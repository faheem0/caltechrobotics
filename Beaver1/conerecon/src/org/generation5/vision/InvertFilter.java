/*
 * InvertFilter.java
 * Created on 01 December 2004, 22:09
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

/**
 * This filter inverts an image. The filter is simply implemented using Java's
 * <code>LookupOp</code>, defining the lookup table as:
 * <code>
 *  lut[i] = (byte)(255-i);
 * </code>
 * @author James Matthews
 */
public class InvertFilter extends Filter {
    
    /** Creates a new instance of InvertFilter */
    public InvertFilter() {
    }
    
    /**
     * Invert the input image.
     * @return the inverted image.
     * @param output the output image (optional).
     * @param image the input image.
     */    
    public java.awt.image.BufferedImage filter(BufferedImage image, BufferedImage output) {
        output = verifyOutput(output, image);
                    
        byte[] lut = new byte[256];
        for (int i=0; i<256; i++) {
            lut[i] = (byte)(255-i);
        }
        
        LookupOp invert = new LookupOp(new ByteLookupTable(0, lut), null);
        
        return invert.filter(image, output);
    }
    
    public String toString() {
        return "Invert";
    }    
}
