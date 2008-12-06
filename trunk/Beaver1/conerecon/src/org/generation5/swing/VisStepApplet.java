/*
 * VisStepApplet.java
 * Created on 05 August 2004, 13:18
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

import org.generation5.*;
import java.lang.reflect.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Color;
import java.awt.*;
import javax.swing.*;
import javax.swing.Timer;

/**
 * <code>VisStepApplet</code> is meant for <i>visualizable</i> and <i>steppable</i>
 * demonstration applets.
 * @author James Matthews
 */
public abstract class VisStepApplet extends javax.swing.JApplet implements ActionListener {
        
    /**
     * Create a new instance of <code>VisStepApplet</code>.
     */    
    public VisStepApplet() {
        isRunning = false;
    }
    
    /**
     * Retrieves an integer parameter, with a default setting if the parameter is null.
     * This method also allows the radix to be passed so hexadecimal
     * and similar can be parsed and returned.
     * @param param the parameter name.
     * @param defaultParameter the default parameter.
     * @param radix the radix.
     * @return the integer retrieved, if parameter is not null, otherwise the default parameter.
     */    
    protected int getIntParameter(String param, int defaultParameter, int radix) {
        if(getParameter(param) == null)
            return defaultParameter;
        else
            return Integer.parseInt(getParameter(param), radix);
    }
    
    /**
     * Retrieves an integer parameter, with a default setting if the parameter is null.
     * @param param the parameter name.
     * @param defaultParameter the default parameter.
     * @return the integer retrieved, if parameter is not null, otherwise the default parameter.
     */    
    protected int getIntParameter(String param, int defaultParameter) {
        return getIntParameter(param, defaultParameter, 10);
    }
    
    /**
     * Retrieves a boolean parameter, with a default setting if the parameter is null.
     * @param param the parameter name.
     * @param defaultParameter the default parameter.
     * @return the boolean retrieved, if parameter is not null, otherwise the default parameter.
     */    
    protected boolean getBoolParameter(String param, boolean defaultParameter) {
        if (getParameter(param) == null) {
            return defaultParameter;
        } else {
            // fixme: make case-insensitive
            return (getParameter(param).compareTo("true") == 0);
        }
    }
    
    /**
     * Retrieves a double parameter, with a default setting if the parameter is null.
     * @param param the parameter name.
     * @param defaultParameter the default parameter.
     * @return the double retrieved, if parameter is not null, otherwise the default parameter.
     */    
    protected double getDblParameter(String param, double defaultParameter) {
        if(getParameter(param) == null)
            return defaultParameter;
        else
            return Double.parseDouble(getParameter(param));
    }
    
    /**
     * Retrieves a string parameter, with a default setting if the parameter is null.
     * @param param the parameter name.
     * @param defaultParameter the default parameter.
     * @return the string retrieved, if parameter is not null, otherwise the default parameter.
     */    
    protected String getStrParameter(String param, String defaultParameter) {
        if(getParameter(param) == null)
            return defaultParameter;
        else
            return getParameter(param);
    }

    /**
     * Initializes the applet.
     */
    public void init() {
        try {
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
        } catch (Exception e) {
            System.err.println("Problem loading 'WindowsLookAndFeel', defaulting to metal.");
        }

        initComponents();
        
        // Initialize the necessary controls
        if (visualizable == null)
            visualizationPanel.setContent(new NullVisualizable());
        
        int timerInterval = 40;
        // Should the toolbar be shown?
        toolbarPanel.setVisible(getBoolParameter("ShowToolbar", true));
        // If toolbar isn't shown, allow mouse interaction.
        allowMouseInteraction = !(getBoolParameter("ShowToolbar", true));
        // Set the timer interval according to the maximum FPS
        timerInterval = 1000 / getIntParameter("MaxFPS", 25);
        // Should the timer start immediately?
        isRunning = getBoolParameter("Autostart", false);
        // Get the background colour, this is used for the toolbar, as well as classes.
        clrBackground = new Color(getIntParameter("BackgroundColor", 0xdfdfdf, 16));
        // Set the animation timer
        animTimer = new Timer(timerInterval, this);
        animTimer.setInitialDelay(0);
        animTimer.setCoalesce(true);
        // Toolbar
        toolbarPanel.setBackground(clrBackground);
        visualizationPanel.setBackground(clrBackground);
        startButton.setBackground(clrBackground);
        stepButton.setBackground(clrBackground);
        resetButton.setBackground(clrBackground);
        // Set the anti-aliasing
        visualizationPanel.setAntiAliasing(getBoolParameter("Antialias", false));
    }
    
    /**
     * Set the steppable data.
     * @param step the steppable data.
     */    
    public void setSteppable(Steppable step) {
        steppable = step;
        if (steppable == null) {
            startButton.setEnabled(false);
            stepButton.setEnabled(false);
            resetButton.setEnabled(false);
        } else {
            startButton.setEnabled(true);
            stepButton.setEnabled(true);
            resetButton.setEnabled(true);
        }
    }
    
    /**
     * Set the visualizable data.
     *
     * @param viz the visualizable data.
     */    
    public void setVisualizable(Visualizable viz) {
        visualizable = viz;
        if (visualizable == null) {
            visualizationPanel.setContent(new NullVisualizable());
        } else {
            visualizationPanel.setContent(viz);
        }
    }
    
    /**
     * Start or stop the animation timer. This function controls the toolbar buttons,
     * as well as maintaining <code>isRunning</code>.
     * @param runningNow is the applet to be running now?
     */    
    public void setStartStop(boolean runningNow) {
        if(runningNow) {
            startButton.setForeground(new Color(192, 0, 0));
            startButton.setText("Stop");
            if(!animTimer.isRunning())
                animTimer.start();
        } else {
            startButton.setForeground(new Color(0, 192, 0));
            startButton.setText("Start");
            if(animTimer.isRunning())
                animTimer.stop();
        }
        
        isRunning = runningNow;
    }
    
    /** This method is called from within the init() method to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    private void initComponents() {//GEN-BEGIN:initComponents
        visualizationPanel = new org.generation5.swing.VisualizationPanel();
        toolbarPanel = new javax.swing.JPanel();
        startButton = new javax.swing.JButton();
        stepButton = new javax.swing.JButton();
        resetButton = new javax.swing.JButton();

        visualizationPanel.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                visualizationPanelMouseClicked(evt);
            }
        });

        getContentPane().add(visualizationPanel, java.awt.BorderLayout.CENTER);

        startButton.setFont(new java.awt.Font("MS Sans Serif", 1, 11));
        startButton.setForeground(new java.awt.Color(0, 192, 0));
        startButton.setText("Start");
        startButton.setEnabled(false);
        startButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                startButtonActionPerformed(evt);
            }
        });

        toolbarPanel.add(startButton);

        stepButton.setText("Step");
        stepButton.setEnabled(false);
        stepButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                stepButtonActionPerformed(evt);
            }
        });

        toolbarPanel.add(stepButton);

        resetButton.setText("Reset");
        resetButton.setEnabled(false);
        resetButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                resetButtonActionPerformed(evt);
            }
        });

        toolbarPanel.add(resetButton);

        getContentPane().add(toolbarPanel, java.awt.BorderLayout.NORTH);

    }//GEN-END:initComponents

    private void startButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_startButtonActionPerformed
        actions.startButton(evt);
    }//GEN-LAST:event_startButtonActionPerformed

    private void visualizationPanelMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_visualizationPanelMouseClicked
        actions.mouseClicked(evt);
    }//GEN-LAST:event_visualizationPanelMouseClicked

    private void resetButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetButtonActionPerformed
        actions.resetButton(evt);
    }//GEN-LAST:event_resetButtonActionPerformed

    private void stepButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stepButtonActionPerformed
        actions.stepButton(evt);
    }//GEN-LAST:event_stepButtonActionPerformed

    /**
     * Called when the animation timer is triggered. Advances the <code>Steppable</code>
     * class, and repaints the VisualizationPanel.
     * @param e not used.
     */    
    public void actionPerformed(ActionEvent e) {
        actions.timer(e);
    }
    
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    protected javax.swing.JButton resetButton;
    protected javax.swing.JButton startButton;
    protected javax.swing.JButton stepButton;
    protected javax.swing.JPanel toolbarPanel;
    protected org.generation5.swing.VisualizationPanel visualizationPanel;
    // End of variables declaration//GEN-END:variables
    
    /**
     * Denotes whether the applet is running. This is controlled by an animation
     * timer.
     */    
    protected boolean isRunning;
    /**
     * Denotes whether the applet allows for mouse interaction. This is automatically
     * set if the toolbar is hidden. A double-click starts or stops the applet, a right-
     * click will advance the demonstration one timestep.
     */    
    protected boolean allowMouseInteraction;
    /**
     * The animation/control timer. The timer will fire the desired number of frames
     * per second, calling both the doStep method and the repaint method of the
     * visualization panel.
     * @see Steppable#doStep
     */    
    protected Timer animTimer;
    /**
     * The background color. This is used as the background of the toolbar and the
     * visualization panel.
     */    
    protected Color clrBackground;
    
    /**
     * The steppable content.
     */    
    protected Steppable steppable = null;
    /**
     * The visualizable content.
     */    
    protected Visualizable visualizable = new NullVisualizable();
    
    /**
     * The actions for this applet for the start, step, reset and timer actions.
     */    
    protected VisStepListener actions = new DefaultActions();
    
    /**
     * This class is the default visualization.
     */    
    protected class NullVisualizable implements Visualizable {
        /**
         * Renders basic visualization.
         * @param g the graphics context.
         * @param width the context width.
         * @param height the context height.
         */        
        public void render(java.awt.Graphics g, int width, int height) {
            Graphics2D g2d = (Graphics2D)g;
            g2d.setColor(new Color(192,0,0));
            g2d.drawLine(0,0,width,height);
            g2d.drawLine(width,0,0,height);
            g2d.setColor(Color.BLACK);
            g2d.drawString("No visualizable data", width/2-48, height/2+4);
        }
        
        /**
         * Not implemented.
         * @param s the filename.
         * @param width the image width.
         * @param height the image height.
         */        
        public void writeImage(String s, int width, int height) {
            return;
        }
    }
    
    /**
     * These are the default actions for <code>VisStepApplets</code>.
     */    
    protected class DefaultActions implements VisStepListener {
        /**
         * Start the timer.
         * @param evt an action event.
         */        
        public void startButton(java.awt.event.ActionEvent evt) {
            setStartStop(!isRunning);
        }
        
        /**
         * Stop the timer, and advance the Steppable one timestep using <code>doStep</code>.
         * @param evt an actiob event.
         */        
        public void stepButton(java.awt.event.ActionEvent evt) {
            setStartStop(false);
            if (steppable != null) steppable.doStep();
            visualizationPanel.repaint();
        }

        /**
         * Stop the timer and run the Steppable's <code>reset</code> method.
         * @param evt an action event.
         */        
        public void resetButton(java.awt.event.ActionEvent evt) {
            setStartStop(false);
            if (steppable != null) steppable.reset();

            visualizationPanel.repaint();
        }

        /**
         * Advances the applet by one timestep, calling <code>doStep</code> and repainting
         * the visualization panel.
         * @param evt an action event.
         */        
        public void timer(java.awt.event.ActionEvent evt) {
            if (steppable != null) steppable.doStep();

            visualizationPanel.repaint();
        }
        
        /**
         * No default action for mouse clicks.
         * @param evt a mouse event.
         */        
        public void mouseClicked(java.awt.event.MouseEvent evt) {
            if (allowMouseInteraction) {
                if (evt.getButton() == evt.BUTTON1) {
                    if (evt.getClickCount() == 2) startButtonActionPerformed(null);
                } else if (evt.getButton() == evt.BUTTON3 && !isRunning) {
                    stepButtonActionPerformed(null);
                }
            }
        }
    }
}
