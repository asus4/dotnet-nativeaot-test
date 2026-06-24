// Native AOT C# library exports.
// Shared between Apple bridging header and Android JNI shim.

#ifndef AOT_NATIVE_METHODS_H
#define AOT_NATIVE_METHODS_H

extern int aotsample_add(int a, int b);
extern long long aotsample_fibonacci(int n);
extern int aotsample_write_line(const char* pString);
extern char* aotsample_sumstring(const char* pStr1, const char* pStr2);

// callback for http_get
typedef void (*aotsample_http_callback)(const char* result);
extern void aotsample_http_get(const char* url, aotsample_http_callback callback);

// Globalization probes. Each returns a malloc'd C string the caller must free().
extern char* aotsample_now(void);
extern char* aotsample_today(void);
extern char* aotsample_culture(void);

#endif // AOT_NATIVE_METHODS_H
