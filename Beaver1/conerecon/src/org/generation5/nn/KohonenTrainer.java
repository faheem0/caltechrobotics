/*
 * KohonenTrainer.java
 * Created on 24 November 2004, 16:28
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

import org.generation5.nn.*;
import org.generation5.util.*;

/**
 * This class implements the Kohonen training algorithm. The class implements
 * the training algorithm as a two-stage process: phase one reduces the 
 * neighbourhood radius slowly to one, while the learning constant k is reduced
 * from 0.9 to 0.1. Phase two increases the number of training points slightly,
 * keeps the neighbourhood size constant at one, and reduces the learning rate
 * from 0.1 to 0.
 *
 * @author James Matthews
 */
public abstract class KohonenTrainer extends NeuralNetworkTrainer {
    /**
     * The number of phase one training iterations.
     */    
    protected int phaseOne = 250;
    /**
     * The number of phase two training iterations.
     */    
    protected int phaseTwo = 100;
    /**
     * The training steps per iteration.
     */    
    protected int trainingSteps = 50;
    /**
     * The number of iterations to train before reducing the neighbourhood size.
     */    
    protected int reductionStep = 0;
    /**
     * The current training iteration.
     */    
    protected int currentIteration = 0;
    /**
     * The amount at which k should be reduced.
     */    
    protected double deltaK = 0.8 / phaseOne;
    /**
     * The training data.
     */    
    protected double[] trainData = new double[2];
    /**
     * Denotes whether the network has finished training.
     */    
    protected boolean hasFinished = false;
    /**
     * The Kohonen network.
     */    
    protected KohonenNN kohonenNN;
    
    /** Creates a new instance of KohonenTrainer */
    public KohonenTrainer() {
    }    
    
    /**
     * Set the number of iterations for the two training phases.
     *
     * @param p1 the number of phase one iterations.
     * @param p2 the number of phase two iterations.
     */    
    public void setPhases(int p1, int p2) {
        phaseOne = p1;
        phaseTwo = p2;
    }
    
    /**
     * Abstract method to allow a deriving class to return a
     * valid training point.
     *
     * @return Returns a random training point.
     */    
    public abstract double[] getTrainingPoint();/* {
        return new double[] { Math.random() * 2 - 1.0, Math.random() * 2 - 1.0 };
    }*/
    
    /**
     * Iterates one step of the Kohonen training algorithm.
     * Nofitications are set up to fire after every iteration (ID = 0),
     * and once training has completed (ID = 1). For more information about
     * the training algorithm itself, see the class description.
     */
    public void doStep() {
        int nr = kohonenNN.getNeighbourhoodRadius();
        
        for (int j=0; j<trainingSteps; j++) {
            trainData = getTrainingPoint();
            
            try {
                kohonenNN.train(trainData);
            } catch (NeuralNetworkException e) {
                System.err.println(e);
            }
        }
        
        if (currentIteration < phaseOne) {
            if (phaseOne > 4 && (currentIteration % reductionStep == 0))
                kohonenNN.setNeighbourhoodRadius(nr-1);
            kohonenNN.reduceK(deltaK);
        } else if (currentIteration == phaseOne) {
            kohonenNN.setNeighbourhoodRadius(1);
            trainingSteps = 75;
            kohonenNN.setK(0.1);
            deltaK = 0.1 / phaseTwo;
        } else {
            if (currentIteration > (phaseOne + phaseTwo)) {
                hasFinished = true;
                if (notifier != null) notifier.notify(1, this, null);
            }
            
            if (kohonenNN.getK() > 0)
                kohonenNN.reduceK(deltaK);
            else
                kohonenNN.setK(0);
        }
        
        if (notifier != null) notifier.notify(0, this, null);
        
        currentIteration++;
    }
    
    /**
     * Initializes the trainer.
     */    
    public void init() {
        kohonenNN.setK(0.9);
        kohonenNN.setNeighbourhoodRadius(kohonenNN.getWidth() / 2);
        kohonenNN.initialize();
        
        currentIteration = 0;
        trainingSteps = 50;
        deltaK = 0.8 / phaseOne;
        hasFinished = false;
        reductionStep = (phaseOne / (kohonenNN.getNeighbourhoodRadius() - 1)) + 1;
    }
    
    /**
     * Set the Kohonen network to use in the trainer.
     * @param net the Kohonen network to use.
     */    
    public void setNetwork(NeuralNetwork net) {
        kohonenNN = (KohonenNN)net;
    }

    /**
     * Return the network being used.
     * @return the network being used.
     */    
    public NeuralNetwork getNetwork() {
        return kohonenNN;
    }
    
    /**
     * Returns whether the training is complete (<code>hasFinished</code>).
     * @see #hasFinished
     * @return true if training has completeld, otherwise false.
     */    
    public boolean isComplete() {
        return hasFinished;
    }
    
    /**
     * Returns the current iteration.
     * @return the current iteration.
     */    
    public int getCurrentIteration() {
        return currentIteration;
    }
    
    /**
     * Return the phase being used by the Kohonen network (1 or 2).
     * @return the phase the Kohonen training algorithm is in.
     */    
    public int getPhase() {
        return (currentIteration < phaseOne) ? 1 : 2;
    }
}
