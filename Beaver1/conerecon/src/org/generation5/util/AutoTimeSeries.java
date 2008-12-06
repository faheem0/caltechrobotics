/*
 * TimeSeries.java
 * Created on 14 November 2004, 13:40
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

import java.awt.image.*;

import org.generation5.*;

/**
 * This class extends <code>TimeSeries</code> by automatically creating a time-series
 * across an interval period, or given at step numbers. For example, if you want
 * to create a time-series image of a CA world every 100 iterations, or perhaps at
 * steps 1, 10, 100, 1000 and 10,000.
 *
 * Note that the steppable object and the visualizable object can be separate,
 * allowing for more complex time-series images.
 * @author James Matthews
 */
public class AutoTimeSeries extends TimeSeries implements Visualizable {
    private int snapshotInterval = -1;
    private int[] snapshots;
    private int assignedSnapshots = 0;
    /**
     * Determies whether the time-series is to be automatically generated when calls to
     * <tt>render</tt> are called. It is set as true by default.
     */    
    protected boolean autoGenerate = true;
    /**
     * The steppable object.
     */    
    protected Steppable steppable;
    /**
     * The visualizable object.
     */    
    protected Visualizable visualizable;
    
    /** Creates a new instance of TimeSeries */
    public AutoTimeSeries() {
    }
    
    /**
     * Set the visualizable object.
     * @param visualizable the visualizable object.
     */    
    public void setVisualizable(Visualizable visualizable) {
        this.visualizable = visualizable;
    }
    
    /**
     * Set the steppable object.
     * @param steppable the steppable object.
     */    
    public void setSteppable(Steppable steppable) {
        this.steppable = steppable;
    }
    
    /**
     * Set a snapshot at a particular timestep. Note that calls to <code>setSnapshotAt</code>
     * should be in ascending order; anything else will cause undefined behaviour.
     * This method <i>cannot</i> be used in conjunction with <code>setSnapshotInterval</code>.
     * @param iteration the step number to take a snapshot at.
     */    
    public void setSnapshotAt(int iteration) {
        if (snapshots == null)
            snapshots = new int[rows * columns];        
        if (assignedSnapshots == rows * columns)
            throw new IllegalArgumentException("too many snapshots assigned.");
        
        snapshots[assignedSnapshots++] = iteration;
    }
    
    /**
     * Set an interval at which to take a snapshot. This method <i>cannot</i> be used
     * in conjunction with <code>setSnapshotAt</code>.
     * @param interval the snapshot interval.
     */    
    public void setSnapshotInterval(int interval) {
        if (interval == 0)
            throw new IllegalArgumentException("interval cannot be zero!");
        
        snapshotInterval = interval;
    }
    
    /**
     * Set whether the time-series is auto-generated or not.
     * @param autoGen set whether the time-series is auto-generated or not.
     */    
    public void setAutoGenerate(boolean autoGen) {
        autoGenerate = autoGen;
    }
    
    /**
     * Reset the time-series options. This resets all traits apart from the
     * visualizable/steppable objects.
     */    
    public void reset() {
        snapshotInterval = -1;
        assignedSnapshots = 0;
        snapshots = null;
        rows = -1;
        columns = -1;
        drawFlags = BORDERS | ANTIALIAS;
    }
    
    /**
     * This method generates the time-series snapshots. By default, the class automatically
     * generates the necessary snapshots when <code>render</code> is called. Under some
     * circumstances, you want to generate the snapshots separately to a call to
     * <code>render</code> or <code>writeImage</code>.
     * @param width the overall width.
     * @param height the overall height.
     * @see #setAutoGenerate(boolean)
     */    
    public void generateSnapshots(int width, int height) {
        int csx = width / columns;
        int csy = height / rows;
        
        // Auto generate all the snapshots
        if (snapshotInterval != -1) {
            int cell = 0;
            int totalIterations = snapshotInterval * rows * columns;
            for (int i=0; i<totalIterations; i++) {
                if (i % snapshotInterval == 0) 
                    addSnapshot(visualizable, csx, csy);

                steppable.doStep();
            }
        } else {
            int cell = 0;
            int totalIterations = snapshots[assignedSnapshots-1]+1;
            for (int i=0; i<totalIterations; i++) {
                if (i == snapshots[cell]) 
                    addSnapshot(visualizable, csx, csy);

                steppable.doStep();
            }            
        }        
    }
    
    /**
     * Render the time-series on a graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        if (autoGenerate) generateSnapshots(width, height);
        
        super.render(g, width, height);
    }
    
    /**
     * Write the series to an image.
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
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        AutoTimeSeries timeSeries = new AutoTimeSeries();
        
        org.generation5.demos.DictyosteliumCA dictyCA =
            new org.generation5.demos.DictyosteliumCA(200, 200);
        dictyCA.init();
        dictyCA.setCASize(1);
        
        timeSeries.setSteppable(dictyCA);
        timeSeries.setVisualizable(dictyCA);
        timeSeries.setDimensions(4, 4);
        timeSeries.setSnapshotInterval(625);
        
        timeSeries.writeImage("timeSeriesInterval.png", 800, 800);
    }
}
