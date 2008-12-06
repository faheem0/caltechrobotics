/*
 * EvoTravellingSalesman.java
 * Created on 09 August 2004, 16:55
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

package org.generation5.demos;

import org.generation5.*;
import org.generation5.bio.*;
import org.generation5.util.*;

/**
 * This class implements a simple evolvable solution to the travelling
 * salesman problem.
 * @author James Matthews
 */
public class EvoTravellingSalesman extends TravellingSalesman implements Evolvable {
    
    /** The fitness value. */    
    protected double fitnessValue = -1.0;
    /**
     * An instance of java.util.Random, useful for generating a range of random numbers.
     */    
    static protected java.util.Random random = new java.util.Random();
    
    /** Creates a new instance of EvoTravellingSalesman */
    public EvoTravellingSalesman() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        int nc = 25;
        
        EvoTravellingSalesman[] population = new EvoTravellingSalesman[256];
        for (int i=0; i<population.length; i++)
            population[i] = new EvoTravellingSalesman();
        EvoTravellingSalesman.setMaximumCities(nc);
        EvoTravellingSalesman.setDimension(640, 480);
        
        for (int i=0; i<nc; i++) {
            int x = random.nextInt(EvoTravellingSalesman.getDimensionX());
            int y = random.nextInt(EvoTravellingSalesman.getDimensionY());
            
            EvoTravellingSalesman.addCity(x, y);
            System.out.println("City added at (" + x + "," + y + ").");
        }
        
        GeneticAlgorithm ga = new GeneticAlgorithm(population);
        ga.init();
        ga.setMutationRate(0.25);
        
        double best = 0, bestsofar = Double.MAX_VALUE;
        int iterations = 0;
        EvoTravellingSalesman bestRoute;
        
        do {
            ga.doStep();
            best = ga.getBestFitness();
            System.out.println(iterations + ":  " + ga.getBest() + ", f = " +
                               ga.getBestFitness());
            if (iterations == 1) {
                bestRoute = (EvoTravellingSalesman)ga.getBest();
                bestRoute.writeImage("evotsp-first.png", 640, 480);
            }
            iterations++;
        } while (iterations < 10000);
        
        bestRoute = (EvoTravellingSalesman)ga.getBest();
        bestRoute.writeImage("evotsp-last.png", 640, 480);
    }
    
    /**
     * Returns the route as a string.
     * @return the route being used.
     */    
    public String toString() {
        String strRoute = "";
        for (int i=0; i<route.length; i++)
            strRoute += route[i] + " -> ";
        return strRoute + "[length=" + getFitness() + "].";
    }
    
    /**
     * Calculate the fitness of this route. This is simply done by return the route
     * length.
     */    
    public void calculateFitness() {
        fitnessValue = routeLength();
    }
    
    /**
     * Mate two routes together.
     * @param partner Partner object.
     * @return the child route.
     */    
    public Evolvable mate(Evolvable partner) {
        EvoTravellingSalesman kid = new EvoTravellingSalesman();
        EvoTravellingSalesman p2  = (EvoTravellingSalesman)partner;
        
        boolean all[] = new boolean[numberCities];
        
        kid.route = new int[numberCities];
        kid.route[0] = this.route[0];
        all[route[0]] = true;
        
        double d1, d2;
        for (int i=1; i<numberCities; i++) {
            d1 = getCityDistance(kid.route[i-1], route[i]);
            d2 = getCityDistance(kid.route[i-1], p2.route[i]);

            if (d1 <= d2 && all[route[i]] == false) {
                kid.route[i] = route[i];
                all[route[i]] = true;
            } else if (d2 < d1 && all[p2.route[i]] == false) {
                kid.route[i] = p2.route[i];
                all[p2.route[i]] = true;
            } else {
                do {
                    kid.route[i] = random.nextInt(numberCities);
                } while (all[kid.route[i]] == true);
                
                all[kid.route[i]] = true;
            }
        }

        return kid;
    }
    
    /**
     * Mutates a route.
     */    
    public void mutate() {
        int r = random.nextInt(route.length);
        flip(r, (r+1) % route.length);
        flip(random.nextInt(route.length), random.nextInt(route.length));
    }
    
    /**
     * Initialize the route randomly.
     */    
    public void randomInitialize() {
        route = new int[maximumCities];
        int rl = numberCities;
        for (int i=0; i<rl; i++) route[i] = i;

        for (int i=0; i<rl*2; i++)
            flip(random.nextInt(route.length), random.nextInt(route.length));
    }

    /**
     * Flip two route positions. Used by initializing and mutation routines.
     * @param i1 the first index.
     * @param i2 the second index.
     */    
    protected void flip(int i1, int i2) {
        int temp  = route[i1];
        route[i1] = route[i2];
        route[i2] = temp;
    }
    
    /**
     * Implementation for the <code>Comparable</code> interface. Compares two route's
     * length.
     * @param o object to compare to.
     * @return fitnessValue < o.fitnessValue
     */    
    public int compareTo(Object o) {
        EvoTravellingSalesman object = (EvoTravellingSalesman)o;
        
        if (fitnessValue < object.fitnessValue) return -1;
        if (fitnessValue > object.fitnessValue) return  1;
        
        return 0;
    }
    
    /**
     * Return the fitness of this route.
     * @return the fitness of the route (route length).
     */    
    public double getFitness() {
        return fitnessValue;
    }
}
