/*
 * Steppable.java
 * Created on 23 July 2004, 15:31
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

package org.generation5;

/**
 * This interface is used to provide a simple way of providing
 * classes with a standardized structure for time-steppable classes.
 * A standard initialization routine is also provided.
 *
 * @author  James Matthews
 */
public interface Steppable {
    /** A standard initialization function. This should be assumed to be a
     *  recurrable initialization procedure. Any one-off initializations should
     *  be done in the constructor. */
    public void init();
    
    /** Move the class forward one time-step. */
    public void doStep();
    
    /**
     * Reset the object. <code>reset</code> can often be substituted for
     * another call to <code>init</code>.
     */    
    public void reset();
}
