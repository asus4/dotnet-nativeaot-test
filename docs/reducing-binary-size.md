# Reducing binary size

How the shipped native libraries are kept small, and what each lever actually buys.
Numbers measured on this repo (`net10.0`, `Microsoft.DotNet.ILCompiler` 10.0.8, NDK r29)
by building one slice at a time and `stat`-ing the output.

## Summary

| Platform | Before | After | Saving |
|---|---:|---:|---:|
| Android, per ABI (arm64-v8a) | ~11.9 MB | ~10.4 MB | −12% |
| Android, both ABIs | ~23.9 MB | ~20.8 MB | −13% |
| macOS (arm64) | ~5.3 MB | ~5.1 MB | −4% |

Two levers do the work: `InvariantGlobalization` on the .NET library, and stripping +
size-optimizing the OpenSSL libs — the latter being the bigger absolute win (~1.2 MB/ABI).

## 1. Native AOT library

Every csproj size flag was applied one at a time and remeasured. **Only
`InvariantGlobalization=true` is worth keeping** (−3.6% Android, −3.8% macOS — the
biggest single win). The rest each move under 1%, not worth the behavior change:

- `StripSymbols`, `EventSourceSupport`, `DebuggerSupport`, `MetadataUpdaterSupport`,
  `UseNativeHttpHandler`: ~0 bytes here (AOT output is already stripped; these have no
  effect for this code).
- `UseSystemResourceKeys=true`: *increased* size.
- `OptimizationPreference=Size` (~2.5%) and `HttpActivityPropagationSupport=false`
  (~0.8%): real but small, and behavioral — dropped.

Notes:
- `InvariantGlobalization=true` is safe for this library (integer add, ASCII string
  concat, ASCII-host HTTPS — no culture-sensitive formatting). It disables IDN; drop it
  if you need non-ASCII hostnames. See [globalization-support.md](globalization-support.md).
- `StackTraceSupport` is left at its default (`true`) so exceptions keep managed stack traces.
- **`<TrimMode>full</TrimMode>` does nothing under AOT** — ILC already does whole-program
  reachability analysis and emits only reachable code; there is no "partial" AOT to upgrade.

## 2. OpenSSL (`build/build_openssl_android.sh`)

OpenSSL was built `-O3` and shipped unstripped. Two lossless changes, ~−22% each on
`libcrypto.so` / `libssl.so`:

1. `llvm-strip --strip-unneeded` after `make` — keeps the exported symbols the managed
   crypto shim `dlsym()`s.
2. `-Os` on the `Configure` line — size over speed (fine for a TLS shim).

No algorithms were removed, so TLS behavior is unchanged (confirmed by the Android
instrumented HTTPS test).

## 3. ABIs shipped

The Android example ships **both** `arm64-v8a` and `x86_64` so it runs on real devices
*and* x86_64 emulators/CI. For a real-device-only build, drop `x86_64` in
`app/build.gradle.kts` (`abiFilters`) and `build_openssl_android.sh` (`ABIS`) to roughly
halve the native payload. (Google Play app bundles split native libs per ABI anyway.)
