/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package serialplot;
import javax.swing.JPanel;
import java.awt.image.*;
import java.awt.Image;
import java.awt.Graphics;
/**
 *
 * @author tonyfwu
 */
public class ImagePanel extends JPanel{
	private Image myImage;
	public ImagePanel(Image i){
		myImage = i;
	}
	public void paint(Graphics g)
	{
		if(myImage != null) g.drawImage(myImage,0,0,this);
	}
}
