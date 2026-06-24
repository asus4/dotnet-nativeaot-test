using System.Globalization;
using System.Runtime.InteropServices;

namespace NativeAotLib;

// Pure managed logic, exercised directly by C# tests and called by the native wrappers in NativeMethods.
static partial class CoreLib
{
    static readonly Lazy<HttpClient> s_httpClient = new(() => new HttpClient());

    internal static int AddCore(int a, int b) => a + b;

    // P/Invoke into the NativeFib native static lib. DirectPInvoke ("nativefib") +
    // NativeLibrary (libnativefib.a) from the imported src/NativeFib/build/NativeFib.targets
    // statically link this symbol into the AOT output, so there is no separate library to load.
    [LibraryImport("nativefib", EntryPoint = "nativefib_fibonacci")]
    private static partial long NativeFibonacci(int n);

    internal static long FibonacciCore(int n) => NativeFibonacci(n);

    internal static int WriteLineCore(string? str)
    {
        try
        {
            if (string.IsNullOrEmpty(str))
            {
                throw new ArgumentNullException(nameof(str));
            }
            Console.WriteLine(str);
        }
        catch
        {
            return -1;
        }
        return 0;
    }

    internal static string? SumStringCore(string? first, string? second)
    {
        try
        {
            if (string.IsNullOrEmpty(first))
            {
                throw new ArgumentNullException(nameof(first));
            }
            if (string.IsNullOrEmpty(second))
            {
                throw new ArgumentNullException(nameof(second));
            }

            // Concatenate strings
            return $"{first}{second}";
        }
        catch
        {
            return null;
        }
    }

    internal static async Task<string> HttpGetAsync(string url)
    {
        using var response = await s_httpClient.Value.GetAsync(url);
        var body = await response.Content.ReadAsStringAsync();
        return $"{(int)response.StatusCode} {response.ReasonPhrase}\n{body}";
    }

    #region Globalization
    internal static string NowStringCore() => $"local={DateTime.Now:O} utc={DateTime.UtcNow:O}";

    // The (proleptic) Gregorian calendar is built in and needs no ICU data.
    internal static string TodayStringCore()
    {
        var cal = new GregorianCalendar();
        var today = DateTime.Today;
        return $"{cal.GetYear(today):D4}-{cal.GetMonth(today):D2}-{cal.GetDayOfMonth(today):D2}";
    }

    // Will throw CultureNotFoundException under invariant mode 
    internal static string CultureStringCore()
    {
        var current = CultureInfo.CurrentCulture.Name;
        string createJaJp;
        try
        {
            var ja = new CultureInfo("ja-JP");
            createJaJp = $"Ok({ja.Name})";
        }
        catch (Exception e)
        {
            createJaJp = e.GetType().Name;
        }
        return $"current='{current}' createJaJP={createJaJp}";
    }
    #endregion // Globalization
}
