#include <jni.h>
#include <android/log.h>
#include <dlfcn.h>
#include <stdlib.h>
#include "aot_nativemethods.h"

#define KLASS "com/example/mynativeaotandroid/NativeAot"
#define LOG_TAG "NativeAotJNI"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// libNativeAotLib.so has no SONAME, so link-time linking against it bakes the
// build-host absolute path into DT_NEEDED. We resolve the exports at runtime
// instead. Kotlin loads the library via System.loadLibrary before this shim,
// so dlopen here only bumps the refcount for dlsym.
static int (*fn_add)(int a, int b);
static int (*fn_write_line)(const char* pString);
static char* (*fn_sumstring)(const char* pStr1, const char* pStr2);

static int resolve_native_aot_exports(void) {
    void* lib = dlopen("libNativeAotLib.so", RTLD_NOW);
    if (!lib) {
        LOGE("Failed to load libNativeAotLib.so: %s", dlerror());
        return -1;
    }

    fn_add = (int (*)(int, int))dlsym(lib, "aotsample_add");
    fn_write_line = (int (*)(const char*))dlsym(lib, "aotsample_write_line");
    fn_sumstring = (char* (*)(const char*, const char*))dlsym(lib, "aotsample_sumstring");

    if (!fn_add || !fn_write_line || !fn_sumstring) {
        LOGE("Failed to resolve Native AOT exports: %s", dlerror());
        dlclose(lib);
        return -1;
    }

    return 0;
}

static jint write_line_jni(JNIEnv* env, jclass cls, jstring s) {
    (void)cls;
    if (!s) return fn_write_line(NULL);
    const char* c = (*env)->GetStringUTFChars(env, s, NULL);
    if (!c) return -1;
    jint r = fn_write_line(c);
    (*env)->ReleaseStringUTFChars(env, s, c);
    return r;
}

static jstring sumstring_jni(JNIEnv* env, jclass cls, jstring a, jstring b) {
    (void)cls;
    const char* ca = (*env)->GetStringUTFChars(env, a, NULL);
    if (!ca) return NULL;
    const char* cb = (*env)->GetStringUTFChars(env, b, NULL);
    if (!cb) {
        (*env)->ReleaseStringUTFChars(env, a, ca);
        return NULL;
    }
    char* r = fn_sumstring(ca, cb);
    (*env)->ReleaseStringUTFChars(env, a, ca);
    (*env)->ReleaseStringUTFChars(env, b, cb);
    if (!r) return NULL;
    jstring js = (*env)->NewStringUTF(env, r);
    free(r);
    return js;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) {
    (void)reserved;
    JNIEnv* env;
    if ((*vm)->GetEnv(vm, (void**)&env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;
    if (resolve_native_aot_exports() != 0) return JNI_ERR;

    jclass cls = (*env)->FindClass(env, KLASS);
    if (!cls) return JNI_ERR;

    const JNINativeMethod methods[] = {
        // @CriticalNative: bound directly to the Native AOT export, no wrapper.
        {"aotsample_add",        "(II)I",                                                     (void*)fn_add},
        {"aotsample_write_line", "(Ljava/lang/String;)I",                                     (void*)write_line_jni},
        {"aotsample_sumstring",  "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;", (void*)sumstring_jni},
    };
    if ((*env)->RegisterNatives(env, cls, methods, sizeof(methods) / sizeof(methods[0])) < 0) return JNI_ERR;

    return JNI_VERSION_1_6;
}
