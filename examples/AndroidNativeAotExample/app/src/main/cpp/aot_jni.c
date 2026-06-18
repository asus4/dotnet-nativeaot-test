#include <jni.h>
#include <stdlib.h>
#include "aot_nativemethods.h"

#define KLASS "com/example/androidnativeaotexample/NativeAot"

// Cached JavaVM
static JavaVM *g_vm = NULL;
// The pending HTTP callback.
static jobject g_http_callback = NULL;

static jint write_line_jni(JNIEnv *env, jclass cls, jstring s) {
    (void) cls;
    if (!s) return aotsample_write_line(NULL);
    const char *c = (*env)->GetStringUTFChars(env, s, NULL);
    if (!c) return -1;
    jint r = aotsample_write_line(c);
    (*env)->ReleaseStringUTFChars(env, s, c);
    return r;
}

static jstring sumstring_jni(JNIEnv *env, jclass cls, jstring a, jstring b) {
    (void) cls;
    const char *ca = (*env)->GetStringUTFChars(env, a, NULL);
    if (!ca) return NULL;
    const char *cb = (*env)->GetStringUTFChars(env, b, NULL);
    if (!cb) {
        (*env)->ReleaseStringUTFChars(env, a, ca);
        return NULL;
    }
    char *r = aotsample_sumstring(ca, cb);
    (*env)->ReleaseStringUTFChars(env, a, ca);
    (*env)->ReleaseStringUTFChars(env, b, cb);
    if (!r) return NULL;
    jstring js = (*env)->NewStringUTF(env, r);
    free(r);
    return js;
}

// Invoked by the C# library
static void native_http_callback(const char *result) {
    JNIEnv *env;
    int attached = 0;
    if ((*g_vm)->GetEnv(g_vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        if ((*g_vm)->AttachCurrentThread(g_vm, &env, NULL) != JNI_OK) return;
        attached = 1;
    }

    if (g_http_callback) {
        jstring js = (*env)->NewStringUTF(env, result ? result : "");
        jclass cbCls = (*env)->GetObjectClass(env, g_http_callback);
        jmethodID mid = (*env)->GetMethodID(env, cbCls, "onResult", "(Ljava/lang/String;)V");
        if (mid) (*env)->CallVoidMethod(env, g_http_callback, mid, js);
        (*env)->DeleteLocalRef(env, js);
        (*env)->DeleteLocalRef(env, cbCls);
        (*env)->DeleteGlobalRef(env, g_http_callback);
        g_http_callback = NULL;
    }

    if (attached) (*g_vm)->DetachCurrentThread(g_vm);
}

static void http_get_jni(JNIEnv *env, jclass cls, jstring url, jobject callback) {
    (void) cls;
    const char *curl = (*env)->GetStringUTFChars(env, url, NULL);
    if (!curl) return;

    if (g_http_callback) (*env)->DeleteGlobalRef(env, g_http_callback);
    g_http_callback = (*env)->NewGlobalRef(env, callback);

    aotsample_http_get(curl, native_http_callback);
    (*env)->ReleaseStringUTFChars(env, url, curl);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    g_vm = vm;
    JNIEnv *env;
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    jclass cls = (*env)->FindClass(env, KLASS);
    if (!cls) return JNI_ERR;

    const JNINativeMethod methods[] = {
            {
                    "aotsample_add",
                    "(II)I",
                    // no wrapper for @CriticalNative
                    (void *) aotsample_add
            },
            {
                    "aotsample_write_line",
                    "(Ljava/lang/String;)I",
                    (void *) write_line_jni
            },
            {
                    "aotsample_sumstring",
                    "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
                    (void *) sumstring_jni
            },
            {
                    "aotsample_http_get",
                    "(Ljava/lang/String;Lcom/example/androidnativeaotexample/NativeAot$HttpCallback;)V",
                    (void *) http_get_jni
            },
    };
    if ((*env)->RegisterNatives(env, cls, methods, sizeof(methods) / sizeof(methods[0])) < 0)
        return JNI_ERR;

    return JNI_VERSION_1_6;
}
