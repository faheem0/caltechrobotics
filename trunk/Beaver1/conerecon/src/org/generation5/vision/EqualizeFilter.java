/*
 * EqualizeFilter.java
 * Created on 21 November 2004, 15:05
 *
 * Copyright 2004, Generation5. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify it under 
 * the terms of the GNU General Public License as published by the Free Software 
 * Foundation; either version 2 of the License, or (at your option) any later 
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple 
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */

package org.generation5.vision;

import java.awt.image.*;
import org.generation5.vision.*;

/**
 * This filter performs histogram equalization on their a greyscale or RGB image.
 * @author James Matthews
 */
public class EqualizeFilter extends Filter {
    
    /** Creates a new instance of EqualizeFilter */
    public EqualizeFilter() {
    }
    
    /**
     * Equalizes an images using its histogram.
     * @return the output image.
     * @param output the pre-allocated output image (optional).
     * @param image input image.
     */    
    public java.awt.image.BufferedImage filter(BufferedImage image, BufferedImage output) {        
        // Create our histogram
        Histogram hist = new Histogram(image);
        // Verify our output
        output = verifyOutput(output, image);
        // Set up the rasters
        Raster in_pixels = image.getRaster();
        WritableRaster out_pixels = output.getRaster();
        
        int g = 0;
        double alpha = 255.0 / (image.getWidth() * image.getHeight());

        for (int j=0; j<image.getHeight(); j++) {
            for (int i=0; i<image.getWidth(); i++) {
                g = (int)(alpha * hist.getCumulativeFrequency(in_pixels.getSample(i, j, 0), 0));
                out_pixels.setSample(i, j, 0, g);
                
                if (hist.isGreyscale() == false) {
                    g = (int)(alpha * hist.getCumulativeFrequency(in_pixels.getSample(i, j, 1), 1));
                    out_pixels.setSample(i, j, 1, g);
                    g = (int)(alpha * hist.getCumulativeFrequency(in_pixels.getSample(i, j, 2), 2));
                    out_pixels.setSample(i, j, 2, g);
                }
            }
        }
        
        return output;
    }
    
    public String toString() {
        return "Histogram Equalization";
    }    
}
