/*
 * Plot.java
 * Created on 22 September 2004, 21:28
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

/**
 * An abstract base class providing basic functionality for the plot classes.
 * @author James Matthews
 */
public abstract class Plot implements Visualizable {
    /**
     * The type of plot for a given data series.
     */    
    protected int[] plotTypes;
    
    /**
     * Minimum X-range
     */
    protected double minX;
    
    /**
     * Maximum X-range
     */    
    protected double  maxX; 
    
    /**
     * Minimum Y-range
     */
    protected double minY;
    
    /**
     * Maximum Y-range.
     */    
    protected double  maxY;
    private double rangeX;
    /**
     * Draw the axes.
     */    
    protected boolean drawAxes = true;
    
    /**
     * The range
     */
    private double rangeY;
        
    /** Creates a new instance of Plot */
    public Plot() {
    }

    /**
     * Allows the axes to be toggled on and off.
     * @param da should the axes be drawn?
     */    
    public void setDrawAxes(boolean da) {
        drawAxes = da;
    }
    
    /**
     * Render the plot on a graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    abstract public void render(java.awt.Graphics g, int width, int height);
    
    /**
     * Write the plot to file.
     * @param s the image filename.
     * @param width the width of the image.
     * @param height the height of the image.
     */    
    public void writeImage(String s, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }    

    
    /**
     * Translates a cartesian coordinate to absolute coordinates for the graphics context.
     * @param x the x-position.
     * @param y the y-position.
     * @param width the width of the graphics context.
     * @param height the height of the graphics context.
     * @return a <code>PlotPoint</code> corresponding to the absolute coordinates.
     */    
    public PlotPoint translateCoordinate(double x, double y, int width, int height) {
        double dx = width / (double)rangeX;
        double dy = height / (double)rangeY;
        
        double xx = (x - minX) * dx;
        double yy = (maxY - y) * dy;
        
        return new PlotPoint(xx, yy);
    }
    
    /**
     * Translates a cartesian coordinate to absolute coordinates for the graphics context.
     * @param point the point to translate.
     * @param width the width of the graphics context.
     * @param height the height of the graphics context.
     * @return a <code>PlotPoint</code> corresponding to the absolute coordinates.
     */    
    public PlotPoint translateCoordinate(PlotPoint point, int width, int height) {
        return translateCoordinate(point.x, point.y, width, height);
    }

    /**
     * Calculates the ranges for the X and Y coordinates. Required for correct rendering.
     */    
    protected void calculateRanges() {
        rangeX = maxX - minX;
        rangeY = maxY - minY;        
    }
    
    /**
     * Return the X-range.
     * @return the range of the X-axis.
     */    
    public double getRangeX() {
        return rangeX;
    }
    
    /**
     * Return the Y-range.
     * @return the range of the Y-axis.
     */    
    public double getRangeY() {
        return rangeY;
    }
    
    /**
     * Return the minimum X-coordinate.
     * @return the minimum X-coordinate.
     */    
    public double getMinimumX() {
        return minX;
    }
    
    /**
     * Set the minimum X-coordinate.
     * @param mx the new minimum X-coordinate.
     */    
    public void setMinimumX(double mx) {
        minX = mx;
        calculateRanges();
    }
    
    /**
     * Return the maximum X-coordinate.
     * @return the maximum X-coordinate.
     */    
    public double getMaximumX() {
        return maxX;
    }
    
    /**
     * Set the maximum X-coordinate.
     * @param mx the new maximum X-coordinate.
     */    
    public void setMaximumX(double mx) {
        maxX = mx;
        calculateRanges();
    }
    
    /**
     * Return the minimum Y-coordinate.
     * @return the minimum Y-coordinate.
     */    
    public double getMinimumY() {
        return minY;
    }
    
    /**
     * Get the maximum Y-coordinate.
     * @return the maximum Y-coordinate.
     */    
    public double getMaximumY() {
        return maxY;
    }
    
    /**
     * Set the maximum Y-coordinate.
     * @param my the new maximum Y-coordinate.
     */    
    public void setMaximumY(double my) {
        maxY = my;
        calculateRanges();
    }
    
    /**
     * Set the range covered by the plot.
     * @param minX the minimum X-coordinate.
     * @param maxX the maximum X-coordinate.
     * @param minY the minimum Y-coordinate.
     * @param maxY the maximum Y-coordinate.
     */    
    public void setRange(double minX, double maxX, double minY, double maxY) {
        this.minX = minX;
        this.minY = minY;
        this.maxX = maxX;
        this.maxY = maxY;
        
        calculateRanges();
    }

    /**
     * Draws the axes on the given graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    protected void drawAxes(java.awt.Graphics g, int width, int height) {
        if (drawAxes) {
            g.setColor(java.awt.Color.darkGray);
            PlotPoint p1 = translateCoordinate(minX, 0d, width, height),
                      p2 = translateCoordinate(maxX, 0d, width, height),
                      p3 = translateCoordinate(0d, minY, width, height),
                      p4 = translateCoordinate(0d, maxY, width, height);

            g.drawLine((int)p1.x, (int)p1.y, (int)p2.x, (int)p2.y);
            g.drawLine((int)p3.x, (int)p3.y, (int)p4.x, (int)p4.y);
        }        
    }
}
