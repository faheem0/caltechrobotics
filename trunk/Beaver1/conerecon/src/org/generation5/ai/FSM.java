/*
 * FSM.java
 * Created on 28 September 2004, 13:05
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

package org.generation5.ai;

import java.util.*;
import org.generation5.*;
import org.generation5.util.*;

/**
 * Implements a finite-state machine. This class implements the <code>Visualizable</code>
 * interface to display the FSM in a graphics context.
 * @author James Matthews
 */
public class FSM implements Visualizable {
    /**
     * The number of states in the FSM.
     */    
    protected int numStates = 0;
    /**
     * The current state in the FSM is in.
     */    
    protected State currentState = null;
    /**
     * An array of the states in the finite-state machine.
     */    
    protected State[] fsmStates = null;
    
    /**
     * The size of the states to be rendered.
     */    
    protected int renderSize = 25;
    
    /** Creates a new instance of FSM */
    public FSM() {
        this(32);
    }
    
    /**
     * Creates a new instance of FSM, with the maximum number of allowed states.
     * @param maxStates the maximum number of states allowed in the FSM.
     */    
    public FSM(int maxStates) {
        fsmStates = new State[maxStates];
        numStates = maxStates;
    }
    
    /**
     * Creates a new instance of FSM with an initial state.
     * @param initialState the initial state.
     */    
    public FSM(State initialState) {
        this();
        addState(initialState);
        setState(initialState);
    }
    
    /**
     * Creates a new instance of FSM with an initial state and the maximum allowed states.
     * @param maxStates the maximum number of states.
     * @param initialState the initial state.
     */    
    public FSM(int maxStates, State initialState) {
        this(maxStates);
        addState(initialState);
        setState(initialState);
    }
    
    /**
     * Return the current state the FSM is in.
     * @return the current state.
     */    
    public State getCurrentState() {
        return currentState;
    }
    
    /**
     * Return the number of states in the FSM.
     * @return the number of states.
     */    
    public int getStates() {
        return numStates;
    }
    
    /**
     * Set the current state of the finite-state machine.
     * @param state the state.
     */    
    public void setState(State state) {
        currentState = state;
    }
    
    /**
     * Add a state to the FSM.
     * @param state the state to be added to the FSM.
     * @return the number of states currently in the FSM.
     */    
    public int addState(State state) {
        if (numStates == fsmStates.length)
            throw new IllegalArgumentException("cannot add an additional state.");
        
        fsmStates[numStates++] = state;
        
        return numStates;
    }
    
    /**
     * Adds an array of states to the FSM.
     * @param states the array of States to add to the FSM.
     * @return the number of states.
     */    
    public int addStates(State[] states) {
        numStates = states.length;
        fsmStates = states;
        
        return numStates;
    }
    
    /**
     * Remove all states.
     */    
    public void removeAllStates() {
        // Keep the array allocated, but remove the
        // states.
        for (int i=0; i<fsmStates.length; i++)
            fsmStates[i] = null;
    }
    
    /**
     * Add a transition to the finite state machine. Note that adding the transition to
     * the FSM is equivalent to adding a transition to the state itself:
     * <code>
     *  fsm.addTransition(state1, transition, state2);
     *  // ...is equivalent to:
     *  state1.addTransition(transition, state2);
     * </code>
     * @param start the start state.
     * @param transition the transition identifier.
     * @param end the end state.
     */    
    public void addTransition(State start, int transition, State end) {
        start.addTransition(transition, end);
    }
    
    /**
     * Transition the FSM from one state to another with a given transition identifier.
     * This function will throw a <code>NullPointerException</code> if the transition
     * isn't defined for the current state.
     * @param transition the transition identifier.
     * @return the new state of the FSM.
     */    
    public State transition(int transition) {
        State newState = currentState.transition(transition);
        
        if (newState == null)
            throw new NullPointerException("transition not defined for this state.");
        
        currentState = newState;
        
        return currentState;
    }
    
    /**
     * Retrieve the given state from the FSM.
     * @param i the index of the state to return.
     * @return the state at this index.
     */    
    public State getState(int i) {
        return fsmStates[i];
    }
    
    /**
     * A simple test function.
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        State state1 = new State("State 1");
        State state2 = new State("State 2");
        State state3 = new State("State 3");
        FSM fsm = new FSM(state1);
        
        fsm.addState(state1);
        fsm.addState(state2);
        fsm.addState(state3);

        fsm.addTransition(state1, 0, state2);
        fsm.addTransition(state1, 1, state3);
        fsm.addTransition(state2, 0, state1);
        
        System.out.println(fsm.getCurrentState());
        fsm.transition(0);
        System.out.println(fsm.getCurrentState());
        fsm.transition(0);
        System.out.println(fsm.getCurrentState());
        fsm.transition(1);
        System.out.println(fsm.getCurrentState());
    }
    
    /**
     * Set the size (in pixels) to render the states.
     * @param rs the new render size.
     */    
    public void setRenderSize(int rs) {
        renderSize = rs;
    }
    
    /**
     * Return the current render size.
     * @return the render size.
     */    
    public int getRenderSize() {
        return renderSize;
    }

    /**
     * Render the FSM in a graphics context. The function renders all connections first,
     * then the states themselves.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        g.setColor(java.awt.Color.WHITE);
        g.fillRect(0, 0, width, height);
        g.setColor(java.awt.Color.BLACK);
        for (int i=0; i<numStates; i++) 
            fsmStates[i].renderConnections(g, width, height, renderSize);
        
        for (int i=0; i<numStates; i++) {
            if (fsmStates[i] == currentState)
                g.setColor(new java.awt.Color(0, 0, 128));
            else 
                g.setColor(new java.awt.Color(225, 225, 225));
            
            fsmStates[i].render(g, width, height, renderSize);
        }
    }
    
    /**
     * Write the FSM to an image.
     * @param s the filename of the image.
     * @param width the width of the image.
     * @param height the height of the image.
     */    
    public void writeImage(String s, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch(java.io.IOException e) {
            System.err.println(e);
        }
    }
    
    /**
     * The FSM states. The default FSM State simply stores a hash table with transitions
     * along with a state name.
     */    
    public static class State {
        /**
         * The name of the state.
         */        
        protected String stateName;
        /**
         * The hash table that stores the transitions.
         */        
        protected Hashtable transitionHash = new Hashtable();
        
        /**
         * The X-position of the state.
         */
        protected double positionX = 0.0;
        
        /**
         * The Y-position of the state.
         */        
        protected double  positionY = 0.0;
        
        /**
         * Specifies whether this FSM node is self-referential. This is required for rendering
         * purposes only.
         */        
        protected boolean selfReferring = false;

        /**
         * Create a new instance of State. Set the name to an empty string.
         */        
	public State() {
	    this("", 0.0, 0.0);
        }
        
        /**
         * Create a new instance of State, with the state name.
         * @param name the state name.
         */        
        public State(String name) {
            this(name, 0.0, 0.0);
        }
        
        /**
         * Create a new instance of the State with name and positional information.
         * @param name the state name.
         * @param x the x-position of the state.
         * @param y the y-position of the state.
         */        
        public State(String name, double x, double y) {
            stateName = name;
            positionX = x;
            positionY = y;
        }
        
        /**
         * Set the name of the state post-construction.
         * @param name the name of the state.
         */        
        public void setName(String name) {
            stateName = name;
        }
        
        /**
         * Is this node self-referential?
         * @return Return whether the node is self-referential.
         */        
        public boolean isSelfReferring() {
            return selfReferring;
        }
        
        /**
         * Sets whether the node is self-referential or not.
         * @param sr true if self-referential, otherwise false.
         */        
        public void setSelfReferring(boolean sr) {
            selfReferring = sr;
        }
        
        /**
         * Add a transition to the state.
         * @param transition the transition identifier.
         * @param endState the end state.
         */        
        public void addTransition(int transition, State endState) {
            transitionHash.put(new Integer(transition), endState);            
            // Not particularly necessary, but keeps consistency.
            if (endState == this) selfReferring = true;
        }
        
        /**
         * Transition this state given the transition identifier. Note that the state itself
         * does not make any sort of transition, but returns the new state for the FSM to
         * handle. If the given transition is not defined, null is returned.
         * @param transition the transition identifier.
         * @return the resultant state.
         */        
        public State transition(int transition) {
            return (State)transitionHash.get(new Integer(transition));
        }
        
        /**
         * Returns the name of the state.
         * @return the name of the state.
         */        
        public String toString() {
            return stateName;
        }
        
        /**
         * Set the position of the state. An <code>IllegalArgumentException</code> will be
         * thrown if either position is less than 0.0 or greater than 1.0.
         * @param x the x-position of the state.
         * @param y the y-position of the state.
         */        
        public void setPosition(double x, double y) {
            if (positionX < 0 || positionX > 1.0)
                throw new IllegalArgumentException("x out of bounds.");
            if (positionY < 0 || positionY > 1.0)
                throw new IllegalArgumentException("y out of bounded.");
            
            positionX = x;
            positionY = y;
        }
        
        /**
         * Retrieve the x-position of the state.
         * @return the x-position.
         */        
        public double getPositionX() {
            return positionX;
        }
        
        /**
         * Retrieve the y-position of the state.
         * @return the y-position.
         */        
        public double getPositionY() {
            return positionY;
        }

        /**
         * Render the connections from this state.
         * @param g the graphics context.
         * @param width the width of the context.
         * @param height the height of the context.
         * @param size the size of the states.
         */        
        public void renderConnections(java.awt.Graphics g, int width, int height, int size) {
            int px, py, px2, py2;
            int halfSize = size / 2;
            java.util.Set keys = transitionHash.keySet();
            Object[] transition = keys.toArray();
            State transitionState;

            px = (int)(positionX * width);
            py = (int)(positionY * height);
            
            for (int i=0; i<transition.length; i++) {
                transitionState = (State)transitionHash.get(transition[i]);
                
                px2 = (int)(transitionState.getPositionX() * width);
                py2 = (int)(transitionState.getPositionY() * height);
                
                if (transitionState == this || transitionState.isSelfReferring() == true)
                    g.drawOval(px-halfSize, py-size, size, size);
                else
                    g.drawLine(px, py, px2, py2);
            }
        }
        
        /**
         * Renders the state. State positions must be specified in the construction of the
         * state or by <code>setPosition</code>. Positions are specified using a double
         * between 0.0 and 1.0 (for example, <code>setPosition(0.5, 0.5)</code> will render
         * the state in the centre of the graphics context).
         * @param g the graphics context.
         * @param width the width of the context.
         * @param height the height of the context.
         * @param size the size of the state.
         */        
        public void render(java.awt.Graphics g, int width, int height, int size) {
            int px, py, px2, py2;
            int halfSize = size / 2;
            
            px = (int)(positionX * width) - halfSize;
            py = (int)(positionY * height) - halfSize;
            
            g.fillOval(px, py, size, size);
            g.setColor(java.awt.Color.BLACK);
            g.drawOval(px, py, size-1, size-1);
        }
    }
}
