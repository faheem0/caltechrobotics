/*
 * FFNLayer.java
 * Created on 22 November 2004, 13:39
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
 * An abstract class for the feedforward layers.
 * @author James Matthews
 */
public abstract class FFNLayer {
    /**
     * The outputs for this layer.
     */    
    protected double[] outputs;
    /**
     * The weights for this layer.
     */    
    protected double[][] weights;
    /**
     * The next layer that this layer is connected to.
     */    
    protected FFNLayer connected;
    /**
     * The network this layer belongs to.
     */    
    protected FeedForwardNN myNetwork;
    /**
     * The activation function this layer uses.
     */    
    protected Activation activate = new Activation.Sigmoid();
    
    /** Creates a new instance of FFNLayer */
    public FFNLayer() {
    }
    
    /**
     * Set the network for this layer.
     * @param network the network to be used.
     */    
    public void setNetwork(FeedForwardNN network) {
        myNetwork = network;
    }
    
    /**
     * Connects this layer with another layer. This method is should normally only be
     * called <code>FeedForwardNN.initialize</code>.
     * @param connect the connecting layer.
     * @see FeedForwardNN#initialize()
     */    
    public void connectWith(FFNLayer connect) {
        connected = connect;
        weights = new double[getUnitCount()][connected.getUnitCount()];
    }
    
    /**
     * Set the weights for this layer. This method iteratively calls:
     * <code>
     *  for (int u=0; u<weights.length; u++) {
     *    setWeights(u, newWeights[u]);
     *  }
     * </code>
     * @param newWeights the new weights.
     */    
    public void setWeights(double[][] newWeights) {
        if (weights.length != newWeights.length)
            throw new IllegalArgumentException("new weights invalid length");
        
        for (int u=0; u<weights.length; u++) {
            setWeights(u, newWeights[u]);
        }
    }
    
    /**
     * Set the weights for a given units.
     * @param unit the unit to set the weights for.
     * @param newWeights the new weight array.
     */    
    public void setWeights(int unit, double[] newWeights) {
        if (weights[unit].length != newWeights.length)
            throw new IllegalArgumentException("new weights invalid length");
        
        for (int w=0; w<weights[unit].length; w++) {
            weights[unit][w] = newWeights[w];
        }
        
    }
    
    /**
     * Randomize the weights between the given range.
     * @param min the range minimum.
     * @param max the range maximum.
     */    
    public void randomizeWeights(double min, double max) {
        for (int u=0; u<weights.length; u++) {
            for (int w=0; w<weights[u].length; w++) {
                weights[u][w] = min + (Math.random() * (max - min));
            }
        }
    }
    
    /**
     * Get the number of units in this layer.
     * @return the number of units.
     */    
    public abstract int getUnitCount();
    
    /**
     * Retrieve the outputs for this layer.
     * @return the layer output.
     */    
    public double[] getOutput() {
        return outputs;
    }
    
    /**
     * Run this layer on the given inputs.
     * @param input the inputs for this layer.
     * @throws NeuralNetworkException unused.
     */    
    public void run(double[] input) throws NeuralNetworkException {
        // FIXME: I'm not happy with this at all...
        if (connected != null) {
            outputs = new double[connected.getUnitCount()];

            for (int o=0; o<outputs.length; o++) {
                outputs[o] = 0;
                for (int i=0; i<getUnitCount(); i++)
                    outputs[o] += input[i] * weights[i][o];
                // Run through the activation function
                outputs[o] = activate.function(outputs[o]);
            }
        } else {
            outputs = new double[input.length];
            for (int i=0; i<input.length; i++)
                outputs[i] = input[i];
        }
    }
}
