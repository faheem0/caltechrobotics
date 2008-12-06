/*
 * Navigable.java
 * Created on 19 August 2004, 19:40
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

import org.generation5.*;

/**
 * A simple interface to allow pathfinders like the A* algorithm to navigate through
 * the environment.
 * @author James Matthews
 */
public interface Navigable {
//    public double getCost(int x, int y);
    /**
     * Determines whether the given node is valid.
     * @param node the node.
     * @return the validity of the node.
     */    
    public boolean isValid(Pathfinder.Node node);
    /**
     * Return the cost to travel from node 1 to node 2.
     * @param n1 the first node.
     * @param n2 the second node.
     * @return the cost required to travel.
     */    
    public double getCost(Pathfinder.Node n1, Pathfinder.Node n2);
    /**
     * Return the distance between the node 1 and node 2. Note that "distance" is not
     * always in terms of Manhattan or Eucledian distances.
     * @param n1 the first node.
     * @param n2 the second node.
     * @return the distance between the two nodes.
     */    
    public double getDistance(Pathfinder.Node n1, Pathfinder.Node n2);
    /**
     * Generate a unique ID for a given node. Note that the ID must be tied to its
     * properties, such as positional information. Nodes with the same information should
     * be assigned the same ID.
     * @param node the node.
     * @return the node's ID.
     */    
    public int createNodeID(Pathfinder.Node node);
}
