/*
 * ImageHelper.java
 * Created on 22 July 2004, 14:25
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

package org.generation5.util;

import org.generation5.*;
import java.awt.*;
import java.awt.image.*;
import javax.imageio.*;
import java.io.*;

/**
 * This utility class provides simple helper functions to aid image loading, saving
 * and rendering within the Generation5 classes.
 * @author James Matthews
 */
public class ImageHelper {
    
    /** Creates a new instance of ImageHelper */
    public ImageHelper() {
    }
    
    /**
     * This function writes an image of a given Visualizable object. The <code>render</code>
     * function is called, rendering the image on to a graphics context before being
     * written to an image.
     * @see org.generation5.Visualizable
     * @param filename filename of the image to write
     * @param width the width of the image in pixels
     * @param height the height of the image in pixels
     * @param content the visualizable content
     * @throws IOException this exception is thrown by the <code>javax.imageio</code> classes if there is a
     * problem writing the image
     */    
    public static void writeVisualizedImage(String filename, int width, int height,
                                     Visualizable content) throws IOException {
        writeVisualizedImage(filename, width, height, content, true);
    }
    
    /**
     * This function writes an image of a given Visualizable object. The <code>render</code>
     * function is called, rendering the image on to a graphics context before being
     * written to an image.
     * @see org.generation5.Visualizable
     * @param aa should anti-aliasing be used?
     * @param filename filename of the image to write
     * @param width the width of the image in pixels
     * @param height the height of the image in pixels
     * @param content the visualizable content
     * @throws IOException this exception is thrown by the <code>javax.imageio</code> classes if there is a
     * problem writing the image
     */    
    public static void writeVisualizedImage(String filename, int width, int height,
                                     Visualizable content, boolean aa) throws IOException {
        // TODO: Detect image type from filename.
        BufferedImage buffer = new BufferedImage(width, height, 1);
        Graphics2D graphics = buffer.createGraphics();
        // Anti-alias as default for written images.
        if (aa == true) {
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                                      RenderingHints.VALUE_ANTIALIAS_ON);
            graphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
                                      RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        }
        
        content.render(graphics, width, height);

        File file = new File(filename);
        ImageIO.write(buffer, "png", file);
    }
}
