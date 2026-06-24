# Globalization / ICU support under Native AOT

.NET globalization (cultures, culture-aware sorting/casing, non-Gregorian calendars,
normalization, IDN) is powered by [ICU](https://icu.unicode.org/). Normal .NET apps —
including .NET MAUI — ship ICU and have full globalization. This project does **not**:
it sets `<InvariantGlobalization>true</InvariantGlobalization>` (in `Directory.Build.props`),
so ICU is never loaded and only built-in invariant culture data is used.

## Why invariant mode?

- [Statically linked ICU is Linux-only and can't be cross-compiled](https://github.com/dotnet/runtime/blob/main/src/coreclr/nativeaot/docs/compiling.md),
  so it is not an option for iOS / macOS / Android.
- [Android (bionic)](https://github.com/dotnet/runtime/blob/main/src/coreclr/nativeaot/docs/android-bionic.md)
  has no system ICU, so invariant mode (or bundling app-local ICU) is required.
- It gives one dependency-free baseline across all three platforms.

## What works vs. what doesn't

| C# API | Invariant mode |
|--------|----------------|
| `DateTime.Now` / `UtcNow`, `TimeZoneInfo.Local` | ✅ OS-backed, no ICU needed |
| `GregorianCalendar`, invariant date/number formatting | ✅ Built in |
| Ordinal string compare / `ToUpperInvariant` | ✅ |
| `CultureInfo.CurrentCulture` | ⚠️ Always invariant (`.Name == ""`) |
| `new CultureInfo("ja-JP")` (any specific culture) | ❌ `CultureNotFoundException` |
| `JapaneseCalendar` / other non-Gregorian calendars | ❌ `TypeInitializationException` |
| Culture-aware sorting, `String.Normalize`, `IdnMapping` | ❌ Unavailable |

The example apps expose this via the **Clock Now**, **Calendar Today**, and **Culture** buttons.

## What if `InvariantGlobalization` is `false`?

- **macOS / iOS**: the app still runs — Apple platforms ship system ICU (`libicucore`),
  which the Native AOT link line links (`-licucore`), so full globalization works
  (e.g. `new CultureInfo("ja-JP")` succeeds).
- **Android (bionic)**: there is no system ICU, so it requires bundling app-local ICU;
  otherwise globalization initialization fails at startup.

That is why the repo keeps `InvariantGlobalization=true`.
