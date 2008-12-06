/*
 * DirectedCAAgent.java
 * Created on 11 August 2004, 20:26
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
 * An extension of <code>CAAgent</code> that adds a directional functionality. A
 * directed agent can move left or right, allowing for agents with more realistic
 * movement.
 * @author James Matthews
 */
public class DirectedCAAgent extends CAAgent {
    /** Direction array, from top in a clockwise direction. */
    static final int[][] directionArray = {
        {  0, -1 }, // up
        {  1, -1 }, // up-right
        {  1,  0 }, // right
        {  1,  1 }, // down-right
        {  0,  1 }, // bottom
        { -1,  1 }, // bottom-left
        { -1,  0 }, // left
        { -1, -1 }  // top-left
    };
    
    /**
     *
     */    
    static public final int TOP = 0;
    static public final int TOP_RIGHT = 1;
    static public final int RIGHT = 2;
    static public final int BOTTOM_RIGHT = 3;
    static public final int BOTTOM = 4;
    static public final int BOTTOM_LEFT = 5;
    static public final int LEFT = 6;
    static public final int TOP_LEFT = 7;

    protected int direction = TOP;
    
    /** Creates a new instance of DirectedCAAgent */
    public DirectedCAAgent() {
        this(0, 0, 0);
    }
    
    public DirectedCAAgent(int x, int y, int state) {
        this(x, y, state, TOP);
    }
    
    public DirectedCAAgent(int x, int y, int state, int direction) {
        super(x, y, state);
        
        this.direction = direction;
    }

    public void reverse() {
        direction = (direction + 4) % 8;
    }
    
    public void moveLeft() {
        direction = (direction + 7) % 8;
    }
    
    public void moveRight() {
        direction = (direction + 1) % 8;
    }
    
    public void move(CellularAutomataLayered world) {
        int gx = world.translateGeometry(pos_x + directionArray[direction][0], 0);
        int gy = world.translateGeometry(pos_y + directionArray[direction][1], 1);
        
        if (world.getCollisionDetection()) {
/*            if (positionTest[gx][gy] == true) return;
            
            positionTest[cx][cy] = false;
            positionTest[gx][gy] = true;*/
        }
        
        setPosition(gx, gy);
    }
    
    public int getDX() {
        return directionArray[direction][0];
    }
    
    public void setDX(int dx) {
        direction = getDirection(dx, directionArray[direction][1]);
    }
    
    public int getDY() {
        return directionArray[direction][1];
    }
    
    public void setDY(int dy) {
        direction = getDirection(directionArray[direction][0], dy);
    }
    
    public int getDirection() {
        return direction;
    }
    
    public void setDirection(int dir) {
        direction = dir;
    }
    
    public static int getDirection(int dx, int dy) {
        for (int i=0; i<directionArray.length; i++) {
            if (directionArray[i][0] == dx && directionArray[i][1] == dy)
                return i;
        }

        // if dx and dy == 0, return random direction.
        return (int)(Math.random() * 8);
    }
}
