/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;

/**
 *
 * @author tonyfwu
 */
public class Webcam {
	
	static {
		System.load("/home/tonyfwu/NetbeansProjects/WebcamLib/dist/Debug/GNU-Linux-x86/libWebcamLib.so");
	}
	static public native void start_camera(String dev_name, int width, int height);
	static public native void capture_frame(int[] image);
	static public native void get_clstrs(int[] image, int width, int height, int threshold);
	static public native void stop_camera();
	static public native void test_camera(
		String dev_name, int[] image, int width, int height);
	

}
