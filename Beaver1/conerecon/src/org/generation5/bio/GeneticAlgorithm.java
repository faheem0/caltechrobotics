/*
 * GeneticAlgorithm.java
 * Created on 25 July 2004, 17:41
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
import java.util.Arrays;
import org.generation5.*;
import org.generation5.util.*;

/**
 * <code>GeneticAlgorithm</code> will evolve anything that implements the
 * <code>Evolvable</code> interface. The genetic algorithm implements
 * <code>Steppable</code>, with each step of the GA being implemented within
 * <code>doStep</code>.
 * <p>
 * Currently, only elitism is supported.
 * @author James Matthews
 * @see org.generation5.Steppable
 * @see org.generation5.Steppable#doStep()
 * @see org.generation5.bio.Evolvable
 */
public class GeneticAlgorithm implements Steppable {

    /**
     * The population to evolve. The population is double-buffered, which increases
     * speed but does require some caution when retrieving values from the class.
     * See <code>doStep</code> and <code>getBest</code> for more information.
     * @see #doStep()
     * @see #getBest()
     */    
    protected Evolvable[][] population;
    /**
     * The current iteration of the genetic algorithm, incremented upon each call to
     * <code>doStep</code>.
     */    
    protected int currentIteration;
    /**
     * The maximum number of iterations (currently unused).
     */    
    protected int maximumIterations = 10000;
    /**
     * The percentage of elites to copy to the new population (defaults to 0.05, or 5%).
     */    
    protected double elitePercentage = 0.05;
    /**
     * The mutation rate (default to 0.05, or 5%).
     */    
    protected double mutationRate = 0.05;
    
    /**
     * The average fitness for this generation.
     */    
    protected double averageFitness = -1;
    
    /**
     * Determines whether average and best fitness data should be logged.
     */    
    protected boolean logData = true;
    /**
     * The maximum number of data points to store in the linked lists.
     */    
    protected int maximumDataPoints = 1024;
    /**
     * The average fitness linked list. Fitnesses are stored as PlotPoints for easy
     * plotting.
     * @see org.generation5.util.PlotPoint
     * @see org.generation5.util.Plot2D
     */    
    protected LinkedList averageFitnesses = new LinkedList();
    /**
     * The best fitness linked list. Fitnesses are stored as PlotPoints for easy
     * plotting.
     * @see org.generation5.util.PlotPoint
     * @see org.generation5.util.Plot2D
     */    
    protected LinkedList bestFitnesses = new LinkedList();
    
    // Private member variables
    private int bufferPosition = 0; 
    
    /** Creates a new instance of GeneticAlgorithm */
    public GeneticAlgorithm() {
    }
    
    /**
     * Create a instance of the genetic algorithm with an initial population.
     * @param population the initial population.
     */    
    public GeneticAlgorithm(Evolvable[] population) {
        setPopulation(population);
    }
    
    /**
     * Return the average fitness linked list.
     * @return the average fitness linked list.
     */    
    public LinkedList getAverageFitnesses() {
        return averageFitnesses;
    }
    
    /**
     * Return the best fitness linked list.
     * @return the best fitness linked list.
     */    
    public LinkedList getBestFitnesses() {
        return bestFitnesses;
    }
    
    /**
     * Set the population to an initial array of <tt>Evolvable</tt>s.
     * @see org.generation5.bio.Evolvable
     * @param thisPopulation the population to assign to the genetic algorithm.
     */    
    public void setPopulation(Evolvable[] thisPopulation) {
        population = new Evolvable[2][thisPopulation.length];
        population[0] = thisPopulation;
        population[1] = new Evolvable[thisPopulation.length];
    }
    
    /**
     * Return the current population (double-buffering taken into account).
     * @return the current population.
     */    
    public Evolvable[] getCurrentPopulation() {
        return inPopulation();
    }
    
    /**
     * Flips the genetic algorithm buffer.
     */    
    protected void flipBuffer() {
        bufferPosition = 1 - bufferPosition;
    }
    
    /**
     * The current population
     * @return the current population.
     */    
    protected Evolvable[] inPopulation() {
        return population[bufferPosition];
    }
    
    /**
     * The new population.
     * @return the new population.
     */    
    protected Evolvable[] outPopulation() {
        return population[1-bufferPosition];
    }
        
    /**
     * Steps through one iteration of the genetic algorithm. Fitnesses are calculated
     * for each member of the population, sorted by fitness and mated together.
     * <code>doStep</code> also implements elitism and mutation.
     * <p>
     * Note that at the end of the iteration, <code>flipBuffer</code> is called. This
     * means that the <code>inPopulation</code> returns the new, unsorted population
     * and <code>outPopulation</code> returns the "current", sorted population.
     */    
    public void doStep() {
        if (population == null)
            throw new NullPointerException("population is null!");
        
        Evolvable[] in = inPopulation();
        Evolvable[] out = outPopulation();
        
        averageFitness = 0;
        // Calculate the fitnesses (and overall average fitness)
        for (int i=0; i<in.length; i++) {
            in[i].calculateFitness();
            averageFitness += in[i].getFitness();
        }
        averageFitness /= in.length;
        // Sort by fitness
        java.util.Arrays.sort(in);        
        
        if (logData == true) {
            // Start to remove earlier data if the maximum
            // number of data points has been reached.
            if (averageFitnesses.size() == maximumDataPoints) {
                averageFitnesses.removeFirst();
                bestFitnesses.removeFirst();
            }
            
            // Update the linked lists with the data
            averageFitnesses.add(new PlotPoint(currentIteration, averageFitness));
            bestFitnesses.add(new PlotPoint(currentIteration, in[0].getFitness()));        
        }
        
        // Copy over elites.
        int eliteNumber = (int)Math.round(in.length * elitePercentage);
        for (int i=0; i<eliteNumber; i++) {
            out[i] = in[i];
        }
        // Now do all the mating
        int p1, p2;
        for (int i=eliteNumber; i<in.length; i++) {
            // TODO: Different selection methods...
            p1 = (int)(Math.random() * (in.length / 2));
            p2 = (int)(Math.random() * (in.length / 2));
            // Now mate them and put them in the buffered array
            out[i] = in[p1].mate(in[p2]);
            if (Math.random() < mutationRate) out[i].mutate();
        }
        
        currentIteration++;

        flipBuffer();
    }
    
    /**
     * Set the mutation rate (should generally be between 0.0 and 0.2).
     * @param mr the mutation rate.
     */    
    public void setMutationRate(double mr) {
        mutationRate = mr;
    }
    
    /**
     * Retrieve the current mutation rate.
     * @return the mutation rate.
     */    
    public double getMutationRate() {
        return mutationRate;
    }
    
    /**
     * Initialize the genetic algorithm.
     */    
    public void init() {
        currentIteration = 0;
        bufferPosition = 0;
        // randomly initialize the population
        for (int i=0; i<population[0].length; i++) {
            population[0][i].randomInitialize();
        }
        
        averageFitnesses.clear();
        bestFitnesses.clear();
    }
    
    /**
     * Retrieves the best <code>Evolvable</code> in the population. It is assumed that
     * <code>getBest</code> is called <i>after</i> <code>doStep</code>, therefore the
     * best population member will be equal to <code>outPopulation()[0]</code>.
     * @return the best <code>Evolvable</code> in the population.
     * @see #outPopulation
     */    
    public Evolvable getBest() {
        return outPopulation()[0];
    }
    
    /**
     * Retrieves the best fitness level. This works the same as <code>getBest</code>,
     * so the assumptions remain the same.
     * @return the best fitness in the population.
     */    
    public double getBestFitness() {
        return outPopulation()[0].getFitness();
    }
    
    /**
     * Return the average fitness of this generation.
     * @return the average fitness.
     */    
    public double getAverageFitness() {
        return averageFitness;
    }
    
    /**
     * Resets the genetic algorithm. This just calls <tt>init</tt>.
     * @see #init()
     */    
    public void reset() {
        init();
    }
    
    /**
     * Return the current iteration of the genetic algorithm.
     * @return the current iteration of the genetic algorithm.
     */    
    public int getCurrentIteration() {
        return currentIteration;
    }
    
    /**
     * Set the maximum number of data points that the GA should log.
     * @param mdp maximum number of data points to log.
     */    
    public void setMaximumDataPoints(int mdp) {
        maximumDataPoints = mdp;
    }
    
    /**
     * Returns the maximum number of data points the GA is logging.
     * @return the maximum data points.
     */    
    public int getMaximumDataPoints() {
        return maximumDataPoints;
    }
}
