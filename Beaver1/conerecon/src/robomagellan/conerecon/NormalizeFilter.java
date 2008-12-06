/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.conerecon;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.awt.image.Raster;
import java.awt.image.WritableRaster;
import org.generation5.vision.Filter;

/**
 *
 * @author tonyfwu
 */
class NormalizeFilter extends Filter{
	private float[] diff;
	public NormalizeFilter() {
		diff = new float[3];
	}

	@Override
	public BufferedImage filter(BufferedImage image, BufferedImage output) {
		output = verifyOutput(output, image);
		Raster in_pixels = image.getRaster();
		WritableRaster out_pixels = output.getRaster();
		int[] ex = extrema(in_pixels);
		
		diff[0] = 255.0f/(ex[0] - ex[3] + 0.001f);
		diff[1] = 255.0f/(ex[1] - ex[4] + 0.001f);
		diff[2] = 255.0f/(ex[2] - ex[5] + 0.001f);
		for (int i = 0; i < image.getWidth(); i++){
			for (int j = 0; j < image.getHeight(); j++){
				out_pixels.setSample(i, j, 0, Math.round((in_pixels.getSample(i, j, 0) - ex[3]) * diff[0])); 
				out_pixels.setSample(i, j, 1, Math.round((in_pixels.getSample(i, j, 1) - ex[4]) * diff[1])); 
				out_pixels.setSample(i, j, 2, Math.round((in_pixels.getSample(i, j, 2) - ex[5]) * diff[2])); 
			}
		}
		return output;
	}
	private int[] extrema(Raster ras){
		int[] ex = {0,0,0,255,255,255};
		int red, green, blue;
		for (int i = 0; i < ras.getWidth(); i++){
			for (int j = 0; j < ras.getHeight(); j++){
				red = ras.getSample(i, j, 0);
				green = ras.getSample(i, j, 1);
				blue = ras.getSample(i, j, 2);
				ex[0] = Math.max(ex[0], red);
				ex[1] = Math.max(ex[1], green);
				ex[2] = Math.max(ex[2], blue);
				ex[3] = Math.min(ex[3], red);
				ex[4] = Math.min(ex[4], green);
				ex[5] = Math.min(ex[5], blue);
			}
		}
		return ex;
	}

}