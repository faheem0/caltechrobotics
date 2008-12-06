/*
 * LangtonAntCA.java
 * Created on 18 July 2004, 18:45
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
import org.generation5.bio.*;

/**
 * Implements Langton's Ant.
 *
 * @author James Matthews
 */
public class LangtonAntCA extends CellularAutomataLayered {
    /** Ant to move up */
    public final static int UP = 0;
    /** Ant to move right */
    public final static int RIGHT = 1;
    /** Ant to move down */
    public final static int DOWN = 2;
    /** Ant to move left */
    public final static int LEFT = 3;

    /** Default constructor */
    public LangtonAntCA() {
        this(0, 0);
    }

    /**
     * Constructor with additional size information.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public LangtonAntCA(int size_x, int size_y) {
        super(size_x, size_y);
    }

    /**
     * Advance the ants one timestep.
     */    
    public void doStep() {
        for(int i = 0; i < getNumCAs(); i++) {
            CAAgent ca = getCA(i);
            int x = ca.getX();
            int y = ca.getY();
            int d = ca.getState();
            
            switch (d) {
                case UP:    moveCARelative(i, 0, -1); break;
                case RIGHT: moveCARelative(i, 1, 0);  break;
                case DOWN:  moveCARelative(i, 0, 1);  break;
                case LEFT:  moveCARelative(i, -1, 0); break;
            }

            x = ca.getX();
            y = ca.getY();
            int p = getWorldAt(x, y);
            if (p == 1) {
                setWorldAt(x, y, 0);
                ca.setState((d + 1) % 4);
                continue;
            } else if (p == 0) {
                setWorldAt(x, y, 1);
                ca.setState((4 + (d - 1)) % 4);
            }
        }
    }

    /**
     * Initializes the world with one ant in the centre of the world.
     */    
    public void init() {
        removeAll();
        clearWorld();

        setWorldColour(0, Color.white);
        setWorldColour(1, Color.black);
        
        addAutomaton(getSizeX()/2, getSizeY()/2, 1);
    }

    /**
     * @param args arguments to pass to iterateCA.
     * @see CellularAutomata#iterateCA(CellularAutomata, String[])
     */
    public static void main(String args[]) {
        LangtonAntCA ants = new LangtonAntCA(640, 480);
        
        ants.init();
        ants.removeAll();   // remove default ant

        java.util.Random random = new java.util.Random();
        for (int i=0; i<50; i++) {
            ants.addAutomaton(random.nextInt(640), random.nextInt(480),
                              random.nextInt(4));
        }
        
        for (int i=0; i<100; i++) {
            ants.setWorldAt(random.nextInt(640), random.nextInt(480), 1);
        }
        
        iterateCA(ants, args);
    }
}
