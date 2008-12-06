/*
 * CellularAutomata.java
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

import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import org.generation5.*;

/**
 * This class provides the necessary functionality for simple 2-dimensional
 * cellular automata. This class is not suitable for CAs that modify their
 * world separately to their own states. See CellularAutomataLayered for this.
 *
 * This class supports double-buffering to simulate synchronous updating of
 * the CA world. See Conway's Life or Langton's Self-replicating loop as an
 * example of this.
 *
 * @see CellularAutomataLayered
 * @version 0.5
 * @author James Matthews
 */
public abstract class CellularAutomata implements Visualizable, Steppable {
    /** The world array */    
    protected int caWorld[][][];
    /** Width of the CA world */    
    protected int caWorld_x;
    /** Height of the CA world */    
    protected int caWorld_y;
    /** Geometry type. Currently, the classes only support torodial geometry. */    
    protected int geometryType = TORODIAL;
    /** Infinite geometry (unsupported) */    
    public static final int INFINITE = 0;
    /** Torodial geometry. Coordinates are wrapped around. */    
    public static final int TORODIAL = 1;
    /** Enclosed geometry. Coordinates are truncated, not wrapped. */
    public static final int ENCLOSED = 2;
    /** Double buffering */
    public static final int DOUBLE_BUFFERING = 1;
    /**
     * Specifies {@link #translateGeometry(int, int)} is to translate across the x-axis.
     * @see #translateGeometry
     */
    protected static final int X_AXIS = 0;
    /**
     * Specifies {@link #translateGeometry(int, int)} is to translate across the y-axis.
     * @see #translateGeometry
     */
    protected static final int Y_AXIS = 1;
       
    /** Background colour */    
    protected Color clrBackground;
    /** World colour */    
    protected Color clrWorld[];
    /** Colour of the grid, if used */
    protected Color clrGrid;
    /** Size of the individual CA cells in pixels. For rendering purposes. */    
    protected int caSize;
    /** The size of the buffer (default = 1) */
    protected int bufferSize = 1;
    /** A quick way to ascertain whether double buffering is enabled */
    protected boolean doubleBuffering = false;
    /** Toggle to draw a grid - note this does NOT expand CA cell sizes,
     *  so caSize must be set to 3 or higher */
    protected boolean drawGrid = false;
    
    /**
     * The buffer position (only 0 or 1).
     */    
    protected int bufferPosition = 0;

    /**
     * Default constructor. The defaults are torodial geometry, 2 pixel per CA
     * cell, a light gray background (outside CA world) and a light gray grid (not 
     * drawn by default).
     */    
    public CellularAutomata() {
        this(0, 0);
    }

    /**
     * Constructor with size initialization. See #CellularAutomata for default
     * settings.
     * @param size_x width of the world
     * @param size_y height of the world
     */    
    public CellularAutomata(int size_x, int size_y) {
        this(size_x, size_y, 0);
    }
    
    /**
     * Constructor with size initialization and setup options.
     * See #CellularAutomata for default
     * settings.
     * @param size_x width of the world
     * @param size_y height of the world
     * @param options possible additional options (such as double buffering)
     */
    public CellularAutomata(int size_x, int size_y, int options) {
        caWorld_x = size_x;
        caWorld_y = size_y;
        geometryType = 1;
        caSize = 2;
        clrBackground = new Color(192,192,192,0);
        clrGrid = Color.lightGray;
        clrWorld = new Color[256];
        for(int i = 0; i < 256; i++)
            clrWorld[i] = Color.black;
        
        if (options == DOUBLE_BUFFERING) {
            bufferSize = 2;
            doubleBuffering = true;
        }
        
        setWorldSize(size_x, size_y);
    }

    /**
     * Return the world x-size. The value returned is the number of cells 
     * the CA world has across its width.
     * @see #caSize
     * @return world width
     */    
    public int getSizeX() {
        return caWorld_x;
    }

    /**
     * Return the world y-size. The value returned is the number of cells 
     * the CA world has across its height.
     * @see #caSize
     * @return World height
     */    
    public int getSizeY() {
        return caWorld_y;
    }

    /**
     * Sets the world size. This will allocate the necessary memory for the 
     * CA world, as well as set the caWorld_x/y member fields.
     * @param size_x The new world size (width)
     * @param size_y The new world size (height)
     */    
    public void setWorldSize(int size_x, int size_y) {
        caWorld = new int[bufferSize][size_x][size_y];
        caWorld_x = size_x;
        caWorld_y = size_y;
    }

    /**
     * Sets the CA size. CA Size is the number of pixels each CA cell is to
     * use when rendered. For example, setCASize(4) causes each cell to be 
     * rendered as a 4x4 square.
     * @param cas cell size (in pixels)
     */    
    public void setCASize(int cas) {
        caSize = cas;
    }

    /**
     * Returns the CA size
     * @see #setCASize(int)
     * @return The CA size in pixels
     */    
    public int getCASize() {
        return caSize;
    }

    /**
     * Set or reset the drawGrid flag. This causes the render function to
     * draw a grid around the CA cells.
     * @see #render(Graphics, int, int)
     * @param dg true to draw the grid
     */
    public void drawGrid(boolean dg) {
        drawGrid = dg;
    }
    
    /**
     * Clears the world. All cell states are set to zero. This includes the
     * buffer if double-buffering is enabled.
     */    
    public void clearWorld() {
        for (int b=0; b<bufferSize; b++) {
            for(int i = 0; i < caWorld_x; i++) {
                for(int j = 0; j < caWorld_y; j++)
                    caWorld[b][i][j] = 0;
            }
        }
    }

    /**
     * Returns the pixel state at a given position. This function uses 
     * translateGeometry before accessing the array; this means for torodial
     * geometry you may pass a number out of bounds of the CA world, and 
     * getWorldAt will wrap around the world.
     *
     * @param pos_x x position of cell state to return
     * @param pos_y y position of cell state to return
     *
     * @see #translateGeometry(int, int)
     * @return Cell state
     */    
    public int getWorldAt(int pos_x, int pos_y) {
        int gx = translateGeometry(pos_x, 0);
        int gy = translateGeometry(pos_y, 1);
        
        if (doubleBuffering) return caWorld[bufferPosition][gx][gy];
        
        return caWorld[0][gx][gy];
    }

    /**
     * Sets the world at the given position to a given state. This function uses 
     * translateGeometry before accessing the array; this means for torodial
     * geometry you may pass a number out of bounds of the CA world, and 
     * setWorldAt will wrap around the world.
     *
     * @param pos_x X-position of cell to set
     * @param pos_y Y-position of cell to set
     * @param s State to use
     */    
    public void setWorldAt(int pos_x, int pos_y, int s) {
        int gx = translateGeometry(pos_x, 0);
        int gy = translateGeometry(pos_y, 1);
        
        if (s < 0) s = 0;
        if (s > 255) s = 255; // FIXME: variable states.
        
        if (doubleBuffering) caWorld[1-bufferPosition][gx][gy] = s;
        else caWorld[0][gx][gy] = s;
    }
    
    /**
     * Set the world state relative to its current state.
     * @param pos_x the x-position of the cell.
     * @param pos_y the y-position of the cell.
     * @param ds the delta value to add to the world state.
     */    
    public void setWorldAtRelative(int pos_x, int pos_y, int ds) {
        setWorldAt(pos_x, pos_y, getWorldAt(pos_x, pos_y) + ds);
    }
    
    /**
     * This function sets a group of cells according to a specially formatted string.
     * Rows of cells are delimited by semi-colons, whilst individual strings are
     * separated using a comma. For example, a glider in Life might be represented by:
     * <code>"0,1,0;0,0,1;1,1,1"</code>. Row strings do not have to be of equal length,
     * but all positions are calculated according to the first cell.
     * @param pos_x the x-position to start the group of cells
     * @param pos_y the y-position to start the group of cells
     * @param cellStates the specially formatted string
     */    
    public void setWorldAtEx(int pos_x, int pos_y, String cellStates) {
        String[] cellRows = cellStates.split(";");
        
        for (int i=0; i<cellRows.length; i++) {
            String[] cells = cellRows[i].split(",");
            for (int j=0; j<cells.length; j++) {
                setWorldAt(pos_x+j, pos_y+i, Integer.parseInt(cells[j]));
            }
        }
    }

    /**
     * Translates a coordinate to the specified geometry.
     * @param pos The coordinate
     * @param axis The axis to translate around
     * @see #geometryType
     * @see #X_AXIS
     * @see #Y_AXIS
     * @return Translated coordinate
     */
    protected int translateGeometry(int pos, int axis) {
        if (geometryType == TORODIAL) return torodialTransform(pos, axis);
        if (geometryType == ENCLOSED) return enclosedTransform(pos, axis);
        return -1;
    }
    
    private int torodialTransform(int pos, int axis) {
        if (axis == X_AXIS) {
            if (pos >= 0 && pos < caWorld_x)
                return pos;
            if (pos < 0)
                return caWorld_x + pos;
            if (pos >= caWorld_x)
                return pos - caWorld_x;
        } else if (axis == Y_AXIS) {
            if (pos >= 0 && pos < caWorld_y)
                return pos;
            if (pos < 0)
                return caWorld_y + pos;
            if (pos >= caWorld_y)
                return pos - caWorld_y;
        }
        
        return pos;        
    }
    
    private int enclosedTransform(int pos, int axis) {
        if (axis == X_AXIS) {
            if (pos >= 0 && pos < caWorld_x)
                return pos;
            if (pos < 0)
                return 0;
            if (pos >= caWorld_x)
                return caWorld_x-1;
        } else if (axis == 1) {
            if (pos >= 0 && pos < caWorld_y)
                return pos;
            if (pos < 0)
                return 0;
            if (pos >= caWorld_y)
                return caWorld_y-1;
        }

        return pos;        
    }

    /**
     * Sets the geometry type. Currently only torodial geometry is supported.
     * @param g the geometry type
     */    
    public void setGeometry(int g) {
        geometryType = g;
    }

    /**
     * Retrieve the current geometry type
     * @return the geometry type in use
     */    
    public int getGeometry() {
        return geometryType;
    }

    /**
     * This abstract function is where the main workings of the CA should take place.
     * Every iteration, this function is called causing the CA to advance a step.
     */    
    public abstract void doStep();

    /**
     * This abstract function is where the initialization of the CA should take place.
     * This function is also called when the CA is reset, so one-time initialization
     * should remain in the constructors.
     */    
    public abstract void init();

    /**
     * Set the background colour of the CA. Note that this colour is not the default
     * world colour, but the colour rendered outside of the CA world area. This is
     * particularly pertinent when displaying CAs in applets.
     * @param back the background colour to be used
     * @see #setWorldColour(int, Color)
     */    
    public void setBackgroundColor(Color back) {
        clrBackground = back;
    }
    
    /**
     * Retrieve the background color. Remember, this is the color that is used for area
     * outside the CA.
     * @return the background color.
     */    
    public Color getBackgroundColor() {
        return clrBackground;
    }

    /**
     * This function sets the various world colours used by the CA. Each cell holds one
     * of a possible 256 states, this function sets the colours for these states. Note
     * that setWorldColour(0, Color) sets the default world colour.
     * @param world the state to set
     * @param colour the colour to use
     */    
    public void setWorldColour(int world, Color colour) {
        clrWorld[world] = colour;
    }
    
    /**
     * Similar to setWorldColour, but accepts an array of colours. This function is
     * especially useful when using the Gradient helper class.
     * @see org.generation5.util.Gradient
     * @param colors the array of colours to be used for the world states.
     */
    public void setWorldColors(Color[] colors) {
        for (int i=0; i<colors.length; i++) {
            clrWorld[i] = colors[i];
        }
    }
    
    /**
     * This function must be called when using double-buffering to swap the buffers
     * around. Remember to do this when after (or within) <code>init</code> and
     * <code>doStep</code>.
     */
    public void flipBuffer() {
        bufferPosition = 1 - bufferPosition;
    }

    /**
     * This is the default function for drawing the CA world. It centres the CA world
     * within the graphics context, and draws each cell as a square <code>caSize</code>
     * large. The render function will also draw a grid, if requested.
     * @param graphics the graphics context
     * @param pw the width of the context
     * @param ph the height of the context
     * @see #caSize
     */    
    public void render(Graphics graphics, int pw, int ph) {
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
        
        graphics.setClip(sx-1, sy-1, cx+2, cy+2);

        // draw the ca world
        for(int i = 0; i < getSizeX(); i++) {
            for(int j = 0; j < getSizeY(); j++) {
                int state = getWorldAt(i, j);
                if(state != 0) {
                    graphics.setColor(clrWorld[state]);
                    graphics.fillRect(sx + i * caSize, sy + j * caSize, caSize, caSize);
                }
            }
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
     * This default function writes a PNG image of the CA world.
     * @param filename the filename to use for the image
     * @param width the width of the image
     * @param height the height of the image
     */    
    public void writeImage(String filename, int width, int height) {
        BufferedImage buffer = new BufferedImage(width, height, 1);
        Graphics graphics = buffer.createGraphics();
        render(graphics, width, height);
        java.awt.image.RenderedImage rendered = buffer;
        try {
            File file = new File(filename);
            ImageIO.write(rendered, "png", file);
        } catch(IOException e) {
            System.err.println("An error occurred.");
        }
    }

    /**
     * This method calls <code>iterateCA</code> but with the parameters encoded as a
     * String array, ideally suited to be passed from the command-line.
     * <ol>
     * <li>number of iterations in total (default 100,000)
     * <li>snapshot frequency  (default 10,000)
     * <li>image prefix (default g5jdk)
     * <li>ca size
     * </ol>
     * @param ca the CA class to use
     * @param args the arguments to be used (see above)
     * @see #iterateCA(CellularAutomata, int, int, String, int)
     */    
    public static void iterateCA(CellularAutomata ca, String args[]) {
        int iterations = 10000;
        int snapshot = 1000;
        int caSize = 1;
        String prefix = "g5jdk";
        if(args.length > 0)
            iterations = Integer.parseInt(args[0]);
        if(args.length > 1)
            snapshot = Integer.parseInt(args[1]);
        if(args.length > 2)
            prefix = args[2];
        if(args.length > 3)
            caSize = Integer.parseInt(args[3]);
        
        iterateCA(ca, iterations, snapshot, prefix, caSize);
    }
    
    /**
     * This is a default testing method that many of the cellular automata <code>main</code>
     * methods use. It will iterate over a certain number of steps, writing snapshots
     * to disk.
     * @param ca an instance of the cellular automata class.
     * @param iterations the total number of iterations.
     * @param snapshot the number of iterations before a snapshot is taken.
     * @param prefix the prefix to apply to the files.
     * @param caSize the size of the CA cells.
     */    
    public static void iterateCA(CellularAutomata ca, int iterations, int snapshot, String prefix, int caSize) {
        ca.setCASize(caSize);
        int width = ca.getSizeX() * caSize;
        int height = ca.getSizeY() * caSize;
        System.out.println("Iterating for " + iterations + " iterations...");
        for(int i = 0; i < iterations; i++) {
            if(i % snapshot == 0)
                ca.writeImage(prefix + i + ".png", width, height);
            ca.doStep();
        }

        ca.writeImage(prefix + "final.png", width, height);
        System.out.println("Complete.");        
    }
    
    /**
     * Reset the world. Defaults to calling <code>init</code> again.
     */    
    public void reset() {
        init();
    }
}
