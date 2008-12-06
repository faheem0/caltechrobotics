/*
 * LSystem.java
 * Created on 11 July 2004, 11:24
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

import java.awt.*;
import java.io.*;
import java.util.Stack;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

import org.generation5.Visualizable;
import org.generation5.util.*;

/**
 * The class provides basic L-System functionality.
 *
 * @author James Matthews
 */
public class LSystem implements Visualizable
{
    /**
     * Default constructor.
     */    
    public LSystem() {
        this("");
    }

    /**
     * Constructor with initial rule specifier (axiom)
     * @param initial Initial rule (the axiom).
     */    
    public LSystem(String initial) {
        rules = new String[26];
        maxDepth = 4;
        segmentSize = 6D;
        stepSize = 0.65D;
        baseAngle = 90D;
        initialAngle = 0.0D;
        startX = 0;
        startY = 0;
        initialX = 0;
        initialY = 0;
        clrBackground = Color.white;
        clrForeground = Color.black;
        stateStack = new Stack();
        axiom = initial;
        initializeRules();
    }

    /**
     * Initializes the rules to be self-referential, essentially resetting them.
     */    
    public void initializeRules() {
        for(int i = 0; i < 26; i++)
            rules[i] = String.valueOf(65 + i);
    }

    /**
     * Set the axiom. This is the initial rule that the L-System follows.
     * @param axiom the axiom to use.
     */    
    public void setAxiom(String axiom) {
        this.axiom = axiom;
    }

    /**
     * Retrieve the axiom used.
     * @return the axiom in use.
     */    
    public String getAxiom() {
        return axiom;
    }

    /**
     * Set the rule for the given character. The rules are specified using the uppercase
     * letters A through Z. Within the L-System, each instance of the letter <i>replace</i>
     * is replaced by <i>rule</i>, recursively until the maximum depth is reached.
     * @param replace the letter of the rule.
     * @param rule the rule itself.
     */    
    public void setRule(char replace, String rule) {
        if (Character.isUpperCase(replace) && Character.isLetter(replace))
            rules[replace - 65] = rule;
        else
            throw new IllegalArgumentException("must be uppercase letter (A-Z)");
    }

    /**
     * Retrieve the rule for the specified letter.
     * @param replace the rule to retrieve.
     * @return a string denoting the rule.
     */    
    public String getRule(char replace) {
        return applyRule(replace);
    }

    /**
     * Set the parameters for the L-System.
     * @param angle the angle at which the +/- parameters rotate the L-System by.
     * @param initAngle the initial angle the L-System starts at.
     * @param seg the segment length.
     * @param step the step size. This is the amount the L-System should multiply the step
     * size by for different depth.
     */    
    public void setParameters(double angle, double initAngle, int seg, double step) {
        baseAngle = angle;
        initialAngle = initAngle;
        segmentSize = seg;
        stepSize = step;
    }

    /**
     * Set the maximum depth the L-System should recursively draw.
     * @param depth the depth.
     */    
    public void setDepth(int depth) {
        maxDepth = depth;
    }

    /**
     * Set the initial starting point to draw the L-System at.
     * @param sx the starting x-point.
     * @param sy the starting y-point.
     */    
    public void setStartPoint(int sx, int sy) {
        initialX = sx;
        initialY = sy;
    }

    /**
     * Draw the L-System. Note that the class does no testing whether the L-System is
     * drawn within bounds.
     * @param graphics the graphics context.
     * @param pw the context width.
     * @param ph the context height.
     */    
    public void render(Graphics graphics, int pw, int ph) {
        graphics.setColor(clrBackground);
        graphics.fillRect(0, 0, pw, ph);
        startX = initialX;
        startY = initialY;
        graphics.setColor(clrForeground);
        drawLSystem(axiom, initialAngle, 0, graphics);
    }

    double degToRadians(double angle) {
        return (angle * 3.1415926535897931D) / 180D;
    }

    /**
     * Draws the L-System itself. The function is called recursively as the L-System
     * rules specify.
     * @param strLSystem the L-System axiom.
     * @param angle the current angle.
     * @param depth the current depth.
     * @param graphics the graphics context.
     */    
    protected void drawLSystem(String strLSystem, double angle, int depth, Graphics graphics) {
        double old = 0.0D;
        int number = 0;
        int length = strLSystem.length();
        for(int i = 0; i < length; i++) {
            char at = strLSystem.charAt(i);
            if (depth < maxDepth && at >= 'A' && at <= 'Z') {
                old = segmentSize;
                segmentSize = (int)(segmentSize * stepSize);
                if(segmentSize % 2D != 0.0D)
                    segmentSize--;
                drawLSystem(applyRule(at), angle, depth + 1, graphics);
                segmentSize = old;
                continue;
            }
            
            if (at == 'F' || at == '|') {
                int mx = (int)Math.round((double)startX + segmentSize * Math.cos(degToRadians(angle)));
                int my = (int)Math.round((double)startY + segmentSize * Math.sin(degToRadians(angle)));
                graphics.drawLine(startX, startY, mx, my);
                startX = mx;
                startY = my;
                continue;
            }
            
            if (at == 'G') {
                int mx = (int)Math.round((double)startX + segmentSize * Math.cos(degToRadians(angle)));
                int my = (int)Math.round((double)startY + segmentSize * Math.sin(degToRadians(angle)));
                startX = mx;
                startY = my;
                continue;
            }
            
            if (at == '+') {
                number = number == 0 ? 1 : number;
                angle = angleIncrement(angle, baseAngle * (double)number);
                number = 0;
                continue;
            }
            
            if (at == '-') {
                number = number == 0 ? 1 : number;
                angle = angleDecrement(angle, baseAngle * (double)number);
                number = 0;
                continue;
            }
            
            if (at == '[') {
                number = 0;
                pushState(angle, startX, startY);
                continue;
            }
            
            if (at == ']') {
                number = 0;
                angle = popState();
                continue;
            }
            
            if (at >= '0' && at <= '9')
                number = number * 10 + (at - 48);
        }

    }

    String applyRule(char at) {
        return rules[at - 65];
    }

    double angleIncrement(double ang, double increment) {
        ang += increment;
        if(ang >= 360D)
            return ang - 360D;
        else
            return ang;
    }

    double angleDecrement(double ang, double decrement) {
        ang -= decrement;
        if(ang < 0.0D)
            return 360D + ang;
        else
            return ang;
    }

    void pushState(double angle, int sx, int sy) {
        double state[] = new double[3];
        state[0] = angle;
        state[1] = sx;
        state[2] = sy;
        stateStack.push(state);
    }

    double popState() {
        double state[] = (double[])stateStack.pop();
        startX = (int)state[1];
        startY = (int)state[2];
        return state[0];
    }

    /**
     * Set the background colour.
     * @param back the background colour.
     */    
    public void setBackground(Color back) {
        clrBackground = back;
    }

    /**
     * Set the foreground colour.
     * @param fore the foreground colour.
     */    
    public void setForeground(Color fore) {
        clrForeground = fore;
    }

    /**
     * Write the L-System to an image file.
     * @param filename the filename to write.
     * @param width the width of the image.
     * @param height the height of the image.
     */    
    public void writeImage(String filename, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(filename, width, height, this);
        } catch (IOException e) {
            System.err.println(e);
        }
    }

    /**
     * Test function that writes a couple of simple L-System examples of varying types
     * as well as depths.
     * @param args no arguments required.
     */    
    public static void main(String args[]) {
        LSystem lsys = new LSystem();
        lsys.setAxiom("Q");
        lsys.setDepth(8);
        lsys.setParameters(36D, 180D, 12, 1.0D);
        lsys.setStartPoint(639, 479);
        lsys.setRule('P', "--FR++++FS--FU");
        lsys.setRule('Q', "FT++FR----FS++");
        lsys.setRule('R', "++FP----FQ++FT");
        lsys.setRule('S', "FU--FP++++FQ--");
        lsys.setRule('T', "+FU--FP+");
        lsys.setRule('U', "-FQ++FT-");
        lsys.writeImage("pentive3.png", 640, 480);
        lsys.initializeRules();
        lsys.setForeground(new Color(0, 90, 0));
        lsys.setAxiom("F");
        lsys.setDepth(0);
        lsys.setParameters(8D, 278D, 100, 0.5D);
        lsys.setStartPoint(320, 450);
        lsys.setRule('F', "|[5+F][7-F]-|[4+F][6-F]-|[3+F][5-F]-|F");
        lsys.writeImage("fern000.png", 640, 480);
        lsys.setDepth(1);
        lsys.writeImage("fern001.png", 640, 480);
        lsys.setDepth(2);
        lsys.writeImage("fern002.png", 640, 480);
        lsys.setDepth(3);
        lsys.writeImage("fern003.png", 640, 480);
        lsys.setDepth(4);
        lsys.writeImage("fern004.png", 640, 480);
        lsys.setDepth(5);
        lsys.setParameters(20D, 270D, 150, 0.5D);
        lsys.setStartPoint(320, 450);
        lsys.setRule('F', "|[+F]|[-F]+F");
        lsys.writeImage("fern01.png", 640, 480);
        lsys.setParameters(20D, 270D, 150, 0.5D);
        lsys.setStartPoint(320, 450);
        lsys.setRule('F', "|[3-F][3+F]|[--F][++F]|F");
        lsys.writeImage("fern02.png", 640, 480);
    }

    private String rules[];
    private String axiom;
    private int maxDepth;
    private double segmentSize;
    private double stepSize;
    private double baseAngle;
    private double initialAngle;
    private int startX;
    private int startY;
    private int initialX;
    private int initialY;
    private Color clrBackground;
    private Color clrForeground;
    private Stack stateStack;
}
