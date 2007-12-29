#include <jni.h>
#include <stdio.h>
#include "capture.h"
#include "graph.h"
#include "Webcam.h"

JNIEXPORT void JNICALL Java_webcamjava_Webcam_start_1camera
  (JNIEnv *env, jclass class, jstring dev_name, jint width, jint height)
{
	jbyte *my_dev;

	my_dev= (*env)->GetStringUTFChars(env, dev_name, NULL);
	start_camera(my_dev, width, height);
	(*env)->ReleaseStringUTFChars(env, dev_name, my_dev);
}

JNIEXPORT void JNICALL Java_webcamjava_Webcam_capture_1frame
  (JNIEnv *env, jclass class, jintArray image)
{
	jint *my_image;

	my_image= (*env)->GetIntArrayElements(env, image, 0);

	capture_frame(my_image);

	(*env)->ReleaseIntArrayElements(env, image, my_image, 0);
}

JNIEXPORT void JNICALL Java_webcamjava_Webcam_get_1clstrs
  (JNIEnv *env, jclass class, jintArray image, jint width, jint height, jint threshold)
{
	jint *my_image;

	my_image= (*env)->GetIntArrayElements(env, image, 0);

	get_clstrs(my_image, width, height, threshold);

	(*env)->ReleaseIntArrayElements(env, image, my_image, 0);
}

JNIEXPORT void JNICALL Java_webcamjava_Webcam_stop_1camera
  (JNIEnv *env, jclass class)
{
	stop_camera();
}

JNIEXPORT void JNICALL Java_webcamjava_Webcam_test_1camera
  (JNIEnv *env, jclass class, jstring dev_name, jintArray image, jint width, jint height)
{
	jint *my_image;
	jbyte *my_dev;
	int i;

	my_dev= (*env)->GetStringUTFChars(env, dev_name, NULL);
	my_image= (*env)->GetIntArrayElements(env, image, 0);
	
	//printf("\nDevice Name: %s\n",my_dev);
	/*for(i = 0; i < width*height; i++){
		my_image[i] = i%256;
	}*/
	test_image(my_dev, my_image, width, height);

	(*env)->ReleaseStringUTFChars(env, dev_name, my_dev);
	(*env)->ReleaseIntArrayElements(env, image, my_image, 0);
           //test_image("/dev/video0");
}
