/*
 * VistepListener.java
 * Created on 10 August 2004, 14:29
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

package org.generation5.swing;

/**
 * This interface is used to control all actions within VisStepApplet.
 * @author James Matthews
 * @see VisStepListener
 */
public interface VisStepListener {
    /**
     * Called when the start button is clicked.
     * @param evt the action event.
     */    
    void startButton(java.awt.event.ActionEvent evt);
    /**
     * Called when the step button is clicked.
     * @param evt the action event.
     */    
    void stepButton(java.awt.event.ActionEvent evt);
    /**
     * Called when the reset button is clicked.
     * @param evt the action event.
     */    
    void resetButton(java.awt.event.ActionEvent evt);
    /**
     * Called whenever the timer is triggered.
     * @param evt the action event.
     */    
    void timer(java.awt.event.ActionEvent evt);
    /**
     * Called when a mouse is clicked on the visualization panel.
     * @param evt the mouse event.
     * @see VisualizationPanel
     */    
    void mouseClicked(java.awt.event.MouseEvent evt);
}

//capsicum