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
public class DifferenceFilter extends Filter{
	private BufferedImage ref;
	private Raster ref_pixels;
	private DifferenceFilter(BufferedImage ref){
		this.ref = ref;
		ref_pixels = ref.getRaster();
	}
	public DifferenceFilter(){

	}
	public void setReference(BufferedImage ref){
		this.ref = ref;
		ref_pixels = ref.getRaster();
	}
	@Override
	public BufferedImage filter(BufferedImage image, BufferedImage output) {
		output = verifyOutput(output, image);

		Raster in_pixels = image.getRaster();
		WritableRaster out_pixels = output.getRaster();
		int value, red, green, blue;
		//		System.out.println(ref_pixels.getNumBands());
		for (int i = 0; i < image.getWidth(); i++){
			for (int j = 0; j < image.getHeight(); j++){
				value = ref_pixels.getSample(i, j, 0);
				//value = 0 ;//ref_pixels.getSample(i, j, 0);
				red = in_pixels.getSample(i, j, 0) - value;
				green = in_pixels.getSample(i, j, 1) - value;
				blue = in_pixels.getSample(i, j, 2) - value;
				if (red < 0) red = 0;
				if (blue < 0) blue = 0;
				if (green < 0) green = 0;
				//System.out.println(red + " "  + green + " "  + blue);
				out_pixels.setSample(i, j, 0, red);
				out_pixels.setSample(i, j, 1, green);
				out_pixels.setSample(i, j, 2, blue);
			}
		}
		return output;
	}

}
