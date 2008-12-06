/*
 * MeanFilter.java
 * Created on 26 November 2004, 14:01
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

/**
 * A mean filter implemented as a convolution filter.
 *
 * @author James Matthews
 * @see org.generation5.vision.ConvolutionFilter
 */
public class MeanFilter extends ConvolutionFilter {
    
    /**
     * The neighbourhood size.
     */    
    protected int neighbourhoodSize = 1;
    
    /**
     * Creates a new instance of MeanFilter. The default constructor sets the neighbourhood
     * size at 3.
     */
    public MeanFilter() {
        this(3);
    }
    
    /**
     * Creates a new instance of MeanFilter of the specified neighbourhood size.
     * @param neighbourhoodSize the neighbourhood size.
     */    
    public MeanFilter(int neighbourhoodSize) {
        setNeighbourhoodSize(neighbourhoodSize);
    }
    
    /**
     * Set the neighbourhood size. Note that the neighbourhood size must be an odd
     * number. Any even number is increased to make it an odd number.
     * @param ns the new neighbourhood size.
     */    
    public void setNeighbourhoodSize(int ns) {
        if (ns % 2 == 0) ns = ns + 1;
            
        neighbourhoodSize = ns;
        int kernel = ns * ns;
        
        float frac = 1.0f / (float)kernel;
        float[] blurKernel = new float[kernel];
        for (int i=0; i<kernel; i++) {
            blurKernel[i] = frac;
        }
        
        setKernel(new java.awt.image.Kernel(ns, ns, blurKernel));
    }
    
    /**
     * Retrieve the current neighbourhood size.
     * @return the neighbourhood size.
     */    
    public int getNeighbourhoodSize() {
        return neighbourhoodSize;
    }

    /**
     * Blur the image using the mean kernel.
     * @param image the input image.
     * @return the output image.
     */    
    public java.awt.image.BufferedImage filter(java.awt.image.BufferedImage image) {
        return super.filter(image);
    }
    
    public String toString() {
        return "Mean Filter (" + neighbourhoodSize + "x" + neighbourhoodSize + ")";
    }
    
    /**
     * Utility method for the class.
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("usage: java MeanFilter <input> <output> {neighbourhood}");
            return;
        }
        
        try {
            java.awt.image.BufferedImage in = javax.imageio.ImageIO.read(new java.io.File(args[0]));
             
            MeanFilter mean = new MeanFilter();
            
            //
            // Retrieve any possible optional parameters
            //
            if (args.length > 2) mean.setNeighbourhoodSize(Integer.parseInt(args[2]));
            
            // Do the filtering
            java.awt.image.BufferedImage out = mean.filter(in);
            // Write the image (FIXME: currently always JPG...)
            javax.imageio.ImageIO.write(out, "jpg", new java.io.File(args[1]));
            
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }    
}
