#include "fib.h"

int64_t nativefib_fibonacci(int32_t n)
{
    if (n <= 0)
    {
        return 0;
    }

    int64_t a = 0;
    int64_t b = 1;
    for (int32_t i = 1; i < n; i++)
    {
        int64_t next = a + b;
        a = b;
        b = next;
    }
    return b;
}
