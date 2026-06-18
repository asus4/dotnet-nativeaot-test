#include <jni.h>
#include <stdlib.h>
#include "aot_nativemethods.h"

#define KLASS "com/example/mynativeaotandroid/NativeAot"

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

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
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
    };
    if ((*env)->RegisterNatives(env, cls, methods, sizeof(methods) / sizeof(methods[0])) < 0)
        return JNI_ERR;

    return JNI_VERSION_1_6;
}
