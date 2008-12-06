/*
 * Flock.java
 * Created on 22 July 2004, 14:15
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

package org.generation5.bio;

import java.awt.Color;
import java.io.*;
import java.util.*;
import org.generation5.*;
import org.generation5.util.*;

/**
 * This class groups {@link org.generation5.bio.FlockingAgent} into one flock.
 *
 * @see FlockingAgent
 * @author James Matthews
 */
public class Flock implements Visualizable, Steppable {
    /**
     * The number of rows in the flocking world (this is equivalent to pixel height).
     */
    protected int rows = 0;
    
    /**
     * The number of columns in the flocking world (this is equivalent to pixel width).
     */    
    protected int  cols = 0;
    /**
     * The number of flocking agents in the flock.
     */    
    protected int numFlockingAgents = 0;
    /**
     * The actual flocking agent array.
     */    
    protected FlockingAgent[] flock;
    
    /**
     * The background of the flock.
     */    
    protected Color clrBackground = Color.lightGray;
    
    /** Creates a new instance of Flock */
    private Flock() {
    }
    
    /**
     * Create a new instance of Flock with size information.
     * @param fa The number of flocking agents to assign.
     * @param cols The number of columns in the flocking world.
     * @param rows The number of rows in the flocking world.
     */    
    public Flock(int fa, int cols, int rows) {
        Random rnd = new Random (0);

        FlockingAgent.initMisc(rnd, rows, cols, 270.0, 90.0, 0.5);
        FlockingAgent.initRadii(80.0, 30.0, 15.0, 40.0);
        FlockingAgent.initWeights(0.2, 0.4, 1.0, 0.8, 0);
        FlockingAgent.initTime(10.0, 0.95);
        
        flock = new FlockingAgent[fa];
        for (int i=0; i<fa; i++) {
            flock[i] = new FlockingAgent();
        }
        
        FlockingAgent.setFlock(flock);
        
        numFlockingAgents = fa;
        this.cols = cols;
        this.rows = rows;
    }
    
    /**
     * Set the number of rows and columns in the world.
     *
     * @param rows Number of rows in this world.
     * @param cols Number of columns in this world.
     */    
    public void setWorldSize(int rows, int cols) {
        this.rows = rows;
        this.cols = cols;
    }
    
    /**
     *
     */    
    public void init() {
        for (int i=0; i<flock.length; i++) {
            flock[i] = new FlockingAgent();
        }
    }
    
    /**
     * Advance the boids world by one time-step.
     */    
    public void doStep() {
        for (int b=0; b<numFlockingAgents; b++)
            flock[b].computeNewHeading(b);
        for (int b=0; b<numFlockingAgents; b++)
            flock[b].update();
    }
    
    /**
     * A test function that writes the 640x480 boids world once every 10 
     * time-steps for 250 iterations.
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Flock flock = new Flock(250, 640, 480);
        
        for (int i=0; i<1000; i++) {
            if ((i % 5) == 0) 
                flock.writeImage("boids" + i + ".png", 640, 480);
            flock.doStep();
        }
    }
    
    /**
     * Draw the boids world. The boids are represented as arrows showing their direction.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        // 
        int sx = (int)((width  - cols) / 2.0);
        int sy = (int)((height - rows) / 2.0);
        // 
        g.setColor(clrBackground);
        g.fillRect(0,0,width,height);
        g.setColor(Color.BLACK);
        g.fillRect(sx,sy,cols,rows);
        g.setColor(Color.WHITE);
        g.setClip(sx, sy, cols, rows);
        
        for (int b=0; b<numFlockingAgents; b++) {
            flock[b].render(g, sx, sy);
        }
    }
    
    /**
     * Write an image of the boids world.
     * @param s the filename.
     * @param width the width of the image.
     * @param height the height of the image.
     */    
    public void writeImage(String s, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch (IOException e) {
            System.err.println("Error writing image.");
        }
    }
    
    /**
     * Reset the flock (call <code>init</code>).
     * @see #init
     */    
    public void reset() {
        init();
    }
    
    /**
     * Set the background color.
     * @param clr the background color.
     */    
    public void setBackgroundColor(Color clr) {
        clrBackground = clr;
    }
    
    /**
     * Retrieve the background color.
     * @return the background color in use.
     */    
    public Color getBackgroundColor() {
        return clrBackground;
    }
}
