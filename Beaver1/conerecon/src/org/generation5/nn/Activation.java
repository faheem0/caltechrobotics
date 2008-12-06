/*
 * Activation.java
 * Created on 17 August 2004, 11:47
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
 * The interface for the neural network activation function.
 * @author James Matthews
 */
public interface Activation {
    /**
     * The activation function.
     * @param in the summed, weighted inputs from the neural network.
     * @return the 'activated' result.
     */    
    public abstract double function(double in);
    
    /**
     * A stepped activation function. If n > 0, return 1.0 otherwise return 0.0.
     */    
    public static class Stepped implements Activation {
        /**
         * Return 1.0 for any value greater than 0.0, otherwise 0.0.
         * @param in the input weight.
         * @return the stepped weight.
         */        
        public double function(double in) {
            if (in > 0) return 1.0;
            return 0.0;
        }
    }

    /**
     * No activation function. Returns the input.
     */    
    public static class None implements Activation {
        /**
         * Returns the weight.
         * @param in the input weight.
         * @return the input weight (no change).
         */        
        public double function(double in) {
            return in;
        }
    }

    /**
     * Sigmoid activation function.
     */    
    public static class Sigmoid implements Activation {
        
        /**
         * Return f(x) = 1/(1+<i>e</i><sup>-x</sup>.
         * @param in the input weight.
         * @return sigmoid activation function.
         */        
        public double function(double in) {
            return 1 / (1 + Math.exp(in * -1));
        }
    }
    
    /**
     * Hyperbolic tangent activation function.
     */    
    public static class Tanh implements Activation {
        
        /**
         * Return f(x) = <i>e</i><sup>x</sup>-<i>e</i><sup>-x</sup>)
         * /(<i>e</i><sup>x</sup>+<i>e</i><sup>-x</sup>.
         * @param in the input weight.
         * @return tanh activation result.
         */        
        public double function(double in) {
            double p1 = Math.exp(in), p2 = Math.exp(in*-1);
            return (p1 - p2) / (p1 + p2);
        }
        
    }
}
