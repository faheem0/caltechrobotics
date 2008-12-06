/*
 * EvoHelloWorld.java
 * Created on 26 July 2004, 15:39
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

/**
 * Attempts to evolve a target string, defaulting to "Hello World!". All valid
 * digits are acceptable inputs for the string.
 *
 * @author James Matthews
 */
public class EvoHelloWorld extends EvolveStandard {
    
    /**
     * The mutable data string.
     */    
    protected StringBuffer dataString = new StringBuffer();
    /**
     * The target string to evolve.
     */    
    static protected String targetString = "Hello World!";
    
    /** Creates a new instance of EvoHelloWorld */
    public EvoHelloWorld() {
    }
    
    /**
     * Run the genetic algorithm with a target string. The best population member is
     * printed for every iteration.
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        EvoHelloWorld[] hw = new EvoHelloWorld[64];

        if (args.length > 0) {
            // Retrieve the arguments, accounting for spaces.
            StringBuffer buf = new StringBuffer();
            for (int i=0; i<args.length-1; i++) buf.append(args[i] + " ");
            EvoHelloWorld.targetString = buf.toString() + args[args.length-1];
        }
        
        for (int i=0; i<hw.length; i++) {
            hw[i] = new EvoHelloWorld();
        }
        
        GeneticAlgorithm ga = new GeneticAlgorithm(hw);
        ga.init();
        
        int best = 100;
        int iterations = 0;
        
        do {
            ga.doStep();
            System.out.println(iterations + ":  " + ga.getBest() + ", f = " +
                               ga.getBestFitness());
            best = (int)ga.getBestFitness();
            iterations++;
        } while (iterations < 1000 && best != 0);
    }
    
    /**
     * The fitness is calculated as the sum of the differences between the data string
     * and the target string.
     */    
    public void calculateFitness() {
        fitnessValue = 0;
        
        for (int i=0; i<dataString.length(); i++) {
            if (targetString.charAt(i) != dataString.charAt(i))
                fitnessValue += Math.abs(targetString.charAt(i) - dataString.charAt(i));
        }
    }
    
    /**
     * Mate two strings with a simple one-point crossover.
     * @param partner the partner string to mate with.
     * @return the new child string.
     */    
    public Evolvable mate(Evolvable partner) {
        int crossover = (int)(Math.random() * targetString.length());
        EvoHelloWorld kid = new EvoHelloWorld();
        EvoHelloWorld p2  = (EvoHelloWorld)partner;
        
        kid.dataString = new StringBuffer();
        kid.dataString.append(dataString.substring(0, crossover));
        kid.dataString.append(p2.dataString.substring(crossover));

        return kid;
    }
    
    /**
     * Mutate this string between -2 and +2 characters.
     */    
    public void mutate() {
        int point = random.nextInt(targetString.length());
        int delta = random.nextInt(5) - 2;
        
        if (Character.isDefined((char)(dataString.charAt(point)+delta))) {
            dataString.setCharAt(point, (char)(dataString.charAt(point)+delta));
        }
    }
    
    /**
     * Initialize the string to a random collection of characters. The size of the
     * string is fixed to that of the target string.
     */    
    public void randomInitialize() {
        int targetLength = targetString.length();
        char randChar;
        
        for (int i=0; i<targetLength; i++) {
            do {
                randChar = (char)random.nextInt(128);
            } while (!(java.lang.Character.isDefined(randChar)));

            dataString.append(randChar);
        }
    }
    
    /**
     * Return an immutable version of dataString.
     * @see #dataString
     * @return the data string.
     */    
    public String toString() {
        return dataString.toString();/* + " [Fitness=" + getFitness() + "]";*/
    }
    
    /**
     * Return the target string being evolved. This defaults to "Hello World!".
     * @return the target string.
     */    
    public static String getTargetString() {
        return targetString;
    }
    
    /**
     * Set the target string.
     * @param ts the new target string.
     */    
    public static void setTargetString(String ts) {
        targetString = ts;
    }
}
