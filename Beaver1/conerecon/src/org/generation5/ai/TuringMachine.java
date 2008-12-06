/*
 * TuringMachine.java
 * Created on 04 October 2004, 13:59
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

import java.awt.*;
import java.awt.image.*;
import org.generation5.*;

/**
 * This class implements a Turing machine by deriving from a finite-state machine.
 * The tape is simply implemented as a tape&mdash;as such, the tape is not infinite.
 * You must allocate any space you want your Turing Machine to use in the tape itself.
 * @author James Matthews
 */
public class TuringMachine extends FSM implements Steppable {

    /**
     * Move the tape left.
     */    
    public final static int LEFT = 0;
    /**
     * Move the tape right.
     */    
    public final static int RIGHT = 1;
    /**
     * A final, stopping state.
     */    
    public final static int STOP = 2;
    /**
     * Move the machine left (equivalent to RIGHT).
     */    
    public final static int MACHINE_LEFT  = RIGHT;
    /**
     * Move the machine right (equal to LEFT).
     */    
    public final static int MACHINE_RIGHT = LEFT;
    /**
     * A final, stopping state (equivalent to STOP).
     */    
    public final static int MACHINE_STOP = STOP;
    /**
     * The machine acceptance state.
     */    
    public final static int ACCEPTED = 1;
    /**
     * The machine is in an undecided state.
     */    
    public final static int UNDECIDED = 0;
    /**
     * The machine rejection state.
     */    
    public final static int REJECTED = -1;
    
    /**
     * Set the render size of the Turing Machine as small.
     */    
    public final static int RENDER_SMALL  = 0;
    /**
     * Set the render size of the FSM/Turing Machine as normal.
     */    
    public final static int RENDER_NORMAL = 1;
    /**
     * Set the render size of the FSM/Turing Machine as large.
     */    
    public final static int RENDER_LARGE  = 2;
    
    /**
     * The input tape.
     */    
    protected StringBuffer inputTape;
    /**
     * The position the tape is in.
     */    
    protected int tapePosition = 0;
    /**
     * The state the machine is in (ACCEPTED, UNDECIDED, REJECTED).
     */    
    protected int machineState = UNDECIDED;
    /**
     * The direction the tape is moving in.
     */    
    protected int tapeDirection = LEFT;

    private int boxSize = 20;
    private int textOffsetX = 6;
    private int textOffsetY = 16;
    private int textSize = 16;
    private  int animOffset = boxSize;

    /** Creates a new instance of TuringMachine */
    public TuringMachine() {
    }
    
    /**
     * Return the current machine state.
     * @see #ACCEPTED
     * @see #REJECTED
     * @see #UNDECIDED
     * @return the machine state.
     */    
    public int getMachineState() {
        return machineState;
    }
    
    /**
     * Set the input tape. The initial input tape is converted to a mutable
     * <code>StringBuffer</code>. The initial position  also needs to be set.
     * @param input the input string.
     * @param start the tape position.
     */    
    public void setInputTape(String input, int start) {
        setInputTape(new StringBuffer(input), start);
    }
    
    /**
     * Set the tape direction.
     * @param td the tape direction (LEFT or RIGHT).
     */    
    public void setTapeDirection(int td) {
        tapeDirection = td;
        if (tapeDirection == LEFT)  animOffset =  boxSize;
        if (tapeDirection == RIGHT) animOffset =  boxSize * -1;
    }
    
    /**
     * Set the input tape.
     * @param input A mutable <code>StringBuffer</code>.
     * @param start the initial tape position.
     * @see #setInputTape(String, int)
     */    
    public void setInputTape(StringBuffer input, int start) {
        inputTape = input;
        tapePosition = start;
        machineState = UNDECIDED;
    }
    
    /**
     * Transitions the Turing Machine from one state to another. If the transition
     * is not defined then the machine assumes that the input is valid and rejects it.
     * @param transition the transition input.
     * @return the new state.
     */    
    public State transition(int transition) {
        Transition transitionState = 
            (Transition)currentState.transition(transition);
        
        if (transitionState == null) {
            machineState = REJECTED;
            return null;
        }
        
        currentState = transitionState.nextState;
        inputTape.setCharAt(tapePosition, (char)transitionState.writeSymbol);
        tapeDirection = transitionState.tapeDirection;
        
        if (tapeDirection == TuringMachine.LEFT)
            tapePosition++;
        else if (tapeDirection == TuringMachine.RIGHT)
            tapePosition--;
        else if (tapeDirection == TuringMachine.STOP)
            machineState = ACCEPTED;
        
        return currentState;
    }
    
    /**
     * Add a transition state between the specified start and end states for the given
     * transition symbol.
     * @param start the start state.
     * @param transition the transition symbol.
     * @param end the end state.
     */    
    public void addTransition(State start, int transition, State end) {
        if (!(end instanceof Transition))
            throw new IllegalArgumentException("end state must be of type Transition.");
        
        Transition tend = (Transition)end;
        if (start == tend.nextState)
            end.setSelfReferring(true);
        
        super.addTransition(start, transition, end);
    }
   
    /**
     * This function simply runs the machine with a given input until the input
     * is accepted or rejected.
     * @param input the input tape.
     * @param start the start position of the tape.
     * @return the machine state returned.
     */    
    public int runMachine(String input, int start) {
        return runMachine(new StringBuffer(input), start);
    }
    
    /**
     * This function simply runs the machine with a given input until the input
     * is accepted or rejected.
     * @param input the input tape.
     * @param start the start position of the tape.
     * @return the machine state returned.
     */    
    public int runMachine(StringBuffer input, int start) {
        setInputTape(input, start);
        
        do {
            doStep();
        } while (getMachineState() == TuringMachine.UNDECIDED);
        
        return getMachineState();
    }
    
    /**
     * <code>doAnimate</code> animates the Turing Machine transitioning from one tape
     * position to the next. The animation system animates that tape moving left or
     * right.
     */    
    public void doAnimate() {
        // Only step if the machine is undecided
        if (machineState != UNDECIDED)
            return;
        
        if (tapeDirection == LEFT)
            animOffset -= 2;
        if (tapeDirection == RIGHT)
            animOffset += 2;
        if ((tapeDirection == LEFT  && animOffset == 0) ||
            (tapeDirection == RIGHT && animOffset == 0)) {
            transition(inputTape.charAt(tapePosition));
            
            if (machineState == UNDECIDED) {
                if (tapeDirection == LEFT)  animOffset = boxSize;
                if (tapeDirection == RIGHT) animOffset = boxSize * -1;
            }
        }
    }
    
    /**
     * Steps the Turing Machine using the tape position and input tape:
     * <code>
     *    transition(inputTape.charAt(tapePosition));
     * </code>
     */    
    public void doStep() {
        // Only step if the machine is undecided
        if (machineState != UNDECIDED)
            return;
        // Transition the machine
        transition(inputTape.charAt(tapePosition));        
        // In case animation is in progress when doStep is called,
        // reset the animation offsets to ensure everything looks nice.
        if (tapeDirection == LEFT)  animOffset = boxSize;
        if (tapeDirection == RIGHT) animOffset = boxSize * -1;
    }
    
    /**
     * Initializes the Turing Machine to its default settings. The tape direction as
     * LEFT and the machine state as UNDECIDED.
     */    
    public void init() {
        inputTape = null;
        animOffset = boxSize;
        machineState = UNDECIDED;
        tapePosition = LEFT;
    }
    
    /**
     * Resets the input tape, removes all the states and calls <code>init</code>.
     * @see #init()
     */    
    public void reset() {
        inputTape = null;
        removeAllStates();
        
        init();
    }
    
    /**
     * Converts the Turing Machine to a string. An example might be:
     * <code>
     * Tape = 1[ ]1, State = q1, Position = 4, I/O State = Undecided
     * </code>
     * Only the three most immediate tape characters are shown, as well as the current
     * state, tape position and machine state.
     * @return a string representation of the Turing Machine.
     */    
    public String toString() {
        StringBuffer machineString;
        
        if (tapePosition == 0) 
            machineString = new StringBuffer("Tape = " + ' ' + inputTape.substring(0, 2));
        else if (tapePosition == inputTape.length() - 1)
            machineString = new StringBuffer("Tape = " + inputTape.substring(inputTape.length() - 2, inputTape.length()) + ' ');
        else 
            machineString = new StringBuffer("Tape = " + inputTape.substring(tapePosition - 1, tapePosition + 2));

        machineString.insert(8, '[');
        machineString.insert(10, ']');
        
        machineString.append(", State = " + currentState);
        machineString.append(", Position = " + tapePosition);
        machineString.append(", I/O State = ");
        
        if (machineState == UNDECIDED) machineString.append("Undecided");
        if (machineState == ACCEPTED)  machineString.append("Accepted");
        if (machineState == REJECTED)  machineString.append("Rejected");
        
        return machineString.toString();
    }
    
    /**
     * Return the input tape in non-mutable String form.
     * @return the current input tape.
     */    
    public String getTape() {
        return inputTape.toString();
    }
    
    /**
     * Set the render size.
     * @param renderSize the render size.
     */    
    public void setRenderSize(int renderSize) {
        if (renderSize == RENDER_NORMAL) {
            boxSize = 20;
            textSize = 16;
            textOffsetX = 6;
            textOffsetY = 16;
            super.setRenderSize(20);
        } else if (renderSize == RENDER_SMALL) {
            boxSize = 16;
            textSize = 12;
            textOffsetX = 5;
            textOffsetY = 13;
            super.setRenderSize(15);
        } else if (renderSize == RENDER_LARGE) {
            boxSize = 30;
            textSize = 20;
            textOffsetX = 9;
            textOffsetY = 23;
            super.setRenderSize(25);
        } else {
            throw new IllegalArgumentException("render size invalid.");
        }
        
        animOffset = boxSize;
    }
    
    /**
     * Render the Turing Machine.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(Graphics g, int width, int height) {
        Graphics2D g2d = (Graphics2D)g;
        // Fill the background out
        g.setColor(new Color(255, 255, 192));
        g.fillRect(0, 0, width, height);
        // Exit if no input tape
        if (inputTape == null) return;
        // Set a bold font
        g2d.setFont(new Font("SansSerif", Font.PLAIN, textSize));
        // Calculate some commonly-used contacts
        int sx = width / 2  - boxSize / 2;
        int sy = height / 2 - boxSize / 2;
        int fontOffset = boxSize / 4;
        // Start drawing stuff!        
        if (machineState == UNDECIDED) g.setColor(new Color(64, 64, 255));
        if (machineState == ACCEPTED)  g.setColor(new Color(64, 255, 64));
        if (machineState == REJECTED)  g.setColor(new Color(255, 64, 64));
        
        g.fillRect(sx, 0, boxSize + 1, height);
        
        g.setColor(java.awt.Color.BLACK);

        // Draw characters to the left of the tape position
        for (int i=0; i<tapePosition; i++) {
            g.setColor(Color.WHITE);
            g.fillRect(sx - (boxSize * (tapePosition - i)) + animOffset, sy, boxSize, boxSize);
            g.setColor(Color.BLACK);
            g.drawRect(sx - (boxSize * (tapePosition - i)) + animOffset, sy, boxSize, boxSize);
            g.drawString(inputTape.substring(i, i + 1),
                         sx - (boxSize * (tapePosition - i)) + textOffsetX + animOffset, sy + textOffsetY);
        }
        // Draw character from the tape position 
        for (int i=tapePosition; i<inputTape.length(); i++) {
            g.setColor(Color.WHITE);
            g.fillRect(sx + (boxSize * (i - tapePosition)) + animOffset, sy, boxSize, boxSize);
            g.setColor(Color.BLACK);
            g.drawRect(sx + (boxSize * (i - tapePosition)) + animOffset, sy, boxSize, boxSize);
            g.drawString(inputTape.substring(i, i + 1),
                         sx + (boxSize * (i - tapePosition)) + textOffsetX + animOffset, sy + textOffsetY);
        }
        // FIXME: Temporary measure!
        for (int i=inputTape.length(); i<50; i++) {
            g.setColor(Color.WHITE);
            g.fillRect(sx + (boxSize * (i - tapePosition)) + animOffset, sy, boxSize, boxSize);
            g.setColor(Color.BLACK);
            g.drawRect(sx + (boxSize * (i - tapePosition)) + animOffset, sy, boxSize, boxSize);
            
            if (sx + (boxSize * (i - tapePosition)) > width) break;
        }
        for (int i=0; i>-50; i--) {
            g.setColor(Color.WHITE);
            g.fillRect(sx - (boxSize * (tapePosition - i)) + animOffset, sy, boxSize, boxSize);
            g.setColor(Color.BLACK);
            g.drawRect(sx - (boxSize * (tapePosition - i)) + animOffset, sy, boxSize, boxSize);

            if (sx - (boxSize * (tapePosition - i)) < (boxSize * -1)) break;
        }
        
        // Draw the FSM.
//        java.awt.image.BufferedImage fsmBI = new java.awt.image.BufferedImage(100, 25, 1);
//        super.render(fsmBI.getGraphics(), fsmBI.getWidth(), fsmBI.getHeight());
//        g.drawImage(fsmBI, width - 105, height - 30, null);
    }
    
    /**
     * Render the Turing Machine as a finite-state machine.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void renderAsFSM(Graphics g, int width, int height) {
        super.render(g, width, height);
    }
    
    /**
     * This class handles the Turing Machine transitions. Turing Machine transitions
     * are a little more complicated than finite state machine transitions since tape
     * direction and write symbols need to be accounted for.
     */    
    public static class Transition extends State {
        /**
         * The next state.
         */        
        protected State nextState;
        /**
         * The write symbol.
         */        
        protected int writeSymbol;
        /**
         * The new tape direction.
         */        
        protected int tapeDirection;
        
        /**
         * The default constructor that specifies the next state, the write symbol and tape
         * direction. Note that the state self-sets its position according to the position
         * of the next state.
         * @param state the next state.
         * @param write the write symbol.
         * @param tape the tape direction.
         */        
        public Transition(State state, int write, int tape) {
            nextState = state;
            writeSymbol = write;
            tapeDirection = tape;
            // Set position to be that of the next state.
            setPosition(nextState.positionX, nextState.positionY);
        }
    }
}
