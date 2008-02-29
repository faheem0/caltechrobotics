/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import java.awt.image.BufferedImage;
import java.awt.Color;
/**
 *
 * @author tonyfwu
 */
public class SatFilter implements CamFilter{
	private float Low, High;
	private int color, blue, green, red;
	private final int COLORMASK = 0xFF;
	public SatFilter(float satL, float satH){
		Low = satL;
		High = satH;
	}
	public BufferedImage filter(BufferedImage b){
		BufferedImage filtered = new BufferedImage(b.getWidth(), b.getHeight(), b.getType());
		for (int i = 0; i < b.getWidth(); i++){
			for (int j = 0; j < b.getHeight(); j++){
				color = b.getRGB(i, j);
				blue = color & COLORMASK;
				color = color >> 8;
				green = color & COLORMASK;
				color = color >> 8;
				red = color & COLORMASK;
				if(isInRange((Color.RGBtoHSB(red, green, blue, null))[1])){
					filtered.setRGB(i, j, b.getRGB(i, j));
				} else filtered.setRGB(i, j, Color.BLACK.getRGB());
			}
		}
		return filtered;
	}
	private boolean isInRange(float f){
		return (f > Low && f < High);
	}
}
