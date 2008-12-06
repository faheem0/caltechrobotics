/*
 * AStarMap.java
 * Created on 22 October 2004, 15:06
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

package org.generation5.ai;

import java.util.*;
import java.awt.image.*;
import org.generation5.util.*;

/**
 * <code>AStarMap</code> is simply derived from <code>StandardMap2D</code> to provide
 * further functionality to visualize the A* algorithm. It displays the map, start/goal
 * positions, the best route as well as open and closed lists.
 * @author James Matthews
 */
public class AStarMap extends StandardMap2D {
    
    /**
     * Start x-position.
     */
    protected int sx = -1;
    
    /**
     * Start y-position.
     */    
    protected int  sy = -1;
    
    /**
     * Goal x-position.
     */
    protected int gx = -1;
    
    /**
     * Goal y-position.
     */    
    protected int  gy = -1;
    /**
     * The open list gradient (red).
     */    
    protected Gradient openGradient = new Gradient();
    /**
     * The closed list gradient (blue).
     */    
    protected Gradient closedGradient = new Gradient();
    /**
     * The pathfinder (used for drawing the routes).
     */    
    protected AStarPathfinder aStar;
    
    /** Creates a new instance of AStarMap */
    public AStarMap() {
        this(0, 0);
    }
    
    /**
     * Creates a new instance with dimensional information.
     * @param width the width of the map.
     * @param height the height of the map.
     */    
    public AStarMap(int width, int height) {
        super(width, height);
        // Open gradient
        openGradient.addPoint(new java.awt.Color(95, 0, 0));
        openGradient.addPoint(new java.awt.Color(250,215,215));
        openGradient.createGradient();
        // Closed gradient
        closedGradient.addPoint(new java.awt.Color(25,65,120));
        closedGradient.addPoint(new java.awt.Color(185,215,255));
        closedGradient.createGradient();
    }

    /**
     * Creates a new instance from a BufferedImage.
     * @param img the image to be used as the map values.
     */    
    public AStarMap(BufferedImage img) {
        super(img.getWidth(), img.getHeight());
        
        BufferedImage sourceImage = img;
        Raster sourceRaster = img.getRaster();

        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                setMapAt(i, j, sourceRaster.getSample(i, j, 0));
            }
        }
        // Open gradient
        openGradient.addPoint(new java.awt.Color(95, 0, 0));
        openGradient.addPoint(new java.awt.Color(250,215,215));
        openGradient.createGradient();
        // Closed gradient
        closedGradient.addPoint(new java.awt.Color(25,65,120));
        closedGradient.addPoint(new java.awt.Color(185,215,255));
        closedGradient.createGradient();
    }
    
    /**
     * Set the pathfinder to display.
     * @param as the pathfinder to display.
     */    
    public void setPathfinder(AStarPathfinder as) {
        aStar = as;
    }
    
    /**
     * Return the pathfinder being used.
     * @return the pathfinder.
     */    
    public AStarPathfinder getPathfinder() {
        return aStar;
    }
    
    /**
     * Render the map.
     * @see org.generation5.util.StandardMap2D#render(java.awt.Graphics, int, int)
     * @param g the graphics context.
     * @param ww the content width.
     * @param hh the context height.
     */    
    public void render(java.awt.Graphics g, int ww, int hh) {
        // Render the map
        super.render(g, ww, hh);

        // Render the start and goal points
        int cx = width * renderSize;
        int cy = height * renderSize;
        // sx/sy are the starting points for the CA world
        // centred within the the graphics context.
        int ssx = (int)((double)(ww - cx) / 2.0);
        int ssy = (int)((double)(hh - cy) / 2.0);

        // Firstly, render the open/closed lists
        int i, j;
        AStarPathfinder.AStarNode node;
        ListIterator open = aStar.getOpen().listIterator();
        ListIterator closed = aStar.getClosed().listIterator();
        
        while (open.hasNext()) {
            node = (AStarPathfinder.AStarNode)open.next();
            i = node.getX();
            j = node.getY();
            g.setColor(openGradient.getColour(mapValues[i][j]));
            g.fillRect(i*renderSize+ssx, j*renderSize+ssy, renderSize, renderSize);
        }
        
        while (closed.hasNext()) {
            node = (AStarPathfinder.AStarNode)closed.next();
            i = node.getX();
            j = node.getY();
            g.setColor(closedGradient.getColour(mapValues[i][j]));
            g.fillRect(i*renderSize+ssx, j*renderSize+ssy, renderSize, renderSize);
        }
        
        
        AStarPathfinder.AStarNode start = aStar.getStart();
        AStarPathfinder.AStarNode goal = aStar.getGoal();
        
        sx = start.getX(); sy = start.getY();
        gx = goal.getX();  gy = goal.getY();
                
        g.setColor(java.awt.Color.GREEN);
        g.fillOval(ssx+sx*renderSize-2, ssy+sy*renderSize-2, 5, 5);
        g.setColor(java.awt.Color.RED);
        g.fillOval(ssx+gx*renderSize-2, ssy+gy*renderSize-2, 5, 5);
        g.setColor(java.awt.Color.BLACK);
        g.drawRect(ssx, ssy, width * renderSize, height * renderSize);

        if (aStar.getBestNode() != null) {
            g.setColor(new java.awt.Color(0, 0, 128));
            AStarPathfinder.AStarNode first = aStar.getBestNode();
            AStarPathfinder.AStarNode next = first.getParent(), temp;
            
            while (next != null) {
                g.drawLine(ssx+first.getX()*renderSize, ssy+first.getY()*renderSize,
                           ssx+next.getX()*renderSize,  ssy+next.getY()*renderSize);
                
                first = next;
                next = next.getParent();
            }
        }
    }
}
