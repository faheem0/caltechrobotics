/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.conerecon;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.awt.image.Raster;
import java.awt.image.WritableRaster;
import org.generation5.vision.EqualizeFilter;
import org.generation5.vision.Filter;
import org.generation5.vision.GreyscaleFilter;
import org.generation5.vision.InvertFilter;

/**
 *
 * @author tonyfwu
 */
public class ConeFilter extends Filter{
	private static final int DENSITY_CHECK_SIZE = 20;
	private static final float DENSITY_THRESHOLD = 0.80f;

	private static InvertFilter invert = new InvertFilter();
	private static NormalizeFilter normalize = new NormalizeFilter();
	private static GreyscaleFilter grayscale = new GreyscaleFilter();
	private static DifferenceFilter difference = new DifferenceFilter();
	
    private boolean detected = false;
    private int xLoc, yLoc;

	public ConeFilter(){
        xLoc = 0;
        yLoc = 0;
	}
	@Override
	public BufferedImage filter(BufferedImage image, BufferedImage output) {
		output = verifyOutput(output,image);
		BufferedImage I_invert = null;
		BufferedImage I_sat = null;
		BufferedImage I_diff = null;
		BufferedImage I_norm = null;

		I_invert = invert.filter(image,I_invert);
		//Desaturate
		I_sat = grayscale.filter(I_invert,I_sat);
		/*I_sat = verifyOutput(I_sat, image);
		WritableRaster sat_pixels = I_sat.getRaster();
		Raster invert_pixels = I_invert.getRaster();
		for (int i = 0; i < output.getWidth(); i++){
			for (int j = 0; j < output.getHeight(); j++){
				red = invert_pixels.getSample(i, j, 0);
				green = invert_pixels.getSample(i, j, 1);
				blue = invert_pixels.getSample(i, j, 2);
				value = Math.round(0.5f * (Math.max(Math.max(red, green), blue) + Math.min(Math.min(red, green),blue)));
				sat_pixels.setSample(i, j, 0, value);
				sat_pixels.setSample(i, j, 1, value);
				sat_pixels.setSample(i, j, 2, value);
			}
		}*/
		//Difference
		difference.setReference(I_sat);
		I_diff = difference.filter(I_invert,I_diff); // TODO: Optimize to single function?
		I_norm = normalize.filter(I_diff,I_norm);
		//output = I_norm;
		output = grayscale.filter(I_norm, output);
		
		int value, x = 0, y = 0, mass = 0, t;
		WritableRaster out_pixels = output.getRaster();
		for (int i = 0; i < output.getWidth(); i++){
			for (int j = 0; j < output.getHeight(); j++){
				value = Math.round((out_pixels.getSample(i, j, 0) & 0xff)/256.0f)*255;
				t = value & 0xff;
				x += i*t;
				y += j*t;
				mass += t;
				//System.out.println(blue + " " + green + " " + red);
				out_pixels.setSample(i, j, 0, value);
			}
		}
		x /= mass;
		y /= mass;
		
		if (density(out_pixels, x, y, DENSITY_CHECK_SIZE) > DENSITY_THRESHOLD){
			/*Graphics g = output.getGraphics();
			g.setColor(Color.ORANGE);
			g.drawOval(x, y, 10, 10);*/
            xLoc = x;
            yLoc = y;
            detected = true;
		} else detected = false;
		return output;
	}
    public boolean isDetected(){
        return detected;
    }
    public int[] getCoords(){
        return new int[]{xLoc, yLoc};
    }
	
	private float density(Raster r, int x, int y, int size){
		if (x - size < 0) x = size;
		if (x + size >= r.getWidth()) size = r.getWidth() - x;
		if (y - size < 0) y = size;
		if (y + size >= r.getHeight()) size = r.getHeight() - y;
		
		float d = 0;
		for (int i = x-size; i < x+size; i++){
			for (int j = y-size; j < y+size; j++){
				if (r.getSample(i, j, 0) != 0) d++;
			}
		}
		return d/(size*size);
	}
}
