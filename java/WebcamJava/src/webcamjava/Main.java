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
	    int width = 640;
	    int height = 480;
	    int Y,n;
	    int[] image = new int[width*height];
	    String device = "/dev/video0";
	    //Webcam.test_camera(device, image, width, height);
	    Webcam.start_camera(device, width, height);
	    //for(int i = 0; i < image.length; i++) System.out.println(i+":" + image[i]);
	    JButton exitButton = new JButton("Exit");
	    exitButton.setActionCommand("exit");
	    exitButton.addActionListener(new Actions());

	    JFrame frame = new JFrame(device);
	    JFrame buttonFrame = new JFrame("Buttons");
	    frame.setPreferredSize(new Dimension(width,height));
	    BufferedImage bImage = new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);
	    ImagePanel panel = new ImagePanel(bImage);
	    
	    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    frame.getContentPane().add(panel);
	    buttonFrame.add(exitButton);
	    buttonFrame.pack();
	    frame.pack();
	    frame.setVisible(true);
	    buttonFrame.setVisible(true);

	    while(true){
		n = 0;
		Webcam.capture_frame(image);
		for(int j = 0; j < height; j++){
			for(int i = 0; i < width; i++){
			    Y = image[n];
			    bImage.setRGB(i, j, (new Color(Y,Y,Y)).getRGB());
			    n++;
			 }
		}
		panel.repaint();
		try{
			Thread.sleep(15);
		} catch (InterruptedException e){
			System.out.println("oops");
		}
	    }
	    
	    //for(int i = 0; i < image.length; i++) System.out.println(i%256+":" + (byte)image[i]);
    }

}
