/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import java.awt.image.BufferedImage;
import java.awt.Image;
/**
 *
 * @author tonyfwu
 */
public class Webcam {
	private FrameGrabber vision;

	public Webcam(String deviceName) throws FrameGrabberException{
		vision = new FrameGrabber(deviceName);
		vision.start();
	}
	public Image getImage()
	{
		return vision.getImage();
	}
	public BufferedImage getFrame()
	{
		return vision.getBufferedImage();
	}
}
