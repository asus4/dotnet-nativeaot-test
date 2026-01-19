#include <jni.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <android/log.h>

#define LOG_TAG "NativeAotJNI"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// NativeAOT library name
#define NATIVE_LIB_NAME "libNativeAotLib.so"

// Function pointer types for NativeAOT exports
typedef int (*add_fn)(int, int);
typedef int (*write_line_fn)(const char*);
typedef char* (*sumstring_fn)(const char*, const char*);

// Function pointers (lazy initialized)
static add_fn fn_add = NULL;
static write_line_fn fn_write_line = NULL;
static sumstring_fn fn_sumstring = NULL;
static void* lib_handle = NULL;

// Helper macro for loading symbols
#define LOAD_SYMBOL(var, type, name) do { \
    var = (type)dlsym(lib_handle, name); \
    if (var == NULL) { \
        LOGE("Symbol not found: %s - %s", name, dlerror()); \
        return -1; \
    } \
} while(0)

// Initialize by loading NativeAotLib and resolving symbols
JNIEXPORT jint JNICALL
Java_com_example_mynativeaotandroid_NativeAot_nativeInit(
    JNIEnv *env, jclass thiz) {
    if (lib_handle != NULL) return 0;

    lib_handle = dlopen(NATIVE_LIB_NAME, RTLD_NOW | RTLD_GLOBAL);
    if (lib_handle == NULL) {
        LOGE("Failed to load %s: %s", NATIVE_LIB_NAME, dlerror());
        return -1;
    }

    LOAD_SYMBOL(fn_add, add_fn, "aotsample_add");
    LOAD_SYMBOL(fn_write_line, write_line_fn, "aotsample_write_line");
    LOAD_SYMBOL(fn_sumstring, sumstring_fn, "aotsample_sumstring");

    return 0;
}

JNIEXPORT jint JNICALL
Java_com_example_mynativeaotandroid_NativeAot_nativeAdd(jint a, jint b) {
    return fn_add(a, b);
}

JNIEXPORT jint JNICALL
Java_com_example_mynativeaotandroid_NativeAot_nativeWriteLine(
    JNIEnv *env, jobject thiz, jstring message) {

    const char *nativeMessage = (*env)->GetStringUTFChars(env, message, NULL);
    if (nativeMessage == NULL) {
        return -1;
    }

    int result = fn_write_line(nativeMessage);

    (*env)->ReleaseStringUTFChars(env, message, nativeMessage);
    return result;
}

JNIEXPORT jstring JNICALL
Java_com_example_mynativeaotandroid_NativeAot_nativeSumString(
    JNIEnv *env, jobject thiz, jstring str1, jstring str2) {

    const char *nativeStr1 = (*env)->GetStringUTFChars(env, str1, NULL);
    if (nativeStr1 == NULL) {
        return NULL;
    }

    const char *nativeStr2 = (*env)->GetStringUTFChars(env, str2, NULL);
    if (nativeStr2 == NULL) {
        (*env)->ReleaseStringUTFChars(env, str1, nativeStr1);
        return NULL;
    }

    char *result = fn_sumstring(nativeStr1, nativeStr2);

    (*env)->ReleaseStringUTFChars(env, str1, nativeStr1);
    (*env)->ReleaseStringUTFChars(env, str2, nativeStr2);

    if (result == NULL) {
        return NULL;
    }

    jstring jResult = (*env)->NewStringUTF(env, result);

    // Free memory
    free(result);

    return jResult;
}
