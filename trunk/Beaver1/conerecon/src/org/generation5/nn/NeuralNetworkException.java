/*
 * NeuralNetworkException.java
 * Created on 22 November 2004, 21:06
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
 * A simple class for neural network exceptions.
 * @author James Matthews
 */
public class NeuralNetworkException extends Exception {
    
    /** Creates a new instance of NeuralNetworkException */
    public NeuralNetworkException() {
    }
    
    /**
     * Creates a new instance of NeuralNetworkException with a reason for the error.
     * @param err the reason for the exception being thrown.
     */    
    public NeuralNetworkException(String err) {
        super(err);
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
    }
    
}
