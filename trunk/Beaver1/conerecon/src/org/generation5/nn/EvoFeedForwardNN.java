/*
 * EvoFeedForwardNN.java
 * Created on 23 November 2004, 16:33
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

import org.generation5.bio.*;

/**
 * This class implements an evolutionary feedforward network.
 * @author James Matthews
 */
public class EvoFeedForwardNN extends FeedForwardNN implements Evolvable {
    
    /**
     * The fitness value for this feedforward network.
     */    
    protected double fitnessValue = 0.0;
    
    /**
     * The input test data.
     */    
    protected double[][] inputData;
    
    /**
     * Creates a new instance of EvoFeedForwardNN
     * @param hidden the number of hidden layers.
     */
    public EvoFeedForwardNN(int hidden) {
        super(hidden);
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
    }
    
    /**
     * Calculate the fitness for this network. This is defined as the difference between
     * the actual and desired output of the network.
     */    
    public void calculateFitness() {
        double err = 0.0;
        for (int i=0; i<inputData.length; i++) {
//            err += Math.abs(run(inputData[i]));
        }
    }
    
    /**
     * Compare to another feedforward network.
     * @param o the comparable object.
     * @return -1, 0 or 1.
     */    
    public int compareTo(Object o) {
        EvoFeedForwardNN object = (EvoFeedForwardNN)o;
        
        if (fitnessValue < object.fitnessValue) return -1;
        if (fitnessValue > object.fitnessValue) return 1;
        
        return 0;
    }
    
    /**
     * Return the fitness value for this network.
     * @return the fitness value.
     */    
    public double getFitness() {
        return fitnessValue;
    }
    
    /**
     * Mate with another network.
     * @param partner the other parent network.
     * @return the new child network.
     */    
    public Evolvable mate(Evolvable partner) {
        return null;
    }
    
    /**
     * Mutate this feedforward network.
     */    
    public void mutate() {
    }
    
    /**
     * Randomly initialize the network. The weights within the feedforward are randomly
     * initialized.
     */    
    public void randomInitialize() {
    }
    
}
