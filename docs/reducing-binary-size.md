# Reducing binary size

How the shipped native libraries for the Apple and Android examples are kept
small, and what each lever actually buys. All numbers below were measured on
this repo (`net10.0`, `Microsoft.DotNet.ILCompiler` 10.0.8, NDK r29) by building
one slice at a time and `stat`-ing the output. Reproduce with the commands in
each section.

## TL;DR

| Platform | Artifact | Before | After | Saving |
|---|---|---:|---:|---:|
| Android (arm64-v8a) | `libNativeAotLib.so` | 6,302,744 | 6,077,408 | −3.6% |
| Android (arm64-v8a) | `libcrypto.so` | 4,835,760 | 3,766,504 | −22.1% |
| Android (arm64-v8a) | `libssl.so` | 758,768 | 587,080 | −22.6% |
| **Android (arm64-v8a)** | **per-ABI total** | **11,897,272** | **10,430,992** | **−12.3%** |
| macOS (arm64) | `NativeAotLib.dylib` | 5,303,744 | 5,104,224 | −3.8% |

The OpenSSL libraries are the bigger absolute win (~1.2 MB/ABI), since they were
shipped completely unstripped. On the `.NET` library only `InvariantGlobalization`
is applied: the other AOT flags were measured but each shaves under 1% of this
~6 MB binary — too subtle to justify changing runtime behavior (see §1).

---

## 1. Native AOT library (`src/NativeAotLib/NativeAotLib.csproj`)

Every csproj size property was applied **one at a time** (cumulatively) and
remeasured, so each row below is the size *after* adding that flag on top of the
ones above it. Two probe RIDs were used: `linux-bionic-arm64` (the Android `.so`)
and `osx-arm64` (the macOS `.dylib`).

Reproduce a single probe:

```sh
# Android probe needs the NDK linker on PATH (the build scripts add it):
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
dotnet publish -r linux-bionic-arm64 src/NativeAotLib/NativeAotLib.csproj -c Release -p:DisableUnsupportedError=true
ls -l src/NativeAotLib/bin/Release/net10.0/linux-bionic-arm64/publish/NativeAotLib.so

dotnet publish -r osx-arm64 src/NativeAotLib/NativeAotLib.csproj -c Release
ls -l src/NativeAotLib/bin/Release/net10.0/osx-arm64/publish/NativeAotLib.dylib
```

### Per-flag measurements (bytes)

| Step (cumulative) | linux-bionic-arm64 | Δ | osx-arm64 | Δ | Verdict |
|---|---:|---:|---:|---:|---|
| baseline (no flags) | 6,302,744 | — | 5,303,744 | — | |
| `StripSymbols=true` | 6,302,744 | 0 | 5,303,744 | 0 | **drop** — already stripped by default (debug info goes to a separate `.dbg`/`.dSYM`) |
| `OptimizationPreference=Size` | 6,140,440 | −162,304 | 5,187,568 | −116,176 | drop — only ~2.5%, behavioral footprint |
| `InvariantGlobalization=true` | 5,917,056 | −223,384 | 4,971,552 | −216,016 | **keep** — biggest single win |
| `UseSystemResourceKeys=true` | 5,937,056 | **+20,000** | 4,972,128 | **+576** | **drop** — *increased* size here |
| `EventSourceSupport=false` | 5,937,056 | 0 | 4,972,128 | 0 | drop — no effect |
| `DebuggerSupport=false` | 5,937,104 | +48 | 4,972,048 | −80 | drop — no effect |
| `MetadataUpdaterSupport=false` | 5,937,104 | 0 | 4,972,048 | 0 | drop — no effect |
| `HttpActivityPropagationSupport=false` | 5,885,240 | −51,864 | 4,922,240 | −49,808 | drop — only ~0.8% |
| `UseNativeHttpHandler=true` | 5,885,288 | +48 | 4,922,240 | 0 | **drop** — no size benefit, and only interop risk |

### What we kept

Only `InvariantGlobalization`. It is the one flag with a non-trivial, clearly-safe
saving; the rest each move under 1% of this ~6 MB library — too subtle to be worth
the change in runtime behavior. It sits in the library's main `PropertyGroup` (not
gated on `Release`) so Debug and Release behave the same — globalization is an
all-configurations decision, not a release-only size trick:

```xml
<InvariantGlobalization>true</InvariantGlobalization>
```

Final (this flag alone): **linux-bionic-arm64 6,077,408** (−3.6%),
**osx-arm64 5,104,224** (−3.8%). These differ slightly from the `InvariantGlobalization`
row in the cumulative table above, which was measured on top of
`OptimizationPreference=Size`.

Notes:
- `InvariantGlobalization=true` is safe for this library: it does plain integer
  add, ASCII string concat, `Console.WriteLine`, and an ASCII-host HTTPS `GET` —
  no culture-sensitive formatting. It does disable IDN (non-ASCII hostnames); if
  you ever need those, drop this flag.
- `StackTraceSupport` is intentionally left at its default (`true`) so exceptions
  keep managed stack traces.
- `StripSymbols` and an explicit `strip -x` on the `.dylib` both yield ~0 bytes —
  the AOT output is already stripped, with debug symbols split into a separate
  `.dbg` (Android) / `.dSYM` (Apple) that is never shipped.

### Why not `<TrimMode>full</TrimMode>`?

It does nothing here. `TrimMode` is an IL-trimmer (`PublishTrimmed`) setting with
`partial`/`full` modes. With `PublishAot=true` the ILC compiler already performs
whole-program reachability analysis and only emits reachable code — there is no
"partial" AOT to upgrade. The AOT-specific knobs above are the real levers.

---

## 2. OpenSSL (`build/build_openssl_android.sh`)

OpenSSL was being built with the default `-O3` and shipped **unstripped** (full
symbol + debug tables). Two independent, lossless changes:

1. **`llvm-strip --strip-unneeded`** after `make` — removes everything not needed
   for dynamic linking, keeping the exported symbols the managed crypto shim
   `dlsym()`s.
2. **`-Os`** on the `Configure` line — builds OpenSSL's own C for size instead of
   speed (we never hammer the hot crypto paths in a TLS shim).

Reproduce: `./build/build_openssl_android.sh arm64-v8a` then
`ls -l examples/AndroidNativeAotExample/app/src/main/jniLibs/arm64-v8a/`.

### Measurements — arm64-v8a (bytes)

| Stage | libcrypto.so | libssl.so |
|---|---:|---:|
| baseline (`-O3`, unstripped) | 4,835,760 | 758,768 |
| + `--strip-unneeded` only | 4,107,888 (−15.1%) | 660,600 (−12.9%) |
| + `-Os` (shipped) | **3,766,504 (−22.1%)** | **587,080 (−22.6%)** |

x86_64 lands similarly: `libcrypto.so` 4,911,384 → 3,932,048, `libssl.so`
758,288 → 593,888.

No algorithms were removed (per the safe-set decision), so TLS behaviour is
unchanged — confirmed by the Android instrumented HTTPS test.

---

## 3. ABIs shipped

The Android example ships **both** `arm64-v8a` and `x86_64` (see `abiFilters` in
`app/build.gradle.kts` and the `ABIS` default in `build_openssl_android.sh`) so it
runs on real devices *and* x86_64 emulators/CI.

`x86_64` is only needed by emulators. For a real-device-only build you can roughly
halve the native payload by dropping it in two places:

```kotlin
// examples/AndroidNativeAotExample/app/build.gradle.kts
ndk { abiFilters += listOf("arm64-v8a") }   // was: "arm64-v8a", "x86_64"
```
```sh
# build/build_openssl_android.sh — default ABI list
ABIS=("arm64-v8a")   # was: ("arm64-v8a" "x86_64")
```

(Google Play app bundles already split native libs per ABI, so a published app
never ships both to one device regardless.)

---

## Total shipped native payload, before → after

| Platform | Before | After |
|---|---:|---:|
| Android, per ABI (arm64-v8a) | ~11.9 MB | ~10.4 MB |
| Android, both ABIs | ~23.9 MB | ~20.8 MB |
| macOS (arm64 slice) | ~5.3 MB | ~5.1 MB |
