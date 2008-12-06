/*
 * NeuralNetworkTrainer.java
 * Created on 22 November 2004, 13:54
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
import org.generation5.nn.*;

/**
 * This class is intended to provide a common interface for the more complicated
 * neural network training algorithms, such as a multi-stage Kohonen training 
 * algorithm. {@link org.generation5.nn.NeuralNetwork#train(double[], double[]) 
 * should only implement one iteration of the training algorithm, and if this
 * algorithm has multiple stages, variables or other complicating factors, it
 * may be easier to use <code>NeuralNetworkTrainer</code> to provide the overall
 * framework.
 *
 * In addition to this, a <code>NeuralNetworkTrainer</code>-derived class can be
 * created to deal with a specific training situation. Continuing with our Kohonen
 * example, you could create a trainer for simple 2D shapes, mapping RGB colours,
 * or complex image association.
 *
 * Finally, <code>NeuralNetworkTrainer</code> also implements <code>Steppable</code>
 * adding greater flexibility/integration when creating demonstration applets/
 * applications.
 *
 * @author James Matthews
 * @see NeuralNetwork#train(double[], double[])
 */
public abstract class NeuralNetworkTrainer implements Steppable {
    /**
     * A simple interface that allows a <code>NeuralNetworkTrainer</code> to notify
     * additional classes about events.
     */    
    protected Notifier notifier;
    
    /** Creates a new instance of NeuralNetworkTrainer */
    public NeuralNetworkTrainer() {
    }
    
    /**
     * Set the network being used by the trainer.
     * @param net the network to be trained.
     */    
    public abstract void setNetwork(NeuralNetwork net);
    /**
     * Return the network being used.
     * @return the network currently being trained.
     */    
    public abstract NeuralNetwork getNetwork();
    /**
     * Set the notifier for this class.
     * @param notify the neural network notifier.
     */    
    public void setNotifier(Notifier notify) {
        notifier = notify;
    }

    /**
     * Returns true is training is complete.
     * @return true, if training has finished, otherwise false.
     */    
    public abstract boolean isComplete();
    /**
     * Advance the training one step.
     */    
    public abstract void doStep();
    /**
     * Initialize the training algorithm.
     */    
    public abstract void init();
    /**
     * Reset the training algorithm (defaults to calling <code>init</code>).
     */    
    public void reset() {
        init();
    }
    
    /**
     * Run the training algorithm. This method is simply defined as:
     * <code>
     * <b>public void</b> run() {
     *  <b>while</b> (!isComplete()) {
     *    doStep();
     *  }
     * }
     * </code>
     */    
    public void run() {
        while (!isComplete()) {
            doStep();
        }
    }
    
}
