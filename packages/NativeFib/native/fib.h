// NativeFib — sample native dependency shipped as a NuGet "native files" package.
// A single, uniquely-named export so it won't clash with other native code that
// gets statically linked into the same Native AOT binary.

#ifndef NATIVEFIB_H
#define NATIVEFIB_H

#include <stdint.h>

// Returns the n-th Fibonacci number (0-indexed: 0,1,1,2,3,5,...).
// Returns 0 for n <= 0. int64_t avoids 32-bit overflow for larger n.
int64_t nativefib_fibonacci(int32_t n);

#endif // NATIVEFIB_H
