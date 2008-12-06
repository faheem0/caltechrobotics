/*
 * InfluenceMap.java
 * Created on 13 December 2004, 17:47
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

/**
 * A class encapsulating basic influence mapping functionality.
 * @author James Matthews
 */
public class InfluenceMap {
    /**
     * Select the first maximum value.
     */    
    public static final int FIRST = 0;
    /**
     * Select the last maximum value.
     */    
    public static final int LAST = 1;
    /**
     * Select a random maximum value.
     */    
    public static final int RANDOM = 2;
    
    /**
     * The influence map itself.
     */    
    protected int[][] influenceMap;
    /**
     * The random threshold.
     */    
    protected double threshold = 0.25;
    
    /** Creates a new instance of InfluenceMap */
    public InfluenceMap() {
    }
    
    /**
     * Create a new instance of InfluenceMap with size information.
     * @param width the width of the influence map.
     * @param height the height of the influence map.
     */    
    public InfluenceMap(int width, int height) {
        influenceMap = new int[width][height];
    }
    
    /**
     * Return the width of the influence map.
     * @return the width.
     */    
    public int getWidth() {
        return influenceMap.length;
    }
    
    /**
     * Return the height of the influence map.
     * @return the height.
     */    
    public int getHeight() {
        return influenceMap[0].length;
    }
    
    /**
     * Resets the influence map to zero (calls <code>resetTo(0)</code>)
     */    
    public void reset() {
        resetTo(0);
    }

    /**
     * Resets the influence map to the specified value.
     * @param value the value to set all positions of the influence map.
     */    
    public void resetTo(int value) {
        for (int i=0; i<influenceMap.length; i++) {
            for (int j=0; j<influenceMap[i].length; j++) {
                influenceMap[i][j] = value;
            }
        }
    }
    
    /**
     * Set a point on the influence map to a specified value.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     * @param value the value to set.
     */    
    public void setAt(int x, int y, int value) {
        influenceMap[x][y] = value;
    }
    
    /**
     * Return the value of the influence map at a given coordinate.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     * @return the value of the influence map.
     */    
    public int getAt(int x, int y) {
        return influenceMap[x][y];
    }
    
    /**
     * Increment the influence map by a given increment. This method can also be used
     * to decrement the influence map.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     * @param increment the increment to be added (can be negative).
     */    
    public void incrementAt(int x, int y, int increment) {
        influenceMap[x][y] += increment;
    }
    
    /**
     * Returns the maximum value. Equal values are treated differently according to the
     * type specified: FIRST will return the first maximum value, LAST will return the
     * last, and RANDOM will return a randomly selected maximum position.
     * @param type the selection type.
     * @return the maximum point. This is returned as an <code>int[3]</code> (x-position, y-position,
     * maximum value).
     */    
    public int[] getMaximum(int type) {
        int mx = -1, my = -1, max = Integer.MIN_VALUE, map;
        java.util.Random random = new java.util.Random();
        
        for (int i=0; i<influenceMap.length; i++) {
            for (int j=0; j<influenceMap[i].length; j++) {
                map = influenceMap[i][j];
                if (map >= max) {
                    if (type == FIRST && map == max) 
                        continue;
                    if (type == RANDOM && map == max && random.nextGaussian() > threshold)
                        continue;
                    mx = i;
                    my = j;
                    max = influenceMap[i][j];
                }
            }
        }
        
        return new int[] { mx, my, max };
    }
}
