using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace NativeAotLib;

// [UnmanagedCallersOnly] entry points exported to native code.
public static class NativeMethods
{
    [UnmanagedCallersOnly(EntryPoint = "aotsample_add")]
    public static int Add(int a, int b) => CoreLib.AddCore(a, b);

    // Calls into the NativeFib NuGet native package via CoreLib.
    [UnmanagedCallersOnly(EntryPoint = "aotsample_fibonacci")]
    public static long Fibonacci(int n) => CoreLib.FibonacciCore(n);

    [UnmanagedCallersOnly(EntryPoint = "aotsample_write_line")]
    public static int WriteLine(IntPtr pString)
    {
        var str = Marshal.PtrToStringAnsi(pString);
        return CoreLib.WriteLineCore(str);
    }

    [UnmanagedCallersOnly(EntryPoint = "aotsample_sumstring")]
    public static IntPtr SumString(IntPtr first, IntPtr second)
    {
        var firstStr = Marshal.PtrToStringAnsi(first);
        var secondStr = Marshal.PtrToStringAnsi(second);
        var sum = CoreLib.SumStringCore(firstStr, secondStr);
        return sum is null ? IntPtr.Zero : Marshal.StringToHGlobalAnsi(sum);
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
                result = await CoreLib.HttpGetAsync(url);
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
}
