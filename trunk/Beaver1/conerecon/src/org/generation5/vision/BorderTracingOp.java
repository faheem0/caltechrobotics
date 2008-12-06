/*
 * BorderTracingOp.java
 * Created on 29 November 2004, 13:59
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

import java.util.*;
import java.awt.image.*;
import org.generation5.vision.*;

/**
 * Placeholder - this class is not yet implemented!
 * @author James Matthews
 */
public class BorderTracingOp extends Filter {
    
    public final int INNER_TRACE = 0;
    public final int OUTER_TRACE = 1;
    public final int CONNECTIVITY_FOUR  = 4;
    public final int CONNECTIVITY_EIGHT = 8;
    protected int scanStartX = 0;
    protected int scanStartY = 0;
    protected int connectivity = CONNECTIVITY_EIGHT;
    protected LinkedList borderList = new LinkedList();
    
    /** Creates a new instance of BorderTracingOp */
    public BorderTracingOp() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
    }
    
    protected BufferedImage innerBorder(BufferedImage input, BufferedImage output) {
        //   1      3 2 1
        // 2   0    4   0
        //   3      5 6 7
        
        Raster in = input.getRaster();
        int borderStartX = -1, borderStartY = -1;
        
        // Firstly, find the border start
        for (int y=scanStartY; y<input.getHeight(); y++) {
            for (int x=scanStartX; x<input.getWidth(); x++) {
                if (in.getSample(x, y, 0) == 0) {
                    borderStartX = x;
                    borderStartY = y;
                    break;
                }
            }

            if (borderStartX != -1 || borderStartY != -1) break;
        }
        
        // Secondly initiate the border trace
        borderList.add(new Integer(7));
        
        int b = ((Integer)(borderList.getFirst())).intValue();
        
        return output;
    }
    
    public java.awt.image.BufferedImage filter(BufferedImage image, BufferedImage output) {
        if (output == null || output.getType() != BufferedImage.TYPE_BYTE_GRAY)
            output = new BufferedImage( image.getWidth(), image.getHeight(),
                                        image.TYPE_BYTE_GRAY);
        return innerBorder(image, output);
    }    
}
