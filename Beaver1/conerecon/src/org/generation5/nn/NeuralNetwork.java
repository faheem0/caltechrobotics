/*
 * NeuralNetwork.java
 * Created on 12 July 2004, 15:52
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

import org.generation5.*;
import org.generation5.ai.*;

/**
 * A neural network framework class. The class is meant to help create simple neural
 * networks, such as perceptrons and self-organizing networks.
 * @author James Matthews
 */
public abstract class NeuralNetwork implements Visualizable {
    /**
     * Allows for a visualizer to be assigned to a neural network. This may be a data
     * plotter, a bitmapped representation of the neural network etc.
     */    
    protected Visualizable visualization = null;
    
    /**
     * Initialize the neural network.
     * @throws NeuralNetworkException This
     */    
    public abstract void initialize() throws NeuralNetworkException ;
    /**
     * Train the neural network on the given training data.
     * @return a double value. This actual interpretation of this return is class-dependent.
     * @param inputData the input data.
     * @param expectedOutput the expect output.
     * @throws NeuralNetworkException if an error occurs with training, this method should throw a <code>NeuralNetworkException</code>.
     */    
    public abstract double train(double[] inputData, double[] expectedOutput) 
        throws NeuralNetworkException ;
    
    /**
     * This method is provided as a helper for networks that only have one output,
     * therefore only one expected output. The method is defined as:
     * <code>
     * <b>public double</b> train(<b>double</b>[] inputData, <b>double</b> expectedOutput)
     *  <b>throws</b> NeuralNetworkException {
     *    <b>return</b> train(inputData, <b>new double</b>[] { expectedOutput });
     * }
     * </code>
     * @param inputData the input data.
     * @param expectedOutput the expected output.
     * @throws NeuralNetworkException the exception thrown if any training errors occur.
     * @return the value returned by <code>train(double[], double[])</code>.
     * @see #train(double[], double[])
     */    
    public double train(double[] inputData, double expectedOutput) throws NeuralNetworkException {
        return train(inputData, new double[] { expectedOutput });
    }
    
    /**
     * This method is provided as a helper for networks that have no expected output,
     * such as unsupervised networks. The method is defined as:
     * <code>
     * <b>public double</b> train(<b>double</b>[] inputData) <b>throws</b> NeuralNetworkException {
     *  <b>return</b> train(inputData, <b>null</b>);
     * }
     * </code>
     * @param inputData the input data.
     * @throws NeuralNetworkException the exception thrown if any training errors occur.
     * @return the value returned by <code>train(double[], double[])</code>.
     */    
    public double train(double[] inputData) throws NeuralNetworkException {
        return train(inputData, null);
    }
    
    /**
     * Run the neural network on the given inputs.
     * @return the returned value of the neural network.
     * @param inputData the input data.
     * @throws NeuralNetworkException an exception is thrown if an error occurs.
     */    
    public abstract double run(double[] inputData) throws NeuralNetworkException ;
    
    /**
     * Set the activation function.
     * @param ac the activation function.
     */    
    public void setActivation(Activation ac) {
        activation = ac;
    }
    
    /**
     * Render the neural network using the assigned visualization.
     * @param g the graphics context.
     * @param width the width of the graphics context.
     * @param height the height of the graphics context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        if (visualization != null) 
            visualization.render(g, width, height);
    }
    
    /**
     * Write an image of the neural network using the assigned visualization.
     * @param s the filename of the image to write.
     * @param width the width of the image.
     * @param height the height of the image.
     */    
    public void writeImage(String s, int width, int height) {
        if (visualization != null) 
            visualization.writeImage(s, width, height);
    }
    
    /**
     * Return the current visualization.
     * @return the visualization currently assigned.
     */    
    public Visualizable getVisualization() {
        return visualization;
    }
    
    /**
     * Set the visualization to use.
     * @param vis the visualization class to use.
     */    
    public void setVisualization(Visualizable vis) {
        visualization = vis;
    }
    
    /**
     * The activation function.
     */    
    protected Activation activation = new Activation.Stepped();
}

