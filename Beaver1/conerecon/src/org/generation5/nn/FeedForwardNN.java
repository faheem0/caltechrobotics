/*
 * FeedForwardNN.java
 * Created on 17 November 2004, 14:22
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
 * A simple implementation of a feedforward network.
 * @author James Matthews
 */
public class FeedForwardNN extends NeuralNetwork {
    /**
     * The number of layers in the feedforward network.
     */    
    protected int numLayers = 0;
    /**
     * The layers in this network.
     */    
    protected FFNLayer[] nnLayers;
    
    /**
     * Creates a new instance of FeedForwardNN
     * @param hiddenLayers the number of hidden layers to be in this network.
     */
    public FeedForwardNN(int hiddenLayers) {
        numLayers = hiddenLayers + 2;
        nnLayers = new FFNLayer[numLayers];
    }
    
    /**
     * Set the input layer for the network.
     * @param input the input layer.
     */    
    public void setInputLayer(FFNInputLayer input) {
        nnLayers[0] = input;
    }
    
    /**
     * Set the given hidden layer.
     * @param hidden the hidden layer.
     * @param layer the layer index.
     */    
    public void setHiddenLayer(FFNLayer hidden, int layer) {
        if (layer == 0 || layer > numLayers - 1)
            throw new IllegalArgumentException("layer index out of range.");
        nnLayers[layer] = hidden;
    }
    
    /**
     * Set the output layer.
     * @param output the output layer.
     */    
    public void setOutputLayer(FFNLayer output) {
        nnLayers[numLayers-1] = output;
    }
    
    /**
     * Initialize the network. This method verifies that all layers have been added,
     * and automatically connects each layer to the next.
     * @throws NeuralNetworkException an exception is thrown if a layer is missing.
     */    
    public void initialize() throws NeuralNetworkException {
        for (int i=0; i<nnLayers.length; i++) {
            // quick error check
            if (nnLayers[i] == null)
                throw new NeuralNetworkException("not all layers added.");
            // Set the layer's network
            nnLayers[i].setNetwork(this);
            // Connect it to the next layer
            if (i < nnLayers.length - 1)
                nnLayers[i].connectWith(nnLayers[i+1]);
        }
    }
    
    /**
     * Run the network with the given inputs.
     * @param inputData the inputs.
     * @throws NeuralNetworkException unused.
     * @return the output of the feedforward network.
     */    
    public double run(double[] inputData) throws NeuralNetworkException {
        double[] in = inputData;
        
        for (int l=0; l<numLayers; l++) {
            nnLayers[l].run(in);
            // Get the output of the later
            in = nnLayers[l].getOutput();
        }
        
        return nnLayers[numLayers - 1].getOutput()[0];
    }
    
    /**
     * This class does not implement a training algorithm.
     * @param inputData unused.
     * @param outputData unused.
     * @return -1.
     */    
    public double train(double[] inputData, double[] outputData) {
        return -1;
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // The feedforward network
        FeedForwardNN ffn = new FeedForwardNN(1);
        // The layers
        FFNInputLayer input = new FFNInputLayer(2);
        FFNHiddenLayer hidden = new FFNHiddenLayer(2);
        FFNOutputLayer output = new FFNOutputLayer();
        // Add the layers to the nn
        ffn.setInputLayer(input);
        ffn.setHiddenLayer(hidden, 1);
        ffn.setOutputLayer(output);
        
        try {
            ffn.initialize();                   // Initialize
            input.setWeights(0, new double[] { 0.25, 0.75 });
            input.setWeights(1, new double[] { 0.5, 1.0 });
            hidden.setWeights(0, new double[] { 0.33 });
            hidden.setWeights(1, new double[] { 0.66 });
            System.out.println(ffn.run(new double[] { 0.15, 0.85 })); // Run the network
        } catch (NeuralNetworkException e) {
            System.err.println(e);
        }
    }
}
