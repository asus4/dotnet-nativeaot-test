// Native AOT C# library exports.
// Shared between Apple bridging header and Android JNI shim.

#ifndef AOT_NATIVE_METHODS_H
#define AOT_NATIVE_METHODS_H

extern int aotsample_add(int a, int b);
extern int aotsample_write_line(const char* pString);
extern char* aotsample_sumstring(const char* pStr1, const char* pStr2);

#endif // AOT_NATIVE_METHODS_H
