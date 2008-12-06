/*
 * ConwaysLifeCA.java
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

import java.awt.Color;
import org.generation5.*;
import org.generation5.bio.*;

/**
 * This class implements Conway's Life using the CellularAutomata classes and
 * double-buffering for speed.
 *
 * @author James Matthews
 */
public class ConwaysLifeCA extends CellularAutomata {
    /**
     * Default constructor
     */    
    public ConwaysLifeCA() {
        this(0, 0);
    }
    
    /**
     * Constructor with size initializors.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public ConwaysLifeCA(int size_x, int size_y) {
        super(size_x, size_y, DOUBLE_BUFFERING);
    }
    
    /**
     * Advance the world one timestep.
     */    
    public void doStep() {
        int neighbours = 0;
        for(int i = 0; i < caWorld_x; i++) {
            for(int j = 0; j < caWorld_y; j++) {
                neighbours += getWorldAt(i - 1, j - 1);
                neighbours += getWorldAt(i, j - 1);
                neighbours += getWorldAt(i + 1, j - 1);
                neighbours += getWorldAt(i - 1, j);
                neighbours += getWorldAt(i + 1, j);
                neighbours += getWorldAt(i - 1, j + 1);
                neighbours += getWorldAt(i, j + 1);
                neighbours += getWorldAt(i + 1, j + 1);
                
                if(getWorldAt(i, j) == 1 && neighbours == 2 || neighbours == 3)
                    setWorldAt(i, j, 1);
                else
                    setWorldAt(i, j, 0);
                
                neighbours = 0;
            }
        }
        
        flipBuffer();
    }
    
    /**
     * Randomly initializes the world.
     */    
    public void init() {
        // Default colours
        setWorldColour(0, Color.white);
        setWorldColour(1, Color.black);
        // Default geometry
        setGeometry(TORODIAL);
        // Create an initial random grid
        for (int i = 0; i < caWorld_x; i++) {
            for (int j = 0; j < caWorld_y; j++) {
                if (Math.random() < 0.2)
                    setWorldAt(i, j, 1);
                else
                    setWorldAt(i, j, 0);
            }
        }
        
        flipBuffer();
    }
    
    /**
     * Standard test function using iterateCA.
     * @see CellularAutomata#iterateCA(CellularAutomata, String[])
     * @param args the arguments to be passed on to iterateCA.
     */    
    public static void main(String args[]) {
        ConwaysLifeCA life = new ConwaysLifeCA(150, 150);
        
        life.init();
        iterateCA(life, args);
    }
}
