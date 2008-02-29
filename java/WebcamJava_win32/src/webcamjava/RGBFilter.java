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
public class RGBFilter implements CamFilter{
	private int RedThreshold;
	private int BlueThreshold;
	private int GreenThreshold;
	private int Tolerance; 
	private final int COLORMASK = 0xFF;
	private int BlueLow, BlueHigh;
	private int RedLow, RedHigh;
	private int GreenLow, GreenHigh;
	private final int RGB_MAX = 255;
	private final int RGB_MIN = 0;
	
	public RGBFilter(int red, int green, int blue, int tolerance){
		RedThreshold = red;
		BlueThreshold = blue;
		GreenThreshold = green;
		Tolerance = tolerance;
		BlueLow = BlueThreshold - Tolerance;
		BlueHigh = BlueThreshold + Tolerance;
		RedLow = RedThreshold - Tolerance;
		RedHigh = RedThreshold + Tolerance;
		GreenLow = GreenThreshold - Tolerance;
		GreenHigh = GreenThreshold + Tolerance;

		if (BlueHigh > RGB_MAX) BlueHigh = RGB_MAX;
		if (GreenHigh > RGB_MAX) GreenHigh = RGB_MAX;
		if (RedHigh > RGB_MAX) RedHigh = RGB_MAX;

		if (BlueLow < RGB_MIN) BlueLow = RGB_MIN;
		if (GreenLow < RGB_MIN) GreenLow = RGB_MIN;
		if (RedLow < RGB_MIN) RedLow = RGB_MIN;

		System.out.println("Red Range: " + RedLow + " " + RedHigh);
		System.out.println("Blue Range: " + BlueLow + " " + BlueHigh);
		System.out.println("Green Range: " + GreenLow + " " + GreenHigh);
	}
	public BufferedImage filter(BufferedImage b){
		BufferedImage filtered = new BufferedImage(b.getWidth(), b.getHeight(), b.getType());
		int red, blue, green;
		int color;
		for(int i = 0; i < b.getWidth(); i++){
			for (int j = 0; j < b.getHeight(); j++){
				color = b.getRGB(i, j);
				blue = color & COLORMASK;
				color = color >> 8;
				green = color & COLORMASK;
				color = color >> 8;
				red = color & COLORMASK;
				if ( !(isInBetween(blue,BlueLow, BlueHigh) && 
					isInBetween(red, RedLow, RedHigh) && 
					isInBetween(green, GreenLow, GreenHigh))){
					filtered.setRGB(i, j, Color.BLACK.getRGB());
				} else filtered.setRGB(i, j, b.getRGB(i, j));
			}
		}
		return filtered;
	}
	private void remove_noise(BufferedImage b){

	}
	private boolean isInBetween(int val, int low, int high){
		return val > low && val < high;
	}
}
