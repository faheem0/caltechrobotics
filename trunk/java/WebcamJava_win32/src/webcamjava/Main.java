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
	    Webcam cam = new Webcam(FrameGrabber.DEFAULT_DEV_NAME);
	    CamFrame frame = new CamFrame(cam);
	    frame.setVisible(true);
	    //for(int i = 0; i < image.length; i++) System.out.println(i%256+":" + (byte)image[i]);
    }

}
