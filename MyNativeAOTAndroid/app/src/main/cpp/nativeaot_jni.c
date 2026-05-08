#include <jni.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <android/log.h>

#include "aot_nativemethods.h"

#define LOG_TAG "NativeAotJNI"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static void *native_aot_lib;
static __typeof__(&aotsample_add) fn_add;
static __typeof__(&aotsample_write_line) fn_write_line;
static __typeof__(&aotsample_sumstring) fn_sumstring;

static int resolve_native_aot_exports(void) {
    if (native_aot_lib != NULL) {
        return 0;
    }

    native_aot_lib = dlopen("libNativeAotLib.so", RTLD_NOW);
    if (native_aot_lib == NULL) {
        LOGE("Failed to load libNativeAotLib.so: %s", dlerror());
        return -1;
    }

    fn_add = (__typeof__(fn_add))dlsym(native_aot_lib, "aotsample_add");
    fn_write_line = (__typeof__(fn_write_line))dlsym(native_aot_lib, "aotsample_write_line");
    fn_sumstring = (__typeof__(fn_sumstring))dlsym(native_aot_lib, "aotsample_sumstring");

    if (fn_add == NULL || fn_write_line == NULL || fn_sumstring == NULL) {
        LOGE("Failed to resolve Native AOT exports: %s", dlerror());
        return -1;
    }

    return 0;
}

JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    return resolve_native_aot_exports() == 0 ? JNI_VERSION_1_6 : JNI_ERR;
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
