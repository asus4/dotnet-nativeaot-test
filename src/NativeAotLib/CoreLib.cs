namespace NativeAotLib;

// Pure managed logic, exercised directly by C# tests and called by the native wrappers in NativeMethods.
static class CoreLib
{
    static readonly Lazy<HttpClient> s_httpClient = new(() => new HttpClient());

    internal static int AddCore(int a, int b) => a + b;

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
}
