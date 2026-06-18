using NativeAotLib;

namespace NativeAotLib.Tests;

// Tests the managed CoreLib logic behind the [UnmanagedCallersOnly] entry points directly,
// without building the native library. The native wrappers only marshal to/from these methods.
public class CoreLibTests
{
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(-4, 1, -3)]
    [InlineData(0, 0, 0)]
    public void AddCore_ReturnsSum(int a, int b, int expected)
    {
        Assert.Equal(expected, CoreLib.AddCore(a, b));
    }

    [Fact]
    public void WriteLineCore_ReturnsZero_ForNonEmptyString()
    {
        Assert.Equal(0, CoreLib.WriteLineCore("hello"));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    public void WriteLineCore_ReturnsMinusOne_ForNullOrEmpty(string? input)
    {
        Assert.Equal(-1, CoreLib.WriteLineCore(input));
    }

    [Fact]
    public void SumStringCore_Concatenates()
    {
        Assert.Equal("foobar", CoreLib.SumStringCore("foo", "bar"));
    }

    [Theory]
    [InlineData(null, "bar")]
    [InlineData("foo", null)]
    [InlineData("", "bar")]
    [InlineData("foo", "")]
    public void SumStringCore_ReturnsNull_ForNullOrEmptyInput(string? first, string? second)
    {
        Assert.Null(CoreLib.SumStringCore(first, second));
    }

    [Fact]
    [Trait("Category", "Network")]
    public async Task HttpGetAsync_ReturnsSuccessStatusAndBody()
    {
        var result = await CoreLib.HttpGetAsync("https://example.com");

        // Result format is "<statusCode> <reasonPhrase>\n<body>".
        Assert.StartsWith("200", result);
        var newlineIndex = result.IndexOf('\n');
        Assert.True(newlineIndex >= 0, "Expected a newline separating status from body.");
        Assert.NotEmpty(result[(newlineIndex + 1)..]);
    }
}
