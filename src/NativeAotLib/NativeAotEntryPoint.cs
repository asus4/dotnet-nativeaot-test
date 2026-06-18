using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace NativeAotLib.Core;

public class NativeEntryPoint
{
    static readonly HttpClient s_httpClient = new();

    [UnmanagedCallersOnly(EntryPoint = "aotsample_add")]
    public static int Add(int a, int b) => AddCore(a, b);

    internal static int AddCore(int a, int b) => a + b;

    [UnmanagedCallersOnly(EntryPoint = "aotsample_write_line")]
    public static int WriteLine(IntPtr pString)
    {
        var str = Marshal.PtrToStringAnsi(pString);
        return WriteLineCore(str);
    }

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

    [UnmanagedCallersOnly(EntryPoint = "aotsample_sumstring")]
    public static IntPtr SumString(IntPtr first, IntPtr second)
    {
        var firstStr = Marshal.PtrToStringAnsi(first);
        var secondStr = Marshal.PtrToStringAnsi(second);
        var sum = SumStringCore(firstStr, secondStr);
        return sum is null ? IntPtr.Zero : Marshal.StringToHGlobalAnsi(sum);
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

    [UnmanagedCallersOnly(EntryPoint = "aotsample_http_get", CallConvs = new[] { typeof(CallConvCdecl) })]
    public static void HttpGet(IntPtr pUrl, IntPtr callback)
    {
        // pUrl is owned by the caller and only valid during this call — copy it now (synchronously).
        var url = Marshal.PtrToStringAnsi(pUrl) ?? string.Empty;
        _ = Task.Run(async () =>
        {
            string result;
            try
            {
                result = await HttpGetAsync(url);
            }
            catch (Exception e)
            {
                result = $"ERROR: {e.Message}";
            }

            IntPtr pResult = Marshal.StringToHGlobalAnsi(result);
            try
            {
                InvokeCallback(callback, pResult);
            }
            finally
            {
                Marshal.FreeHGlobal(pResult);
            }
        });
    }

    static unsafe void InvokeCallback(IntPtr callback, IntPtr result)
    {
        var cb = (delegate* unmanaged[Cdecl]<IntPtr, void>)callback;
        cb(result);
    }

    internal static async Task<string> HttpGetAsync(string url)
    {
        using var response = await s_httpClient.GetAsync(url);
        var body = await response.Content.ReadAsStringAsync();
        return $"{(int)response.StatusCode} {response.ReasonPhrase}\n{body}";
    }
}
