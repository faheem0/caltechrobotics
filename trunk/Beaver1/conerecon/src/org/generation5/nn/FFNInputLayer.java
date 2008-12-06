/*
 * FFNInputLayer.java
 * Created on 22 November 2004, 21:05
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

package org.generation5.nn;

/**
 * This class implements the input layer for the feedforward network.
 * @author James Matthews
 */
public class FFNInputLayer extends FFNLayer {
    /**
     * The number of units in this layer.
     */    
    protected int numUnits = 0;
    
    /**
     * Creates a new instance of FFNInputLayer
     * @param units the number of units in this input layer.
     */
    public FFNInputLayer(int units) {
	numUnits = units;
    }
    
    public int getUnitCount() {
        return numUnits;
    }
    
}
