/*
 * EvolveStandard.java
 * Created on 29 July 2004, 19:25
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

package org.generation5.bio;

import java.util.*;

/**
 * <code>EvolveStandard</code> implements the {@link org.generation5.bio.Evolvable} interface and
 * provides default behaviour for fitness values, as well as providing the necessary
 * <code>Comparable</code> implementation for sorting in both ascending and descending
 * order.
 * @author James Matthews
 */
public abstract class EvolveStandard implements Evolvable {
    
    /** The fitness value. */    
    protected double fitnessValue = -1.0;
    /**
     * Whether the genetic algorithm minimize or maximize the fitness. This is implemented
     * through the sorting function.
     * @see #compareTo(Object)
     */    
    protected boolean minimizeFitness = true;
    /**
     * An instance of java.util.Random, useful for generating a range of random numbers.
     */    
    static protected Random random = new Random();
    
    /** Creates a new instance of EvolveStandard */
    public EvolveStandard() {
    }
    
    /**
     * The fitness function. Should store the fitness to <tt>fitnessValue</tt>.
     */    
    public abstract void calculateFitness();
    
    /**
     * Compares two <code>EvolveStandard</code> objects and sorts by fitness. By default,
     * values are sorted in ascending order.
     * @param o the object to compare to.
     * @return -1, 0 or 1 according to fitness levels.
     */    
    public int compareTo(Object o) {
        EvolveStandard object = (EvolveStandard)o;
        
        if (fitnessValue < object.fitnessValue) return (minimizeFitness) ? -1:1;
        if (fitnessValue > object.fitnessValue) return (minimizeFitness) ? 1:-1;
        
        return 0;
    }
    
    /**
     * Retrieve the fitness of this instance.
     * @return the fitness value of this instance.
     */    
    public double getFitness() {
        return fitnessValue;
    }
    
    /**
     * Abstract function to mate with another object to produce an offspring for the
     * next generation.
     * @param partner the partner object.
     * @return a child object.
     */    
    public abstract Evolvable mate(Evolvable partner);
    
    /**
     * Abstract function to mutate the object.
     */    
    public abstract void mutate();
    
    /**
     * An abstract function to randomize the object's initial settings.
     */    
    public abstract void randomInitialize();
    
}
