/*
 * ConvolutionFilter.java
 * Created on 17 November 2004, 14:33
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

import java.io.*;
import java.awt.image.*;

/**
 * This class implements a convolution filter. This class is merely a wrapper for
 * the Java 2D <code>ConvolveOp</code>, but implements the Generation5 JDK's
 * <code>Filter</code>.
 * @author James Matthews
 */
public class ConvolutionFilter extends Filter {
    
    /**
     * The kernel to be used.
     */    
    protected Kernel kernel;
    
    /** Creates a new instance of ConvolutionFilter */
    public ConvolutionFilter() {
    }
    
    /**
     * Creates a new instance of a convolution filter with the given kernel.
     * @param kernel the kernel to use.
     */    
    public ConvolutionFilter(Kernel kernel) {
        setKernel(kernel);
    }
    
    /**
     * Set the kernel to be used.
     * @param kernel the kernel.
     */    
    public void setKernel(Kernel kernel) {
        this.kernel = kernel;
    }
    
    /**
     * Return the kernel currently set.
     * @return the kernel.
     */    
    public Kernel getKernel() {
        return kernel;
    }
        
    /**
     * Convolve the image using the kernel.
     * @return the output image.
     * @param output the pre-allocated output image (optional).
     * @param image the input image.
     */    
    public BufferedImage filter(BufferedImage image, BufferedImage output) {
        if (kernel == null)
            throw new IllegalArgumentException("kernel not set.");
        
        // Verify our output image
        output = verifyOutput(output, image);
        // Set up the convolution operation
        BufferedImageOp operation = new ConvolveOp(kernel);
        // Filter and return the image
        return operation.filter(image, output);
    }
    
    public String toString() {
        return "Convolution";
    }    
}
