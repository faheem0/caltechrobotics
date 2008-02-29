/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import java.awt.Frame;
import java.awt.image.*;
import java.awt.Image;
import java.awt.Graphics;
import java.awt.event.*;
import java.awt.Color;
/**
 *
 * @author tonyfwu
 */
public class CamFrame extends Frame{
	private Image myImage;
	private Webcam cam;
	private static int camNumber = 0;
	private CamFilter myFilter;
	public CamFrame(Webcam w){
		cam = w;
		myImage = cam.getImage();
		setSize(myImage.getWidth(this), myImage.getHeight(this));
		setBackground(Color.black);
		addWindowListener(new WindowListener());
		setTitle("Cam " + camNumber);
		camNumber++;
		myFilter = null;
	}
	public void setFilter(CamFilter f){
		myFilter = f;
	}
	public void updateImage(){
		BufferedImage tmp = cam.getFrame();
		BufferedImage buffer = null;
		if (myFilter != null){
			buffer = myFilter.filter(tmp);
			myImage = buffer;
		} else myImage = tmp;

	}
	public void paint(Graphics g)
	{
		if(myImage != null) g.drawImage(myImage,0,0,this);
	}
	public void update(Graphics g) {
		paint(g);
	}
	class WindowListener extends WindowAdapter {
		public void windowClosing(WindowEvent e) {
			System.exit(0);
		}
	}

}
