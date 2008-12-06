/*
 * EvoDiophantine.java
 * Created on 26 July 2004, 11:45
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
 * <code>EvoDiophantine</code> is an example of a genetic algorithm solving a
 * diophantine equation. A diophantine equation is an integer-only equation of the
 * form <i>ax+by+cz...=t</i>. The class solves for the variables given the
 * coefficients <i>a, b, c</i> etc. and target <i>t</i>.
 * @author James Matthews
 */
public final class EvoDiophantine extends EvolveStandard {
    
    static private int[] coefficients;
    static private int targetValue;
    
    private int[] values;
    static private int minimumValue;
    static private int maximumValue;
    static private int numberRange;
    
    /** Creates a new instance of EvoDiophantine */
    public EvoDiophantine() {
        setRange(-500,500);
    }
    
    /**
     * Diophantine fitness is calculated as the error between the target value and the
     * calculated value.
     */    
    public void calculateFitness() {
        int sum = 0;
        for (int i=0; i<values.length; i++) {
            sum += coefficients[i] * values[i];
        }
        
        fitnessValue = Math.abs(targetValue - sum);
    }
    
    /**
     * Return the fitness of this object.
     */    
    public double getFitness() {
        return fitnessValue;
    }
    
    /**
     * One-point crossover of the equation values.
     * @param partner the other parent equation.
     * @return the new child equation.
     */    
    public Evolvable mate(Evolvable partner) {
        EvoDiophantine kid = new EvoDiophantine();
        EvoDiophantine p2  = (EvoDiophantine)partner;
        
        kid.values = new int[values.length];
        int crossover = (int)(Math.random() * values.length);
        for (int i=0; i<crossover; i++)
            kid.values[i] = values[i];
        for (int i=crossover; i<values.length; i++)
            kid.values[i] = p2.values[i];
        
        return kid;
    }
    
    /**
     * Mutates one of the equation values by a random value between -2 and 2.
     */    
    public void mutate() {
        int index = random.nextInt(values.length);
        int delta = random.nextInt(5) - 2;
        
        values[index] += delta;
    }
    
    /**
     * Initialize the equation values to a number within the specified range.
     * @see #setRange(int, int)
     */    
    public void randomInitialize() {
        values = new int[coefficients.length];

        for (int i=0; i<values.length; i++) {
            values[i] = randomValue();
        }
    }
    
    /**
     *
     */    
    private int randomValue() {
        return random.nextInt(numberRange) - Math.abs(minimumValue);
    }
    
    /**
     * Set the range the genetic algorithm checks between.
     * @param min minimum value.
     * @param max maximum value.
     */    
    public void setRange(int min, int max) {
        minimumValue = min;
        maximumValue = max;
        
        numberRange = (int)(Math.abs(min) + Math.abs(max));
    }
    
    /**
     *
     * @return a string with the equation and current fitness.
     */    
    public String toString() {
        String strValue = coefficients[0] + "(" + values[0] + ")";
        for (int i=1; i<values.length; i++) {
            strValue += " + " + coefficients[i] + "(" + values[i] + ")";
        }
        
        return strValue;/* + " [Fitness=" + getFitness() + "]";*/
    }
     
    /**
     * Set the coefficients and target of the equation. As a static member function,
     * this specifies the values for all members of the population.
     * @param coeff the coefficients.
     * @param target target value.
     */    
    static public void setCoefficients(int[] coeff, int target) {
        coefficients = coeff;
        targetValue = target;
    }
    
    /**
     * Run the genetic algorithm on the specified coefficients and target values. If
     * nothing is specified, a+2b+3c+4d=50 is attempted. The GA runs for a maximum of
     * 1000 iterations or until fitness reaches zero.
     * @param args coefficients and target value to run the GA on.
     */
    public static void main(String[] args) {
        EvoDiophantine[] dio = new EvoDiophantine[64];
        
        for (int i=0; i<dio.length; i++) {
            dio[i] = new EvoDiophantine();
        }
        
        int target;
        int[] equation;
        if (args.length > 1) {
            equation = new int[args.length - 1];
            for (int i=0; i<args.length-1; i++) {
                equation[i] = Integer.parseInt(args[i]);
            }
            target = Integer.parseInt(args[args.length-1]);
        } else {
            equation = new int[4];
            equation[0] = 1;    // a 
            equation[1] = 2;    // b
            equation[2] = 3;    // c
            equation[3] = 4;    // d
            target = 100;
        }
        
        EvoDiophantine.setCoefficients(equation, target);
        
        GeneticAlgorithm ga = new GeneticAlgorithm(dio);
        ga.init();
        
        int best = 100;
        int iterations = 0;
        
        do {
            ga.doStep();
            System.out.println(iterations + ":  " + ga.getBest() + ", f = " +
                               ga.getBestFitness());
            best = (int)ga.getBestFitness();
            iterations++;
        } while (iterations < 2500 && best != 0);
    }
}
