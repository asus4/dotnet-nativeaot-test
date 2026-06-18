using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace NativeAotLib.Core;

public class NativeEntryPoint
{
    private static readonly HttpClient s_httpClient = new HttpClient();

    [UnmanagedCallersOnly(EntryPoint = "aotsample_add")]
    public static int Add(int a, int b)
    {
        return a + b;
    }

    [UnmanagedCallersOnly(EntryPoint = "aotsample_write_line")]
    public static int WriteLine(IntPtr pString)
    {
        try
        {
            var str = Marshal.PtrToStringAnsi(pString);
            if (string.IsNullOrEmpty(str))
            {
                throw new ArgumentNullException(nameof(pString));
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
        try
        {
            var firstStr = Marshal.PtrToStringAnsi(first);
            var secondStr = Marshal.PtrToStringAnsi(second);
            if (string.IsNullOrEmpty(firstStr))
            {
                throw new ArgumentNullException(nameof(first));
            }
            if (string.IsNullOrEmpty(secondStr))
            {
                throw new ArgumentNullException(nameof(second));
            }

            // Concatenate strings 
            string sum = $"{firstStr}{secondStr}";
            IntPtr sumPointer = Marshal.StringToHGlobalAnsi(sum);
            return sumPointer;
        }
        catch
        {
            return IntPtr.Zero;
        }
    }

    /// <summary>
    /// Performs an async HTTP GET and reports the result through a native callback.
    /// </summary>
    /// <remarks>
    /// A <see cref="UnmanagedCallersOnly"/> entry point cannot return a <see cref="Task"/> across
    /// the native boundary, so this method returns immediately and runs the request on a background
    /// <see cref="Task"/>. When it completes it invokes <paramref name="callback"/> exactly once with
    /// the result (or "ERROR: ..."). The result pointer is only valid for the duration of the callback
    /// — it is freed right after the callback returns, so callers must copy the string before returning.
    /// </remarks>
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

    // Calling a native function pointer requires an unsafe context, which is not allowed in an
    // async method — so the cast and call live in this small synchronous helper.
    private static unsafe void InvokeCallback(IntPtr callback, IntPtr result)
    {
        var cb = (delegate* unmanaged[Cdecl]<IntPtr, void>)callback;
        cb(result);
    }

    private static async Task<string> HttpGetAsync(string url)
    {
        using var response = await s_httpClient.GetAsync(url);
        var body = await response.Content.ReadAsStringAsync();
        return $"{(int)response.StatusCode} {response.ReasonPhrase}\n{body}";
    }
}
