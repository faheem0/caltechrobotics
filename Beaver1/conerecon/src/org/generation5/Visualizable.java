/*
 * Steppable.java
 * Created on 23 July 2004, 15:31
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

package org.generation5;

import java.awt.Graphics;

/**
 * This abstract class provides the necessary methods for visualizable data.
 *
 * @author James Matthews
 */
public interface Visualizable {
    
    /**
     * Render the class data in a graphics context.
     * @param g the graphics context
     * @param height the width of the graphics context
     * @param width the height of the graphics context
     */
    public abstract void render(Graphics g, int width, int height);
    
    /**
     * Write an image using the class data. This function should usually use the
     * render function to write the image.
     * @param s the filename of the image to write
     * @param width the width of the image
     * @param height the height of the image
     */
    public abstract void writeImage(String s, int width, int height);
}
