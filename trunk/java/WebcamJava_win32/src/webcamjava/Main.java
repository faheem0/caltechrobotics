/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import java.util.Scanner;
import java.util.StringTokenizer;
/**
 *
 * @author tonyfwu
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
	    Scanner scan = new Scanner(System.in);
	    StringTokenizer st;
	    try{
		Webcam cam = new Webcam(FrameGrabber.DEFAULT_DEV_NAME);
		CamFrame frame = new CamFrame(cam);
		CamFrame orgFrame = new CamFrame(cam);
		frame.setFilter(new RGBFilter(150, 56, 42, 50));
		frame.setVisible(true);
		orgFrame.setVisible(true);
		Thread frameThread = new Thread(frame);
		Thread orgThread = new Thread(orgFrame);
		frameThread.start();
		orgThread.start();
		String s;
		int r, g, b, t;
		while (true){
			System.out.print("Set RGB and Threshold: ");
			s = scan.nextLine();
			st = new StringTokenizer(s, " ");
			r = Integer.parseInt(st.nextToken());
			g = Integer.parseInt(st.nextToken());
			b = Integer.parseInt(st.nextToken());
			t = Integer.parseInt(st.nextToken());
			frame.setFilter(new RGBFilter(r, g, b, t));
		}
	    } catch (FrameGrabberException fge){
		fge.printStackTrace();
	    }
	    //for(int i = 0; i < image.length; i++) System.out.println(i%256+":" + (byte)image[i]);
    }

}
