/*
 * PlotGrid.java
 * Created on 23 September 2004, 20:26
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

import java.awt.*;
import org.generation5.util.*;

/**
 * Plot data as a two-dimensional grid. Data can be passed as either a
 * two-dimensional array of <code>PlotPoint</code>s, or as a three-dimensional
 * array of doubles. This class was primarily designed to facilitate the 
 * visualization of Kohonen neural network weights, but should work well in
 * most other situations too.
 *
 * @author James Matthews
 * @see org.generation5.util.PlotPoint
 * @see org.generation5.nn.KohonenNN
 */
public class PlotGrid extends Plot {
    
    /**
     * A two dimensional array of the grid points.
     */    
    protected PlotPoint[][] gridPoints1;
    /**
     * The grid points as a three-dimensional array of doubles.
     */    
    protected double[][][] gridPoints2;
    
    /** Creates a new instance of PlotGrid */
    public PlotGrid() {
    }
    
    /**
     * Set the grid points as a two-dimensional array of <code>PlotPoint</code>s. Note
     * that this will set any data set with {@link #setGridPoints(double[][][])} to null.
     * @param gridPoints a two-dimensional array of <code>PlotPoint</code>s.
     */    
    public void setGridPoints(PlotPoint[][] gridPoints) {
        gridPoints1 = gridPoints;
        gridPoints2 = null;
    }
    
    /**
     * Set the grid points as a three-dimensional array of doubles. Note
     * that this will set any data set with {@link #setGridPoints(PlotPoint[][])} to
     * null.
     * @param gridPoints the grid points.
     */    
    public void setGridPoints(double[][][] gridPoints) {
        gridPoints2 = gridPoints;
        gridPoints1 = null;
    }
    
    /**
     * Render the grid on a graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        g.setColor(Color.white);
        g.fillRect(0, 0, width, height);
        
        drawAxes(g, width, height);
        
        if (gridPoints1 == null && gridPoints2 == null) return;
        
        int gridWidth, gridHeight;
        int x = 0, y = 0, x1 = 0, y1 = 0;
        
        // Now we branch according to the type of data we've been
        // given. There could be a nicer solution, but I choose this
        // route for the additional speed benefit.
        if (gridPoints1 != null) {
            gridWidth = gridPoints1.length;
            gridHeight = gridPoints1[0].length;

            PlotPoint p1, p2;

            for (int i=0; i<gridWidth; i++) {
                for (int j=0; j<gridHeight; j++) {
                    g.setColor(java.awt.Color.black);
                    p1 = translateCoordinate(gridPoints1[i][j], width, height);

                    if (i < (gridWidth-1)) {
                        p2 = translateCoordinate(gridPoints1[i+1][j], width, height);
                        g.drawLine((int)p1.x, (int)p1.y, (int)p2.x, (int)p2.y);
                    }

                    if (j < (gridHeight-1)) {
                        p2 = translateCoordinate(gridPoints1[i][j+1], width, height);
                        g.drawLine((int)p1.x, (int)p1.y, (int)p2.x, (int)p2.y);
                    }

                    g.setColor(java.awt.Color.red);
                    g.fillRect((int)(p1.x-1), (int)(p1.y-1), 3, 3);
                }
            }
        } else if (gridPoints2 != null) {
            gridWidth = gridPoints2.length;
            gridHeight = gridPoints2[0].length;

            PlotPoint p1, p2;

            for (int i=0; i<gridWidth; i++) {
                for (int j=0; j<gridHeight; j++) {
                    g.setColor(java.awt.Color.black);
                    p1 = translateCoordinate(gridPoints2[i][j][0], gridPoints2[i][j][1], width, height);

                    if (i < (gridWidth-1)) {
                        p2 = translateCoordinate(gridPoints2[i+1][j][0], gridPoints2[i+1][j][1], width, height);
                        g.drawLine((int)p1.x, (int)p1.y, (int)p2.x, (int)p2.y);
                    }

                    if (j < (gridHeight-1)) {
                        p2 = translateCoordinate(gridPoints2[i][j+1][0], gridPoints2[i][j+1][1], width, height);
                        g.drawLine((int)p1.x, (int)p1.y, (int)p2.x, (int)p2.y);
                    }

                    g.setColor(java.awt.Color.red);
                    g.fillRect((int)(p1.x-1), (int)(p1.y-1), 3, 3);
                }
            }
        }
    }    
}
