/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
/**
 *
 * @author tonyfwu
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
	    try{
		Webcam cam = new Webcam(FrameGrabber.DEFAULT_DEV_NAME);
		CamFrame frame = new CamFrame(cam);
		CamFrame orgFrame = new CamFrame(cam);
		frame.setFilter(new RGBFilter(150, 56, 42, 50));
		frame.setVisible(true);
		orgFrame.setVisible(true);
		while (true){
			frame.updateImage();
			frame.repaint();
			orgFrame.updateImage();
			orgFrame.repaint();
			try {
				Thread.sleep(100);
			} catch(Exception e) {
				System.out.println("Doh");
			}
		}
	    } catch (FrameGrabberException fge){
		fge.printStackTrace();
	    }
	    //for(int i = 0; i < image.length; i++) System.out.println(i%256+":" + (byte)image[i]);
    }

}
