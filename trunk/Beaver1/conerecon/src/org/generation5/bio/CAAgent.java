/*
 * CAAgent.java
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

/**
 * Implements a simple CA agent to be used with {@link org.generation5.bio.CellularAutomataLayered},
 * where the CA agent is an embodied entity within the CA world.
 *
 * @author James Matthews
 * @version 0.5
 */
public class CAAgent {
    /** 
     * Default constructor. Positional and state variables are initialized to -1.
     */
    public CAAgent() {
        this(-1, -1, -1);
    }

    /**
     * Creates a CA2DInfo instance with positional information.
     *
     * @param x X-position.
     * @param y Y-position.
     */    
    public CAAgent(int x, int y) {
        this(x, y, -1);
    }

    /**
     * Creates a CA2DInfo instance with positional and state information.
     *
     * @param x X-position.
     * @param y Y-position.
     * @param s cell state.
     */    
    public CAAgent(int x, int y, int s) {
        pos_x = x;
        pos_y = y;
        state = s;
    }

    /**
     * Set the position of this CA.
     * @param x X-position to set.
     * @param y Y-position to set.
     */    
    public void setPosition(int x, int y) {
        pos_x = x;
        pos_y = y;
    }

    /**
     * Set the state of this CA.
     * @param s this cell state.
     */    
    public void setState(int s) {
        state = s;
    }

    /**
     * Set only the X-position.
     * @param x this cell's new X-position.
     */    
    public void setX(int x) {
        pos_x = x;
    }

    /**
     * Set only the Y-position.
     * @param y this cell's new Y-position.
     */    
    public void setY(int y) {
        pos_y = y;
    }

    /**
     * 
     * @return retrieve the X-position of the cell.
     */    
    public int getX() {
        return pos_x;
    }

    /**
     *
     * @return retrieve the Y-position of the cell.
     */    
    public int getY() {
        return pos_y;
    }

    /**
     *
     * @return retrieve the state of the cell.
     */    
    public int getState() {
        return state;
    }

    /** An integer to be used at programmer's discretion. */    
    public int dataInteger;
    /**
     * The x-position.
     */    
    protected int pos_x;
    /**
     * The y-position.
     */    
    protected int pos_y;
    /**
     * The agent state.
     */    
    protected int state;
}
