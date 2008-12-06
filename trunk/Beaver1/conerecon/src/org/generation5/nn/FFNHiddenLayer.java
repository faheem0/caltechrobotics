/*
 * FFNHiddenLayer.java
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
 * This class implements a hidden layer for a feedforward network.
 * @author James Matthews
 */
public class FFNHiddenLayer extends FFNLayer {
    /**
     * The number of units/nodes in this layer.
     */    
    protected int numUnits = 0;
    
    /**
     * Creates a new instance of FFNHiddenLayer
     * @param units the number of units in this layer.
     */
    public FFNHiddenLayer(int units) {
        numUnits = units;
    }

    /**
     * Set the activation function.
     * @param activate the activation function.
     */    
    public void setActivation(Activation activate) {
        this.activate = activate;
    }
    
    public int getUnitCount() {
        return numUnits;
    }
}
