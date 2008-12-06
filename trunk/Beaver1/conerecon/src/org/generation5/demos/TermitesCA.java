/*
 * TermitesCA.java
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
 * Implements the termites algorithm, randomly sorting a collection
 * of woodchips.
 * @author James Matthews
 */
public class TermitesCA extends CellularAutomataLayered {
    
    /**
     * Default constructor.
     */    
    public TermitesCA() {
        this(0, 0);
    }
    
    /**
     * Create an instance with additional size information.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public TermitesCA(int size_x, int size_y) {
        super(size_x, size_y);
        caPercentage = 0.01;
        wcPercentage = 1.0 / 3.0;
        
        dirArray = new int[8][2];
        dirArray[0][0] = 0;
        dirArray[0][1] = -1;
        dirArray[1][0] = 1;
        dirArray[1][1] = -1;
        dirArray[2][0] = 1;
        dirArray[2][1] = 0;
        dirArray[3][0] = 1;
        dirArray[3][1] = 1;
        dirArray[4][0] = 0;
        dirArray[4][1] = 1;
        dirArray[5][0] = -1;
        dirArray[5][1] = 1;
        dirArray[6][0] = -1;
        dirArray[6][1] = 0;
        dirArray[7][0] = -1;
        dirArray[7][1] = -1;
    }
    
    /**
     * Set the percentages of cellular automata and woodchips.
     * @param cap the cellular automata percentage.
     * @param wcp the woodchip percentage.
     */    
    public void setPercentages(double cap, double wcp) {
        caPercentage = cap;
        wcPercentage = wcp;
    }
    
    /**
     * Initializes the world.
     */    
    public void init() {
        clearWorld();
        removeAll();
        
        double rand = 0.0D;
        for(int i = 0; i < caWorld_x; i++){
            for(int j = 0; j < caWorld_y; j++) {
                rand = Math.random();
                if(rand < wcPercentage)
                    setWorldAt(i, j, 1);
            }
        }
        
        int num = (int)((double)(caWorld_x * caWorld_y) * caPercentage);
        for(int i = 0; i < num; i++) {
            int px = (int)(Math.random() * (double)caWorld_x);
            int py = (int)(Math.random() * (double)caWorld_y);
            addAutomaton(px, py, 1);
            getCA(i).dataInteger = (int)(Math.random() * 8D);
        }

        // Set default colours (green background, 
        // brown chips and yellow termites)
        setWorldColour(0, new Color(0, 128, 0));
        setWorldColour(1, new Color(128, 64, 0));
        setStateColour(1, Color.yellow);
        setStateColour(2, Color.yellow);
    }
    
    /**
     * Advances the world by one timestep.
     */    
    public void doStep() {
        // dataInteger used to control direction, the
        // CAAgent:state used to determine whether termite has picked up.
        
        int dx = 0;
        int dy = 0;
        int piece = -1;
        int nc = getNumCAs();
        boolean bFound = false;
        for(int c = 0; c < nc; c++) {
            CAAgent ca = getCA(c);
            int x = ca.getX();
            int y = ca.getY();
            int di = ca.dataInteger;
            dx = dirArray[di][0];
            dy = dirArray[di][1];
            piece = getWorldAt(x + dx, y + dy);
            if(piece == 1) {
                if(ca.getState() == 1) {
                    setWorldAt(x + dx, y + dy, 0);
                    ca.setState(2);
                } else {
                    if(ca.getState() == 2 && getWorldAt(x, y) != 1) {
                        setWorldAt(x, y, 1);
                        ca.setState(1);
                    }
                    ca.dataInteger = (ca.dataInteger + 4) % 8;
                }
            } else {
                moveCARelative(c, dx, dy);
                ca.dataInteger = (ca.dataInteger + ((int)(Math.random() * 3D) - 1) + 8) % 8;
            }
        }        
    }
    
    /**
     *
     * @param args command-line arguments to pass to iterateCA.
     * @see CellularAutomata#iterateCA(CellularAutomata, String[])
     */    
    public static void main(String args[]) {
        TermitesCA termites = new TermitesCA();
        termites.setWorldSize(320, 240);
        termites.setPercentages(0.02D, 0.25D);
        termites.init();
        iterateCA(termites, args);
    }
    
    /**
     * The percentage of the cellular automata within the world.
     */    
    protected double caPercentage;
    /**
     * The percentage of woodchips within the world.
     */    
    protected double wcPercentage;
    private int dirArray[][];
}
