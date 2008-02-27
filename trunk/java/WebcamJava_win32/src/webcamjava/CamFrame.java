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
/**
 *
 * @author tonyfwu
 */
public class CamFrame extends Frame{
	private Image myImage;
	private Webcam cam;
	public CamFrame(Webcam w){
		cam = w;
	}
	public void paint(Graphics g)
	{
		myImage = cam.getFrame();
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
