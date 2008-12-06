/*
 * CellularAutomataLayered.java
 * Created on 11 July 2004, 11:24
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
import java.awt.Graphics;

/**
 * Expands upon the cellular automata class by adding a separate layer of automata
 * that are independent of the world states. This is useful for classes that
 * require a greater degree of interaction with the world. For example, each cell
 * in Conway's Life simply requires knowledge of its 8 immediate neighbours, and
 * does not move location. Other, more complicated, CAs move about and must keep
 * internal states as well as world states. Termites are a good example of this,
 * where the world and the woodchips are independent of the termites.
 *
 * @author James Matthews
 * @version 0.5
 * @see CellularAutomata
 * @see org.generation5.demos.ConwaysLifeCA
 * @see org.generation5.demos.TermitesCA
 */
public abstract class CellularAutomataLayered extends CellularAutomata {
    
    /**
     * Stores boolean values corresponding to cell occupancy.
     */    
    protected boolean[][] positionTest;
    /**
     * Collision detection can be used for <code>CellularAutomataLayered</code>-derived
     * classes to ensure that two agents do not occupy the same world position.
     * Collision detection is turned off by default.
     */    
    protected boolean collisionDetection = false;
    
    /** Default constructor.
      * @see CellularAutomata#CellularAutomata(int, int)
      */
    public CellularAutomataLayered() {
        this(0, 0);
    }
    
    /**
     * Create an instance of <code>CellularAutomataLayered</code> with world
     * size information. Only two world colours are set, state 0 to black and
     * state 1 to red.
     * @param size_x the world x-size.
     * @param size_y the world y-size.
     */
    public CellularAutomataLayered(int size_x, int size_y) {
        this(size_x, size_y, 0);
    }
    
    /**
     * Create a new instance of <code>CellularAutomataLayered</code> with positional
     * information and optional settings.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     * @param options additional options.
     */    
    public CellularAutomataLayered(int size_x, int size_y, int options) {
        maxCAs = 0;
        numCAs = 0;
        clrStates = new Color[256];
        for(int i = 0; i < 256; i++)
            clrStates[i] = Color.black;
        
        clrStates[0] = Color.black;
        clrStates[1] = Color.red;
        
        if (options == DOUBLE_BUFFERING) {
            bufferSize = 2;
            doubleBuffering = true;
        }
        
        setWorldSize(size_x, size_y);
    }
    
    /**
     * Sets the world size. This function also allocates the maximum number
     * of CA automaton as <code>size_x * size_y</code>.
     * @see CellularAutomata#setWorldSize(int, int)
     * @param size_x the world x-size.
     * @param size_y the world y-size.
     */
    public void setWorldSize(int size_x, int size_y) {
        super.setWorldSize(size_x, size_y);
        
        maxCAs = size_x * size_y;
        caList = new CAAgent[maxCAs];
        
        // positionTest might need to be reinitialized
        setCollisionDetection(collisionDetection);
    }
    
    /**
     * Set or reset collision detection in the world.
     * @param cd turn collision detection on or off.
     */    
    public void setCollisionDetection(boolean cd) {
        collisionDetection = cd;
        
        positionTest = new boolean[caWorld_x][caWorld_y];
    }
    
    /**
     * Returns the collision detection status of this cellular automata world.
     * @return the status of collision detection.
     */    
    public boolean getCollisionDetection() {
        return collisionDetection;
    }
    
    /**
     * Check to see if a world cell is free or not. This function calls
     * <code>translateGeometry</code> before accessing the <code>positionTest</code> array.
     * @param x the x-position to check.
     * @param y the y-position to check.
     * @return a boolean value corresponding to the value in <code>positionTest</code>.
     */    
    protected boolean isCellFree(int x, int y) {
        int gx = translateGeometry(x, 0);
        int gy = translateGeometry(y, 1);
        return !(positionTest[gx][gy]);
    }
    
    /**
     * Add an automaton to the world with state and position information.
     * @param pos_x the x-position of the new automaton
     * @param pos_y the y-position of the new automaton
     * @param state the state of the new automaton
     */
    public void addAutomaton(int pos_x, int pos_y, int state) {
        if (pos_x < 0 || pos_x > caWorld_x || pos_y < 0 || pos_y > caWorld_y) {
            throw new java.lang.IllegalArgumentException("Automata coordinates out of bounds");
        } else {
            caList[numCAs] = new CAAgent(pos_x, pos_y, state);
            numCAs++;
        }
    }
    
    /**
     * Adds an automaton of type <code>CAAgent</code>. This allows you to add
     * <code>CAAgent</code>-derived classes (such as <code>DirectedCAAgent</code>) to the world.
     * <p>
     * Remember to initialize parameters such as positional and state information.
     * @param agent the agent to add.
     * @see CAAgent
     */    
    public void addAutomaton(CAAgent agent) {
        caList[numCAs] = agent;
        numCAs++;
    }
    
    /** Remove all the automata from the world. */
    public void removeAll() {
        numCAs = 0;
    }
    
    /**
     * Move a given automaton to a new position relative to its current. If the current
     * position of the CA is <code>(x,y)</code>, then the new position is
     * <code>(x+dx, y+dy)</code>.
     * @param caIndex the index of the automaton to move.
     * @param dx x-delta position.
     * @param dy y-delta position.
     */    
    public void moveCARelative(int caIndex, int dx, int dy) {
        int cx = caList[caIndex].getX();
        int cy = caList[caIndex].getY();
        int gx = translateGeometry(cx + dx, X_AXIS);
        int gy = translateGeometry(cy + dy, Y_AXIS);
        
        if (collisionDetection == true) {
            if (positionTest[gx][gy] == true) return;
            
            positionTest[cx][cy] = false;
            positionTest[gx][gy] = true;
        }
        
        caList[caIndex].setPosition(gx, gy);
    }
    
    /**
     * Move a given automaton to a new position. If the current
     * position of the CA is <code>(x,y)</code>, then the new position is
     * <code>(new_x, new_y)</code>.
     * @param caIndex the index of the automaton to move.
     * @param new_x the new x-position.
     * @param new_y the new y-position.
     */    
    public void moveCAAbsolute(int caIndex, int new_x, int new_y) {
        int gx = translateGeometry(new_x, 0);
        int gy = translateGeometry(new_y, 1);
        
        if (collisionDetection == true) {
            if (positionTest[gx][gy] == true) return;
            
            positionTest[caList[caIndex].getX()][caList[caIndex].getY()] = false;
            positionTest[gx][gy] = true;
        }

        caList[caIndex].setPosition(gx, gy);
    }
    
    /**
     * Retrieve the corresponding <code>CAAgent</code>, which in turn holds positional,
     * state and other information.
     * @param caIndex the index of the automaton to return.
     * @return the corresponding CAAgent.
     * @see CAAgent
     */    
    public CAAgent getCA(int caIndex) {
        return caList[caIndex];
    }
    
    /**
     * Retrieve the number of automata in the world, this should be equal to the number
     * of calls to <code>addAutomaton</code>.
     * @return the number of cellular automata in the world.
     * @see #addAutomaton(int, int, int)
     */    
    public int getNumCAs() {
        return numCAs;
    }
    
    /**
     * Draws the world state, then each automata.
     * @param graphics the graphics context.
     * @param pw the width of the context.
     * @param ph the height of the context.
     */    
    public void render(Graphics graphics, int pw, int ph) {
        // Render the world state using the super call
        super.render(graphics, pw, ph);
        // Now draw the agents individually
        int cx = getSizeX() * caSize;
        int cy = getSizeY() * caSize;
        int sx = (int)((double)(pw - cx) / 2D);
        int sy = (int)((double)(ph - cy) / 2D);
        for(int i = 0; i < getNumCAs(); i++) {
            CAAgent ca = getCA(i);
            graphics.setColor(clrStates[ca.getState()]);
            graphics.fillRect(sx + ca.getX() * caSize, sy + ca.getY() * caSize, caSize, caSize);
        }
        
    }
    
    /**
     * Sets the colour of the automata states. This is separate to <code>setWorldColour</code>.
     * @param state the state index (0-255).
     * @param colour the colour of the state.
     */    
    public void setStateColour(int state, Color colour) {
        clrStates[state] = colour;
    }
    
    private CAAgent caList[];
    private int maxCAs;
    private int numCAs;
    /**
     * The colours representing the automaton states.
     */    
    protected Color clrStates[];
}
