/*
 * Evolvable.java
 * Created on 22 July 2004, 14:12
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

/**
 * This interface allows any class to be evolvable by {@link org.generation5.bio.GeneticAlgorithm}.
 * It is derived from <code>Comparable</code> so they classes can be efficiently sorted by the
 * GA. Invariably, this is done by fitness.
 *
 * @author James Matthews
 */
public interface Evolvable extends java.lang.Comparable {
    /**
     * Initialize the class to random values. This allows for a default constructor or
     * initializor, as well as the random initializor required for the genetic
     * algorithm.
     */
    public void randomInitialize();
    /**
     * Mutate the class data.
     */
    public void mutate();
    /**
     * Mate with another <code>Evolvable</code> type. It is entirely up to the class
     * implementator how to implement the mating; one-point, two-point crossover etc.
     * @param partner the other mate.
     * @return the child of <code>this</code> and <code>partner</code>.
     */
    public Evolvable mate(Evolvable partner);
    /**
     * Calculate the fitness of this object.
     */
    public void calculateFitness();
    /**
     * Return the fitness of this object.
     * @return the fitness.
     */
    public double getFitness();
}
