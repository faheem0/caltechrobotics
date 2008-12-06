/*
 * WireWorldCA.java
 * Created on 19 November 2004, 15:12
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

import org.generation5.bio.*;

/**
 * This implements the simple cellular automata, Wire World. Wire World is an
 * excellent sample CA since you can easily demonstrate its universal computing
 * properties.
 * @author James Matthews
 */
public class WireWorldCA extends CellularAutomata {
    
    /** Creates a new instance of WireWorldCA */
    public WireWorldCA() {
        this(0, 0);
    }
    
    /**
     * Creates a new instance of WireWorldCA with dimensional information.
     * @param size_x the x-size of the CA world.
     * @param size_y the y-size of the CA world.
     */    
    public WireWorldCA(int size_x, int size_y) {
        super(size_x, size_y, DOUBLE_BUFFERING);
    }
    
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        WireWorldCA wireWorld = new WireWorldCA(100, 100);
        
        wireWorld.init();
        wireWorld.setWorldAtEx(5, 5, "0,0,0,0,0,3,3;1,3,3,3,3,0,0,3;0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3;1,3,3,3,3,0,0,3;0,0,0,0,0,3,3");        
        wireWorld.setWorldAtEx(5, 20, "0,0,0,0,0,0,0,0,0,0,3,3;0,0,0,0,0,0,0,0,0,3,0,0,3;1,3,3,3,3,3,3,3,3,0,0,3,3,3,3;0,0,0,0,0,0,0,0,0,0,0,3,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3;1,3,3,3,3,3,3,3,3,0,0,3,3,3,3;0,0,0,0,0,0,0,0,0,3,0,0,3;0,0,0,0,0,0,0,0,0,0,3,3");
        wireWorld.setWorldAtEx(5, 40, "0,0,0,0,0,0,0,0,0,0,3,3;0,0,0,0,0,0,0,0,0,3,0,0,3;1,3,3,3,3,3,3,3,3,0,0,3,3,3,3;0,0,0,0,0,0,0,0,0,0,0,3,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3;3,3,3,3,3,3,3,3,3,0,0,3,3,3,3;0,0,0,0,0,0,0,0,0,3,0,0,3;0,0,0,0,0,0,0,0,0,0,3,3");
        
        wireWorld.flipBuffer();
        
        iterateCA(wireWorld, args);
    }
    
    /**
     * Iterate the CA one time-step.
     */    
    public void doStep() {
        //
        int caAt = 0;
        int u = 0;
        for(int j=0; j<caWorld_y; j++) {
            for(int i=0; i<caWorld_x; i++) {
                caAt = getWorldAt(i, j);
                
                if (caAt == 1)
                    setWorldAt(i,j, 2);
                else if (caAt == 2)
                    setWorldAt(i,j, 3);
                else if (caAt == 3) {
                    u = 0;
                    u += (getWorldAt(i - 1, j - 1) == 1) ? 1  : 0;
                    u += (getWorldAt(i, j - 1) == 1) ? 1  : 0;
                    u += (getWorldAt(i + 1, j - 1) == 1) ? 1  : 0;
                    u += (getWorldAt(i - 1, j) == 1) ? 1  : 0;
                    u += (getWorldAt(i + 1, j) == 1) ? 1  : 0;
                    u += (getWorldAt(i - 1, j + 1) == 1) ? 1  : 0;
                    u += (getWorldAt(i, j + 1) == 1) ? 1  : 0;
                    u += (getWorldAt(i + 1, j + 1) == 1) ? 1  : 0;
                    
                    if (u == 1 || u == 2)
                        setWorldAt(i,j,1);
                    else
                        setWorldAt(i,j,3);
                }
            }
        }
        
        flipBuffer();
    }
    
    /**
     * Initialize WireWorld.
     */    
    public void init() {
        clearWorld();
        
        setWorldColour(0, java.awt.Color.WHITE);
        setWorldColour(1, java.awt.Color.YELLOW);
        setWorldColour(2, java.awt.Color.RED);
        setWorldColour(3, java.awt.Color.BLACK);
    }
}
