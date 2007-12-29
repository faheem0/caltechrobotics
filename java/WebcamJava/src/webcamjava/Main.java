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
	    int width = 352;
	    int height = 288;
	    long fps = 30;
	    int Y,Y_clstr,n;
	    int[] image = new int[width*height];
	    int[] image_clstr = new int[width*height];
	    String device = "/dev/video0";
	    //Webcam.test_camera(device, image, width, height);
	    Webcam.start_camera(device, width, height);
	    //for(int i = 0; i < image.length; i++) System.out.println(i+":" + image[i]);
	    JButton exitButton = new JButton("Exit");
	    exitButton.setActionCommand("exit");
	    exitButton.addActionListener(new Actions());

	    JFrame frame = new JFrame(device);
	    JFrame frame_clstr = new JFrame(device + " Clusters");
	    JFrame buttonFrame = new JFrame("Buttons");
	    frame.setPreferredSize(new Dimension(width,height));
	    frame_clstr.setPreferredSize(new Dimension(width,height));
	    BufferedImage bImage = new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);
	    BufferedImage bImage_clstr = new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);
	    ImagePanel panel = new ImagePanel(bImage);
	    ImagePanel panel_clstr = new ImagePanel(bImage_clstr);
	    
	    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    frame_clstr.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    frame.getContentPane().add(panel);
	    frame_clstr.getContentPane().add(panel_clstr);
	    buttonFrame.add(exitButton);
	    buttonFrame.pack();
	    frame.pack();
	    frame_clstr.pack();
	    frame.setVisible(true);
	    frame_clstr.setVisible(true);
	    buttonFrame.setVisible(true);

	    Long sleep, start;
	    while(true){
		n = 0;
		start = System.currentTimeMillis();
		Webcam.capture_frame(image);
		Webcam.get_clstrs(image_clstr, width, height, 150);
		for(int j = 0; j < height; j++){
			for(int i = 0; i < width; i++){
			    Y = image[n];
			    Y_clstr = image_clstr[n];
			    bImage.setRGB(i, j, (new Color(Y,Y,Y)).getRGB());
			    bImage_clstr.setRGB(i, j, (new Color(Y_clstr,Y_clstr,Y_clstr)).getRGB());
			    n++;
			 }
		}
		panel.repaint();
		panel_clstr.repaint();
		sleep = fps - System.currentTimeMillis() + start;
		if (sleep <= 0) continue;
		try{
			Thread.sleep(sleep);
		} catch (InterruptedException e){
			System.out.println("oops");
		}
	    }
	    
	    //for(int i = 0; i < image.length; i++) System.out.println(i%256+":" + (byte)image[i]);
    }

}
