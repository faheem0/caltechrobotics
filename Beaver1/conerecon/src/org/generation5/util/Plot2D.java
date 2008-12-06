/*
 * Plot2D.java
 * Created on 21 August 2004, 16:14
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

import java.io.*;
import java.awt.*;
import java.util.*;
import org.generation5.*;
import org.generation5.util.*;

/**
 * <code>Plot2D</code> is a simple utility class designed to plot data. The class
 * provides the necessary render functions to plot points, line or histogram data.
 * @author James Matthews
 */
public class Plot2D extends Plot {    
    /**
     * The colours to use for the different data-sets.
     */    
    protected Color[] datasetColors = {
        Color.RED, new Color(0,128,0), Color.BLUE, Color.YELLOW,
        Color.MAGENTA, Color.ORANGE, Color.CYAN, Color.DARK_GRAY,
        Color.GRAY, Color.LIGHT_GRAY, Color.PINK, Color.BLACK
    };
    
    /**
     * The data to plot. The data is stored as an array of linked lists.
     */    
    protected LinkedList[] plotData;

    /**
     * Draw the data-series as points.
     */    
    public static final int POINTS = 0;
    /**
     * Draw the data-series as lines.
     */    
    public static final int LINES  = 1;
    /**
     * Draw the data-series as a histogram
     */    
    public static final int HISTOGRAM = 2;
    
    /**
     * Don't draw the data series.
     */    
    public static final int NONE = -1;
        
    /** Creates a new instance of Plot2D */
    public Plot2D() {
        this(0);
    }
    
    /**
     * Create a new instance of Plot2D, with a given number of data sets.
     * @param dataSets the number of data sets in this plot.
     */    
    public Plot2D(int dataSets) {
        minX = minY = -10;
        maxX = maxY = 10;
        
        calculateRanges();
        
        if (dataSets > 0) setDataSets(dataSets); 
    }
    
    /**
     * Set the number of the datasets.
     * @param dataSets the number of data sets present.
     */    
    public void setDataSets(int dataSets) {
        plotData = new LinkedList[dataSets];
        plotTypes = new int[dataSets];
    }
    
    /**
     * Sets the plot type for a given data series.
     * @param dataSeries the series number.
     * @param plotType the plot type to use (see POINTS, LINES, FILLED).
     */    
    public void setPlotType(int dataSeries, int plotType) {
        plotTypes[dataSeries] = plotType;
    }
    
    /**
     * Set the plot colour for a given data series.
     * @param dataSeries the data series.
     * @param plotColor the new plot colour.
     */    
    public void setPlotColor(int dataSeries, Color plotColor) {
        datasetColors[dataSeries % datasetColors.length] = plotColor;
    }
    
    /**
     * Set the data for a given series. Note that this function creates a linked list:
     * <code>
     *    plotData[dataSeries] = new LinkedList();
     *
     *    for (int i=0; i<pd.length; i++) {
     *        plotData[dataSeries].add(new PlotPoint(i, pd[i]));
     *    }
     * </code>
     * @param dataSeries the data series.
     * @param pd a one-dimensional double array specifying the y-coordinates of the data.
     */    
    public void setData(int dataSeries, double[] pd) {
        plotData[dataSeries] = new LinkedList();
        
        for (int i=0; i<pd.length; i++) {
            plotData[dataSeries].add(new PlotPoint(i, pd[i]));
        }
    }
    
    /**
     * Set the data from an array of <code>long</code>s.
     * @param dataSeries the data series to set.
     * @param pd a one-dimensional long array specifying the y-coordinates of the data.
     */    
    public void setData(int dataSeries, long[] pd) {
        plotData[dataSeries] = new LinkedList();
        
        for (int i=0; i<pd.length; i++) {
            plotData[dataSeries].add(new PlotPoint(i, (double)pd[i]));
        }
    }
    
    /**
     * Set the data for a given series. Note that this function creates a linked list:
     * <code>
     *    plotData[dataSeries] = new LinkedList();
     *
     *    for (int i=0; i<pd.length; i++) {
     *        plotData[dataSeries].add(new PlotPoint(pd[i][0], pd[i][1]));
     *    }
     * </code>
     * @param dataSeries the data series.
     * @param pd a two-dimensional array specifying the x and y coordinates of the data.
     */    
    public void setData(int dataSeries, double[][] pd) {
        plotData[dataSeries] = new LinkedList();
        
        for (int i=0; i<pd.length; i++) {
            plotData[dataSeries].add(new PlotPoint(pd[i][0], pd[i][1]));
        }
    }
    
    /**
     * Set the data for a given series. Note the linked list must stored objects of
     * type <code>PlotPoint</code>.
     * @param dataSeries the data series.
     * @param pd the linked list of plot data.
     */    
    public void setData(int dataSeries, LinkedList pd) {
        plotData[dataSeries] = pd;
    }
    
    
    /**
     * Render the plot on a graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        g.setColor(Color.white);
        g.fillRect(0, 0, width, height);
        
        drawAxes(g, width, height);
        
        // null plotData is allowed, just render
        // point-space and axes if necessary.
        if (plotData == null) return;
        
        for (int i=0; i<plotData.length; i++) {
            switch (plotTypes[i]) {
                case NONE: continue;
                case POINTS: renderPoints(g, i, width, height); break;
                case LINES:  renderLines(g, i, width, height); break;
                case HISTOGRAM: renderHistogram(g, i, width, height); break;
            }
        }
    }
    
    /**
     * Render the data as lines.
     * @param g the graphics context.
     * @param dataSeries the data series to render.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    protected void renderLines(Graphics g, int dataSeries, int width, int height) {
        // We need at least two points to plot a line!
        if (plotData[dataSeries].size() < 2) return;
        
        java.util.ListIterator it = plotData[dataSeries].listIterator();
        PlotPoint p1 = (PlotPoint)it.next(), p2;
        PlotPoint t1, t2;
        
        g.setColor(datasetColors[dataSeries % datasetColors.length]);
        
        do {
            p2 = (PlotPoint)it.next();
            
            t1 = translateCoordinate(p1.x, p1.y, width, height);
            t2 = translateCoordinate(p2.x, p2.y, width, height);

            g.drawLine((int)t1.x, (int)t1.y, (int)t2.x, (int)t2.y);
            
            p1 = p2;
        } while (it.hasNext());
        
    }

    /**
     * Render the data as a histogram.
     * @param g the graphics context.
     * @param dataSeries the data series to plot.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    protected void renderHistogram(Graphics g, int dataSeries, int width, int height) {
        if (plotData[dataSeries].size() < 1) return;
        
        PlotPoint p1;
        java.util.ListIterator it = plotData[dataSeries].listIterator();
        
        g.setColor(datasetColors[dataSeries % datasetColors.length]);
        
        //
        // FIXME: This is all fairly inaccurate at the moment...
        //
        PlotPoint t1, t2;
        
        do {
            p1 = (PlotPoint)it.next();
            t1 = translateCoordinate(p1.x, p1.y, width, height);
            t2 = translateCoordinate(p1.x, 0, width, height);
            g.drawLine((int)t1.x, (int)t1.y, (int)t1.x, (int)t2.y);
        } while (it.hasNext());
        
    }
    
    /**
     * Render the data series as points.
     * @param g the graphics context.
     * @param dataSeries the data series to render.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    protected void renderPoints(Graphics g, int dataSeries, int width, int height) {
        // We need at least one points to plot a point!
        if (plotData[dataSeries].size() < 1) return;
        
        PlotPoint p1;
        java.util.ListIterator it = plotData[dataSeries].listIterator();
        
        g.setColor(datasetColors[dataSeries % datasetColors.length]);
        
        do {
            p1 = (PlotPoint)it.next();
            renderPoint(g, p1.x, p1.y, width, height);
        } while (it.hasNext());
    }
    
    /**
     * Render a point.
     * @param g the graphics context.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    protected void renderPoint(Graphics g, double x, double y, int width, int height) {
        PlotPoint point = translateCoordinate(x, y, width, height);
        point.x--; point.y--;
        
        g.fillRect((int)point.x, (int)point.y, 3, 3);
    }

}
