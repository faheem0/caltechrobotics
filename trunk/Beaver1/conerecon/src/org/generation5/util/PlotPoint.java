/*
 * PlotPoint.java
 * Created on 22 September 2004, 14:53
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

package org.generation5.util;

/**
 * A simple class encapsulating a two-dimensional point. The class does little more
 * than derive from <code>java.awt.geom.Point2D.Double</code>.
 * @author James Matthews
 * @see java.awt.geom.Point2D.Double
 */
public class PlotPoint extends java.awt.geom.Point2D.Double {
    /**
     * Create a new PlotPoint instance.
     */    
    public PlotPoint() {
        this(0,0);
    }
    /**
     * Create a new instance, and set the x/y coordinates.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     */
    public PlotPoint(double x, double y) {
        this.x = x;
        this.y = y;
    }
}
