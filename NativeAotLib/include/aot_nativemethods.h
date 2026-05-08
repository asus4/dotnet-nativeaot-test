#ifndef AOT_NATIVEMETHODS_H
#define AOT_NATIVEMETHODS_H

#ifdef __cplusplus
extern "C" {
#endif

int aotsample_add(int a, int b);
int aotsample_write_line(const char *pString);
char *aotsample_sumstring(const char *pStr1, const char *pStr2);

#ifdef __cplusplus
}
#endif

#endif // AOT_NATIVEMETHODS_H
