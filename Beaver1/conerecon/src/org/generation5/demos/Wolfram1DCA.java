/*
 * Wolfram1DCA.java
 * Created on 18 July 2004, 18:45
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

import java.awt.*;
import org.generation5.bio.*;

/**
 * Implements Wolfram's one-dimensional cellular automata. The class
 * allows for a large neighbourhood size, and supports smooth scrolling
 * of the rendered region.
 * @author James Matthews
 */
public class Wolfram1DCA extends CellularAutomata {
    
    /**
     * The neighbourhood size.
     */    
    protected int neighbourSize = 3;
    
    /**
     * Default constructor.
     */    
    public Wolfram1DCA() {
        this(0, 0);
    }
    
    /**
     * Create an instance with world size information.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public Wolfram1DCA(int size_x, int size_y) {
        this(size_x, size_y, RANDOM);
    }
    
    /**
     * Create an instance with world size information as well as
     * a starting state.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     * @param initType the initial state of the world, either RANDOM or MIDPOINT.
     */    
    public Wolfram1DCA(int size_x, int size_y, int initType) {
        super(size_x, size_y);
        stepPosition = 0;
        neighbourSize = 3;
        ruleSpecifier = 126;
        initialState = RANDOM;
        initialState = initType;
        setRules(3, 126);
    }
    
    /**
     * Advance the world by one timestep. This means calculating one line of the CA.
     */    
    public void doStep() {
        stepPosition = translateGeometry(stepPosition + 1, Y_AXIS);
        if (stepPosition == 0)  isScrolling = true;
        
        int dx = (neighbourSize - 1) / 2;
        int state = 0, shift = 0;
        int stepAbove = stepPosition - 1;
        for(int i = 0; i < caWorld_x; i++) {
            state = 0;
            shift = 0;
            // Calculate the rule required
            for (int n=i-dx; n<=i+dx; n++) {
                state += (getWorldAt(n, stepAbove) << shift);
                shift += 1;
            }
            
            if (caRules[state] == 1)
                setWorldAt(i, stepPosition, 1);
            else
                setWorldAt(i, stepPosition, 0);
        }
    }
    
    /**
     * Return the rule specifier.
     * @return the rule specifier.
     */    
    public long getRules() {
        return ruleSpecifier;
    }
    
    /**
     * Sets the neighbourhood size and the rule specifier.
     * @param neighbours the neighbourhood size.
     * @param rule the rule specifier.
     */    
    public void setRules(int neighbours, long rule) {
        if (neighbours % 2 == 0) return;
        if (neighbours < 0 || neighbours > 13) return;
        
        int size = (int)Math.pow(2, neighbours);
        caRules = new int[size];
        for(int i = 0; i < size; i++) {
            if ((rule >> i) % 2 == 1) {
                caRules[i] = 1;
            } else {
                caRules[i] = 0;
            }
        }
        
        ruleSpecifier = rule;
        neighbourSize = neighbours;
    }
    
    /**
     * Retrieves the inital state type - either random or midpoint.
     * @return returns either RANDOM or MIDPOINT.
     */    
    public int getInitialState() {
        return initialState;
    }
    
    /**
     * Set the initial world state.
     * @param initState set to either RANDOM or MIDPOINT.
     */    
    public void setInitialState(int initState) {
        initialState = initState;
    }
    
    /**
     * Initializes the 1D CA.
     */    
    public void init() {
        clearWorld();
        stepPosition = 0;
        isScrolling = false;
        if (initialState == RANDOM) {
            for (int i = 0; i < caWorld_x; i++)
                if (Math.random() < 0.5) {
                    setWorldAt(i, 0, 1);
                }
        } else {
            setWorldAt(caWorld_x / 2, 0, 1);
        }
        
        setWorldColour(0, Color.white);
        setWorldColour(1, Color.darkGray);
    }
    
    /**
     * Renders the 1D cellular automata. This overrides the usual
     * render function to scroll the CA data once the number of timesteps
     * is greater than the height of the rendering area.
     * @param graphics the graphics context.
     * @param pw the width of the context.
     * @param ph the height of the context.
     * @see CellularAutomata#render(Graphics, int, int)
     */    
    public void render(Graphics graphics, int pw, int ph) {
        if (!isScrolling) {
            super.render(graphics, pw, ph);
            return;
        }
        // We are overloading the default rendering procedure to
        // allow for smooth scrolling.
        graphics.setColor(clrBackground);
        graphics.fillRect(0, 0, pw, ph);
        // cx/cy is the size of the CA world with
        // the size in pixels factored in.
        int cx = getSizeX() * caSize;
        int cy = getSizeY() * caSize;
        // sx/sy are the starting points for the CA world
        // centred within the the graphics context.
        int sx = (int)((double)(pw - cx) / 2.0);
        int sy = (int)((double)(ph - cy) / 2.0);
        // draw the default state of the world
        graphics.setColor(clrWorld[0]);
        graphics.fillRect(sx, sy, cx, cy);
        
        // draw the ca world
        int dh = 0;
        for(int j = stepPosition+1; j < getSizeY(); j++) {
            for(int i = 0; i < getSizeX(); i++) {
                int state = getWorldAt(i, j);
                if(state != 0) {
                    graphics.setColor(clrWorld[state]);
                    graphics.fillRect(sx + i * caSize, sy + dh * caSize, caSize, caSize);
                }
            }
            dh++;
        }
        for(int j = 0; j < stepPosition+1; j++) {
            for(int i = 0; i < getSizeX(); i++) {
                int state = getWorldAt(i, j);
                if(state != 0) {
                    graphics.setColor(clrWorld[state]);
                    graphics.fillRect(sx + i * caSize, sy + dh * caSize, caSize, caSize);
                }
            }
            dh++;
        }
        
        // draw a grid if neccessary
        if (caSize > 2 && drawGrid) {
            graphics.setColor(clrGrid);
            for (int i=sx-1; i<(sx+cx-1); i+=caSize) {
                graphics.drawLine(i,sy,i,sy+cy);
            }
            for (int i=sy-1; i<(sy+cy-1); i+=caSize) {
                graphics.drawLine(sx,i,sx+cx,i);
            }
        }
        // draw a bordering rectangle
        graphics.setColor(Color.black);
        graphics.drawRect(sx - 1, sy - 1, cx + 1, cy + 1);
    }
    
    /**
     *
     * @param args the command-line arguments to pass to iterateCA.
     */    
    public static void main(String args[]) {
        Wolfram1DCA wolfram = new Wolfram1DCA();
        
        if (args.length != 3) {
            System.out.println("Usage: java wolfram neighbourhood rule iterations");
//            System.out.println("  neighbourhood - the neighbourhood size");
//            System.out.println("  rule          - the rule specifier");
//            System.out.println("  iterations    - number of iterations to run.");
            System.out.println();

            return;
        }
        
/*        wolfram.setWorldSize(Integer.parseInt(args[2]) / 4,
                             Integer.parseInt(args[2]));*/
        wolfram.setWorldSize(640, 480);
        
        wolfram.init();
        wolfram.setRules(Integer.parseInt(args[0]), 
                         Integer.parseInt(args[1]));
        
        String[] arguments = {
            args[2],
            "100",
            "wolf-Rule-"+args[1]+"-",
            "1"
        };
        
        iterateCA(wolfram, arguments);
    }
    
    private int caRules[];
    private int stepPosition;
    private boolean isScrolling = false;
    /**
     * The rule specifier. This is a single digit number that encodes
     * the rules.
     */    
    protected long ruleSpecifier;
    /**
     * The initial state of the CA, either RANDOM or MIDPOINT.
     */    
    protected int initialState;
    /** Start the CA with an random line */
    public static int RANDOM = 0;
    /** Start the CA with one mid point */
    public static int MIDPOINT = 1;
    
}
