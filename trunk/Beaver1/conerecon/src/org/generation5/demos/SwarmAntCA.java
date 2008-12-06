/*
 * SwarmAntCA.java
 * Created on 11 August 2004, 19:40
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
 * NOTE: THIS CODE IS EXTREMELY UNFINISHED!! :)
 */

package org.generation5.demos;

import java.awt.*;
import org.generation5.bio.*;
import org.generation5.util.*;

/**
 *
 * @author  James Matthews
 */
public class SwarmAntCA extends CellularAutomataLayered {

    protected int nestX = 60;
    protected int nestY = 60;
    protected int[][] goals = new int[3][3];
    protected int iterations = 0;
    
    protected int nestSize = 10; 
    protected int foodSize = 20;
    
    /** Creates a new instance of SwarmAntCA */
    public SwarmAntCA() {
        this(0,0);
    }
    
    protected SwarmAntCA(int size_x, int size_y) {
        super(size_x, size_y, DOUBLE_BUFFERING);
                
        Gradient gradient = new Gradient();
        gradient.addPoint(Color.black);
        gradient.addPoint(new Color(80,0,100));
        gradient.addPoint(Color.red);
        gradient.addPoint(Color.yellow);
        gradient.addPoint(Color.white);
        gradient.createGradient();
        
        setStateColour(1, Color.lightGray);
        setStateColour(2, Color.yellow);
        setWorldColors(gradient.getGradient());
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
    }
    
    public void doStep() {
        if (iterations % 3 == 0) {
            for (int i=0; i<getSizeX(); i++) {
                for (int j=0; j<getSizeY(); j++) {
                    int avg = 0;
                    for (int x=i-1; x<i+2; x++) {
                        for (int y=j-1; y<j+2; y++) {
                            avg += getWorldAt(x,y);
                        }
                    }

                    setWorldAt(i, j, avg / 9);
                }
            }
        }
        
        if (iterations % 25 == 0 && getNumCAs() < 50) {
            addAutomaton(new DirectedCAAgent(nestX, nestY, 1, (int)(Math.random() * 8)));
        }
        
        for(int i = 0; i < getNumCAs(); i++) {
            DirectedCAAgent ca = (DirectedCAAgent)getCA(i);
            if (ca.dataInteger == 0) {
                int world, best = 0, dx, dy;
                int cx = ca.getX(), cy = ca.getY();
                int dir = ca.getDirection();
                for (int x=-1; x<2; x++) {
                    for (int y=-1; y<2; y++) {
                        if (x == 0 && y == 0) continue;
                        if (Math.abs(dir - DirectedCAAgent.getDirection(x,y)) < 2) {
                            world = getWorldAt(cx+x, cy+y);
                            if (world > best || ((world == best && Math.random() < 0.5))) {
                                best = world;
                                ca.setDirection(DirectedCAAgent.getDirection(x,y));
                            }
                        }
                    }
                }

                if (best < 5) {
                    if (Math.random() < 0.0625) ca.moveLeft();
                    else if (Math.random() < 0.125) ca.moveRight();
                }
                
                moveCARelative(i, ca.getDX(), ca.getDY());
                
                int fs = atFoodSource(ca);
                if (fs != -1) {
                    ca.dataInteger = 255;
                    ca.setState(2);
                    goals[fs][2] -= 5;
                    ca.reverse();
                }
            } else if (ca.dataInteger > 0) {
                int p1 = ca.dataInteger;
                int p2 = p1 / 2;
                int p3 = p1 / 4;
                int cx = ca.getX();
                int cy = ca.getY();
                
                setWorldAtRelative(cx, cy, p1);
                setWorldAtRelative(cx-1, cy-1, p3);
                setWorldAtRelative(cx, cy-1, p2);
                setWorldAtRelative(cx+1, cy-1, p3);
                setWorldAtRelative(cx-1, cy, p2);
                setWorldAtRelative(cx+1, cy, p2);
                setWorldAtRelative(cx-1, cy+1, p3);
                setWorldAtRelative(cx, cy+1, p2);
                setWorldAtRelative(cx+1, cy+1, p3);
                

                int dx = nestX - cx;
                int dy = nestY - cy;
                if (dx < 0) ca.setDX(-1);
                if (dx == 0) ca.setDX(0);
                if (dx > 0) ca.setDX(1);

                if (dy < 0) ca.setDY(-1);
                if (dy == 0) ca.setDY(0);
                if (dy > 0) ca.setDY(1);

                double dc = Math.random();
                if (dc < 0.05)     ca.moveLeft();
                else if (dc < 0.1) ca.moveRight();
                
                moveCARelative(i, ca.getDX(), ca.getDY());
                
                if (atNest(ca)) {
                    ca.dataInteger = 0;
                    ca.reverse();
                    ca.setState(1);
                } else {
                    if (ca.dataInteger > 9) ca.dataInteger -= 5;
                    else ca.dataInteger = 5;
                }
            }
        }
        
        iterations++;
        
        flipBuffer();
    }
    
    protected boolean atNest(DirectedCAAgent ca) {
        java.awt.geom.Ellipse2D.Double nest = new java.awt.geom.Ellipse2D.Double();
        nest.x = nestX - (nestSize / 2);
        nest.y = nestY - (nestSize / 2);
        nest.width = nestSize;
        nest.height = nest.width;
        
        return nest.contains(ca.getX(), ca.getY());
    }
    
    protected int atFoodSource(DirectedCAAgent ca) {
        java.awt.geom.Ellipse2D.Double foodSource = new java.awt.geom.Ellipse2D.Double();
        
        for (int i=0; i<goals.length; i++) {
            foodSource.x = goals[i][0] - (goals[i][2] / 10);
            foodSource.y = goals[i][1] - (goals[i][2] / 10);
            foodSource.width = goals[i][2] / 5;
            foodSource.height = foodSource.width;
            
            if (foodSource.contains(ca.getX(), ca.getY())) {
                return i;
            }
        }
        
        return -1;
    }
    
    public void init() {
        clearWorld();
        removeAll();
        
        iterations = 0;
        
        nestX = caWorld_x / 2;
        nestY = caWorld_y / 2;
        
        addAutomaton(new DirectedCAAgent(nestX, nestY, 1, (int)(Math.random() * 8)));
        
        goals[0][0] = 15;
        goals[0][1] = 15;
        goals[0][2] = 100;
        
        goals[1][0] = 50;
        goals[1][1] = 15;
        goals[1][2] = 100;

        goals[2][0] = 60;
        goals[2][1] = 60;
        goals[2][2] = 100;
        
        flipBuffer();
    }
    
    public void render(java.awt.Graphics graphics, int pw, int ph) {        
        super.render(graphics, pw, ph);
        
        int cx = getSizeX() * caSize;
        int cy = getSizeY() * caSize;
        int sx = (int)((double)(pw - cx) / 2.0);
        int sy = (int)((double)(ph - cy) / 2.0);
        
        int nest = nestSize * caSize;
        int n2 = nest / 2;
        int f2 = 0;
        
        graphics.setColor(java.awt.Color.darkGray);
        graphics.fillOval(sx+(nestX*caSize) - n2, sy+(nestY*caSize) - n2, nest, nest);
        
        graphics.setColor(java.awt.Color.RED);
        for (int i=0; i<goals.length; i++) {
            f2 = (goals[i][2] * caSize) / 10;
            graphics.fillOval(sx+(goals[i][0]*caSize) - f2, 
                              sy+(goals[i][1]*caSize) - f2, 
                              goals[i][2] / 5 * caSize,
                              goals[i][2] / 5 * caSize);
        }
    }
    
    protected class SwarmAgent extends DirectedCAAgent {
        SwarmAgent(int x, int y, int state, int direction) {
            super(x, y, state, direction);
        }
        
//        protected goal
    }
}
