/*
 * KohonenNN.java
 * Created on 23 September 2004, 14:42
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

import org.generation5.util.*;
import org.generation5.nn.NeuralNetwork.*;

/**
 * This class provides a simple implementation of a two-dimensional Kohonen self-
 * organizing map. <code>KohonenNN.train</code> only implements one iteration of
 * the training algorithm, and as such does not handle the learning rate and
 * neighbourhood alterations. <code>KohonenTrainer</code> provides the necessary
 * implementation for that.
 *
 * @author James Matthews
 * @see org.generation5.nn.KohonenNN#train(double[], double[])
 * @see org.generation5.nn.KohonenTrainer
 * @see org.generation5.nn.KohonenTrainer#doStep()
 */
public class KohonenNN extends NeuralNetwork {
    /**
     * The width of the network.
     */
    protected int width = -1;
    /**
     * The height of the network.
     */
    protected int height = -1;
    /**
     * The number of feature vectors
     */
    protected int featureVectors = -1;
    /**
     * The learning constant.
     */
    protected double k = 0.9;
    /**
     * The network's weights. Weights are a 3-dimensional array, or a 2-dimensional
     * array of feature vectors.
     */
    protected double weights[][][];
    /**
     * The neighbourhood radius used during learning.
     */
    protected int neighbourhoodRadius = 1;

    private double min = -1, max = -1;
    
    /** Creates a new instance of KohonenNN */
    public KohonenNN() {
    }
    
    /**
     * Create a new instance of the network with additional size information.
     *
     * @param w the width of the network.
     * @param h the height of the network.
     */
    public KohonenNN(int w, int h) {
        this(w, h, 2);
    }
    
    public KohonenNN(int w, int h, int v) {
        setDimensions(w, h, v);
    }
    
    /**
     * Set the dimensions of the network.
     * @param w the width of the network.
     * @param h the height of the network.
     */
    public void setDimensions(int w, int h, int v) {
        width  = w;
        height = h;
        featureVectors = v;
        
        weights = new double[w][h][v];
        
        neighbourhoodRadius = (width / 2);
    }
    
    /**
     * Return the width of the network.
     * @return the width of the network.
     */
    public int getWidth() {
        return width;
    }
    
    /**
     * Return the height of the network.
     * @return the height of the network.
     */
    public int getHeight() {
        return height;
    }
    
    public int getFeatureVectors() {
        return featureVectors;
    }
    
    /**
     * Set the neighbourhood radius used during training. The new radius must
     * be greater than zero.
     * @param nr the new neighbourhood radius.
     */
    public void setNeighbourhoodRadius(int nr) {
        if (nr < 1) neighbourhoodRadius = 1;
        else neighbourhoodRadius = nr;
    }
    
    /**
     * Retrieve the neighbourhood radius.
     * @return the neighbourhood radius.
     */
    public int getNeighbourhoodRadius() {
        return neighbourhoodRadius;
    }
    
    /**
     * Reduces the neighbourhood radius by the specified amount.
     * @param nrd the neighbourhood radius delta. The delta is subtracted from the current
     * neighbourhood radius.
     */
    public void reduceNeighbourhoodRadius(int nrd) {
        setNeighbourhoodRadius(neighbourhoodRadius - nrd);
    }
    
    /**
     * Set <i>k</i>, the learning constant. The new constant must be greater than,
     * or equal to, zero.
     * @param nk the new value of <i>k</i>.
     */
    public void setK(double nk) {
        if (nk < 0) k = 0;
        else k = nk;
    }
    
    /**
     * Retrieve the K-value.
     * @return the k-value of the network.
     */
    public double getK() {
        return k;
    }
    
    /**
     * Reduce the learning constant by a specified amount.
     *
     * @param kd the <i>k</i> delta. This value will be subtracted from the current <i>k</i>.
     */
    public void reduceK(double kd) {
        setK(k - kd);
    }
    
    /**
     * Initialize the network. All weights are initialized to random values between -0.5
     * and 0.5.
     */
    public void initialize() {
        if (min == -1 && max == -1)
            initialize(-0.5, 0.5);
        else
            initialize(min, max);
    }
    
    /**
     * Initialize the network. All weights are initialized to random values between
     * the specified values.
     * @param min the minimum value.
     * @param max the maximum value.
     */
    public void initialize(double min, double max) {
        if (width == -1 || height == -1 || featureVectors == -1) {
            throw new IllegalArgumentException("dimensions must be set before calling initialize!");
        }
        
        this.min = min;     // save in case initialize() is called
        this.max = max;
        
        java.util.Random random = new java.util.Random();
        double numberRange = Math.abs(min) + Math.abs(max);
        
        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                for (int v=0; v<featureVectors; v++)
                    weights[i][j][v] = (random.nextDouble() * numberRange) - Math.abs(min);
            }
        }
    }
    
    /**
     * Retrieves the closest neuron to the input point.
     * @param x input x
     * @param y input y
     * @return the neuron (<code>PlotPoint</code>) closest in distance to the inputs.
     */
    public int[] getClosestNeuron(double[] input) {
        // Get 'nearest' neuron.
        int minx = 0, miny = 0;
        double d = 0, mind = Double.MAX_VALUE;
        
        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                for (int v=0; v<featureVectors; v++) {
                    d += (input[v] - weights[i][j][v]) * (input[v] - weights[i][j][v]);
                }
                
                if (d < mind) {
                    minx = i; miny = j;
                    mind = d;
                }
                
                d = 0;
            }
        }
        
        return new int[] { minx, miny };
    }
    
    /**
     * Run the network for a given input. (<i>Currently does not return anything meaningful.</i>)
     * @param inputData the input data.
     * @return the network output (0.0).
     */
    public double run(double[] inputData) {
        if (neighbourhoodRadius < 1) neighbourhoodRadius = 1;
        
        //        getClosestNeuron(inputData[0], inputData[1]);
        
        return 0.0;
    }
    
    /**
     * Train the network using <code>KohonenData</code>. This implementation of the training
     * algorithm only trains for one iteration, using the given learning rate and
     * neighbourhood size. See the <code>main</code> function for a complete training
     * cycle.
     * @return nothing.
     * @param inputData the input data.
     * @param expectedOutput unused.
     */
    public double train(double[] inputData, double[] expectedOutput) {
        int[] closest = getClosestNeuron(inputData);
        int minx = closest[0];
        int miny = closest[1];
        int nr2 = neighbourhoodRadius * neighbourhoodRadius;
        double influence;
        int dx;
        
        // Adjust the weights in the necessary neighbournood.
        for (int i=minx-neighbourhoodRadius; i<=minx+neighbourhoodRadius; i++) {
            if (i < 0 || i >= width)  continue;
            dx = ((minx-i) * (minx-i));     // cache this for speed
            for (int j=miny-neighbourhoodRadius; j<=miny+neighbourhoodRadius; j++) {
                if (j < 0 || j >= height) continue;
                
                int dist = (int)Math.abs(dx + ((miny-j) * (miny-j)));
                if (dist > nr2) continue;
                
                influence = Math.exp(-(dist) / (2.0*nr2));
                
                for (int v=0; v<featureVectors; v++)
                    weights[i][j][v] += k*influence*(inputData[v] - weights[i][j][v]);
            }
        }
        
        return 0.0;
    }
    
    /**
     * Return the array of <code>PlotPoint</code>s used to store the weights. Useful for
     * plotting the weights on a grid.
     * @see org.generation5.util.PlotGrid#setGridPoints(PlotPoint[][])
     * @return a two-dimensional array of <code>PlotPoint</code>s.
     */
    public double[][][] getWeights() {
        return weights;
    }
}
