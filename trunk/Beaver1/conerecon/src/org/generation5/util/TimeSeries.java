/*
 * TimeSeries.java
 * Created on 14 November 2004, 16:41
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

import java.util.*;
import java.awt.*;
import java.awt.image.*;
import org.generation5.*;

/**
 * This class creates a time-series of images. Snapshots of a <code>Visualizable</code>
 * object are added on-the-fly, before specifying the row/column layout and rendering
 * or writing the time-series image.
 *
 * For automatic time-series diagrams, see <code>AutoTimeSeries</code>.
 * @author James Matthews
 * @see AutoTimeSeries
 */
public class TimeSeries implements Visualizable {
    /**
     * The number of rows in the time-series diagram.
     */    
    protected int rows = -1;
    /**
     * The number of columns in the time-series diagram.
     */    
    protected int columns = -1;
    /**
     * The drawing options for the diagram. Currently supported options are anti-
     * aliasing (default) and inner/outer border options (defaults to both).
     */    
    protected int drawFlags = BORDERS | ANTIALIAS;
    /**
     * The background colour.
     */
    protected java.awt.Color backColor = java.awt.Color.lightGray;
    /**
     * The inner border colour.
     */    
    protected java.awt.Color innerBorder = java.awt.Color.BLACK;
    /**
     * The outer border colour.
     */    
    protected java.awt.Color outerBorder = java.awt.Color.BLACK;
    /**
     * The image linked list.
     */    
    protected java.util.LinkedList imgArray = new java.util.LinkedList();
    
    /**
     * No drawing options specified.
     */    
    public static final int NONE = 0;
    /**
     * Draw outer borders.
     */    
    public static final int OUTER_BORDER = 1;
    /**
     * Draw inner borders.
     */    
    public static final int INNER_BORDER = 2;
    /**
     * Draw both inner and outer borders (default).
     */    
    public static final int BORDERS = OUTER_BORDER | INNER_BORDER;
    /**
     * Anti-alias all captured images (default).
     */    
    public static final int ANTIALIAS = 4;
    
    /** Creates a new instance of TimeSeries */
    public TimeSeries() {
    }
    
    /**
     * Set the row/column layout of the image.
     * @param rows number of rows.
     * @param columns number of columns.
     */    
    public void setDimensions(int rows, int columns) {
        this.rows = rows;
        this.columns = columns;
    }
    
    /**
     * Set the background colour. This only sets the background colour for the image
     * itself, not the visualized data.
     * @param back the background colour.
     */    
    public void setBackgroundColor(java.awt.Color back) {
        backColor = back;
    }
    
    /**
     * Set the drawing options.
     * @param flags the drawing options.
     */    
    public void setFormat(int flags) {
        drawFlags = flags;
    }
    
    /**
     * Set the border colour. This is equivalent to calling:
     * <code>    setBorderColors(borderColor, borderColor);</code>
     * @param borderColor the inner/outer border colour.
     */    
    public void setBorderColor(java.awt.Color borderColor) {
        setBorderColors(borderColor, borderColor);
    }
    
    /**
     * Set the inner and outer border colours separately.
     * @param innerBorder the inner border colour.
     * @param outerBorder the outer border colour.
     */    
    public void setBorderColors(java.awt.Color innerBorder, java.awt.Color outerBorder) {
        this.innerBorder = innerBorder;
        this.outerBorder = outerBorder;
    }
    
    /**
     * Add a snapshot to the time-series image. Note that the width and height of the
     * object does not necessarily relate to the final size in the rendered time-series
     * image. See <code>render</code> for more details.
     * @param visObject the object to capture.
     * @param width the width of the snapshot.
     * @param height the height of the snapshot.
     * @see #render(java.awt.Graphics, int, int)
     */    
    public void addSnapshot(Visualizable visObject, int width, int height) {
        BufferedImage snapshot = new BufferedImage(width, height, 1);
        
        Graphics2D graphics = snapshot.createGraphics();
        // Anti-alias as default for written images.
        if ((drawFlags & ANTIALIAS) == ANTIALIAS) {
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                                      RenderingHints.VALUE_ANTIALIAS_ON);
            graphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
                                      RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        }        
        
        visObject.render(graphics, width, height);
        imgArray.add(snapshot);
    }
    
    /**
     * Directly add an image to the time-series. This is useful for creating composite
     * images from, for example, the output of the machine vision filter classes.
     * @param snapshot the buffered image snapshot.
     */    
    public void addSnapshot(BufferedImage snapshot) {
        imgArray.add(snapshot);
    }
    
    /**
     * Return the number of snapshots currently stored.
     * @return the number of snapshots.
     */    
    public int getSnapshots() {
        return imgArray.size();
    }
    
    /**
     * Renders the time-series diagram. This renders the stored snapshots in sequence,
     * filling out each column in the row before moving down to the next row. For example:
     * <code>
     * 4x4, with 9 images
     *
     * x x x x
     * x x x x
     * x _ _ _
     * _ _ _ _
     *
     * 3x3, with 9 images
     *
     * x x x
     * x x x
     * x x x
     * </code>
     *
     * It is also important to note that the captured images are cropped (if necessary)
     * to the appropriate cell size for the time-series image. For example, if snapshots
     * are taken at 200x200, but <code>render</code> is called to draw the time-series
     * image at 600x600 with a layout of 6x6, the captured images will be cropped (not
     * resized).
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        if (rows == -1 || columns == -1)
            throw new IllegalArgumentException("rows and columns not set!");
        
        int position = 0;
        int cw = width / columns;
        int ch = height / rows;
        ListIterator iterator = imgArray.listIterator();
        BufferedImage img;
        
        g.setColor(backColor);
        g.fillRect(0, 0, width, height);
        
        while (iterator.hasNext()) {
            img = (BufferedImage)iterator.next();
            g.drawImage(img, (cw) * (position % columns), (ch) * (position / columns), cw, ch, null);
            position++;
        }
        
        if ((drawFlags & OUTER_BORDER) == OUTER_BORDER) {
            g.setColor(outerBorder);
            g.drawRect(0,0,width-1,height-1);
        }
        
        if ((drawFlags & INNER_BORDER) == INNER_BORDER) {
            g.setColor(innerBorder);
            for (int i=ch; i<height; i+=ch) {
                g.drawLine(0, i, width, i);
            }
            for (int i=cw; i<width; i+=cw) {
                g.drawLine(i, 0, i, height);
            }
        }
    }
    
    public void writeImage(String s, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
    }
    
}
