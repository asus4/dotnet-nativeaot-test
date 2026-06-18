using System.Runtime.InteropServices;

namespace NativeAotLib.Core;

public class NativeEntryPoint
{
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
}
