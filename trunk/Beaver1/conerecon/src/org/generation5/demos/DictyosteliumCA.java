/*
 * DictyosteliumCA.java
 * Created on 14 July 2004, 20:12
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

package org.generation5.demos;

import java.awt.*;
import org.generation5.*;
import org.generation5.bio.*;
import org.generation5.util.*;

/**
 * This class implements Conway's Life using the CellularAutomata classes and
 * double-buffering for speed.
 *
 * @author James Matthews
 */
public class DictyosteliumCA extends CellularAutomataLayered {
    
    /**
     * An instance of <code>java.util.Random</code>.
     * @see java.util.Random
     */    
    static protected java.util.Random random = new java.util.Random();
    
    /**
     * Create an instance of the Dicty CA.
     */    
    public DictyosteliumCA() {
        this(0,0);
    }
    
    /**
     * Create an instance of the Dicty CA with size information.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public DictyosteliumCA(int size_x, int size_y) {
        super(size_x, size_y, DOUBLE_BUFFERING);

        Gradient gradient = new Gradient();
        gradient.addPoint(Color.black);
        gradient.addPoint(new Color(0,128,0));
        gradient.addPoint(Color.green);
        gradient.addPoint(Color.yellow);
        gradient.addPoint(Color.white);
        gradient.createGradient();
        
        setWorldColors(gradient.getGradient());
    }
    
    /**
     * Advance the world forward one time-step.
     */    
    public void doStep() {
        for (int i=0; i<getSizeX(); i++) {
            for (int j=0; j<getSizeY(); j++) {
                setWorldAtRelative(i, j, -1);
                int avg = 0;
                for (int x=i-1; x<i+2; x++) {
                    for (int y=j-1; y<j+2; y++) {
                        avg += getWorldAt(x,y);
                    }
                }
                
                setWorldAt(i, j, avg / 9);
            }
        }
        
        for(int i = 0; i < getNumCAs(); i++) {
            CAAgent ca = getCA(i);
            setWorldAtRelative(ca.getX(), ca.getY(), 8);

            int dx = random.nextInt(3) - 1;
            int dy = random.nextInt(3) - 1;
            int world = 0;
            int highest = 16;
            int cx = ca.getX(), cy = ca.getY();
            for (int x=-1; x<2; x++) {
                for (int y=-1; y<2; y++) {
                    if (x == 0 && y == 0) continue;
                    if (isCellFree(cx+x, cy+y) == true) {
                        world = getWorldAt(cx+x, cy+y);
                        if (world > highest || ((world == highest && Math.random() < 0.5))) {
                            highest = world;
                            dx = x;
                            dy = y;
                        }
                    }
                }
            }
            
            moveCARelative(i, dx, dy);
        }
        
        flipBuffer();
    }
    
    /**
     * Initialize the world.
     */    
    public void init() {
        clearWorld();
        removeAll();
        
        int num = (int)((double)(caWorld_x * caWorld_y) * 0.05);
        for(int i = 0; i < num; i++) {
            int px = random.nextInt(caWorld_x);
            int py = random.nextInt(caWorld_y);
            addAutomaton(px, py, 1);
        }
        
        setCollisionDetection(true);
        
        flipBuffer();
    }
    
    /**
     * Runs a test program.
     */    
    public static void main(String[] args) {
        DictyosteliumCA dicty = new DictyosteliumCA(640, 480);
         
        dicty.init();
        
        if (args.length == 0) {
            args = new String[3];
            args[0] = "10000";
            args[1] = "100";
            args[2] = "dicty";
        }
        
        iterateCA(dicty, args);
        
    }
}
