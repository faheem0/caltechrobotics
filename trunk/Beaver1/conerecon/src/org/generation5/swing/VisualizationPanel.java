/*
 * VisualizationPanel.java
 * Created on 11 July 2004, 17:42
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

import java.awt.*;
import javax.swing.JPanel;

/**
 * This JPanel-derived class acts a simple way of displaying classes that implement
 * the Visualizable interface.
 *
 * @author James Matthews
 * @see org.generation5.Visualizable
 */
public class VisualizationPanel extends JPanel {
    
    /**
     * Default constructor
     */
    public VisualizationPanel() {
        clrBackground = new java.awt.Color(223, 223, 223);
    }
    
    /**
     * Sets the content to display. Note that the panel itself has no control over
     * how the content is rendered within itself, much beyond passing the width and
     * height of the display region to the content's render function.
     *
     * @param content the content to render in the panel
     */
    public void setContent(org.generation5.Visualizable content) {
        visualizeContent = content;
    }
    
    /**
     * Paint the content on the panel.
     *
     * @param graphics the graphics interface
     * @see org.generation5.Visualizable#render(Graphics,int,int)
     */
    protected void paintComponent(Graphics graphics) {
        super.paintComponent(graphics);
        
        if (visualizeContent == null) {
            // todo: just use the null viz stuff?
        } else {
            int pw = getWidth();
            int ph = getHeight();
            graphics.setColor(clrBackground);
            graphics.fillRect(0,0,pw,ph);
            Graphics2D g2d = (Graphics2D)graphics;
            g2d.setClip(0, 0, pw, ph);
            if (antiAliasing == true) {
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                                     RenderingHints.VALUE_ANTIALIAS_ON);
                g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
                                     RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
            }
            visualizeContent.render(g2d, pw, ph);
        }
    }
    
    /**
     * Sets the background colour. This is the colour that is painted across the
     * visualization panel before the Visualizable content is rendered. While many
     * other classes also allow separate background colour settings, their default
     * settings are transparent.
     * @param clr the background colour.
     */    
    public void setBackground(java.awt.Color clr) {
        clrBackground = clr;
    }
    
    /**
     * Retrieve the background colour.
     * @return the background colour.
     */    
    public java.awt.Color getBackground() {
        return clrBackground;
    }
    
    /**
     * Set the anti-aliasing state.
     * @param aa enables or disables anti-aliasing.
     */    
    public void setAntiAliasing(boolean aa) {
        antiAliasing = aa;
    }
    
    /**
     * Boolean value to specify whether anti-aliasing is to be used.
     */    
    protected boolean antiAliasing;
    private java.awt.Color clrBackground;
    private org.generation5.Visualizable visualizeContent;
}
