/*
 * AStarPathfinder.java
 * Created on 20 October 2004, 13:33
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
 * Implements the A* algorithm. Pathing can be done on any class that implements the
 * <code>Navigable</code> interface.
 * @author James Matthews
 * @see org.generation5.ai.Navigable
 */
public class AStarPathfinder implements Pathfinder {
    /**
     * Returned by <code>getStatus</code> if a path <i>cannot</i> be found.
     * @see #getStatus
     */    
    public static final int PATH_NOT_FOUND = -1;
    /**
     * Returned by <code>getStatus</code> if a path has been found.
     * @see #getStatus
     */    
    public static final int PATH_FOUND = 1;
    /**
     * Returned by <code>getStatus</code> if the pathfinder is still running.
     * @see #getStatus
     */    
    public static final int IN_PROGRESS = 0;
    /**
     * The current status of the pathfinder.
     * @see #PATH_FOUND
     * @see #PATH_NOT_FOUND
     * @see #IN_PROGRESS
     */    
    protected int pathStatus = IN_PROGRESS;
    /**
     * The open list.
     */    
    protected LinkedList listOpen = new LinkedList();
    /**
     * The closed list.
     */    
    protected LinkedList listClosed = new LinkedList();
    /**
     * The goal node.
     */    
    protected AStarNode nodeGoal = null;
    /**
     * The start node.
     */    
    protected AStarNode nodeStart = null;
    /**
     * The current best node. The best node is taken from the open list after every
     * iteration of <code>doStep</code>.
     */    
    protected AStarNode nodeBest = null;
    /**
     * The current navigable environment.
     */    
    protected Navigable navMap = null;
    
    /** Creates a new instance of AStarPathfinder */
    public AStarPathfinder() {
    }
    
    /**
     * Return the current status of the pathfinder.
     * @return the pathfindre status.
     * @see #pathStatus
     */    
    public int getStatus() {
        return pathStatus;
    }
    
    /**
     * Iterate the pathfinder through one step.
     */    
    public void doStep() {
        nodeBest = getBest();
        if (nodeBest == null) {
            pathStatus = PATH_NOT_FOUND;
            return;
        }
        
        if (nodeBest.nodeNumber == nodeGoal.nodeNumber) {
            pathStatus = PATH_FOUND;
            return;
        }
        
        createChildren(nodeBest);
    }
    
    /**
     * Initialize the pathfinder.
     */    
    public void init() {
        listOpen.clear();       // Clear the open list
        listClosed.clear();     // Clear the closed list
        
        if (nodeGoal == null || nodeStart == null)
            throw new IllegalArgumentException("start/goal not yet set!");
        if (navMap == null)
            throw new IllegalArgumentException("navigation map not set!");
        
        // Initialize the node numbers
        nodeStart.nodeNumber = navMap.createNodeID(nodeStart);
        nodeGoal.nodeNumber  = navMap.createNodeID(nodeGoal);

        nodeBest = null;
        pathStatus = IN_PROGRESS;
        nodeStart.g = 0;
        nodeStart.h = navMap.getDistance(nodeGoal, nodeStart);
        nodeStart.f = nodeStart.g + nodeStart.h;
        nodeStart.reset();
        
        listOpen.add(nodeStart);
    }
    
    /**
     * Reset the pathfinder (just calls <code>init</code>).
     */    
    public void reset() {
        init();
    }
    
    /**
     * Sets the navigable  to use in the pathfinder. The object must implement the
     * <code>Navigable</code> interface.
     * @param map the map (or other Navigable object) to find a path through.
     */    
    public void setNavigable(Navigable map) {
        navMap = map;
    }

    /**
     * Sets the starting and goal points for the pathfinder.
     * @param sx the start x-position.
     * @param sy the start y-position.
     * @param gx the goal x-position.
     * @param gy the goal y-position.
     */    
    public void setEndpoints(int sx, int sy, int gx, int gy) {
        setEndpoints(new AStarNode(sx, sy), new AStarNode(gx, gy));
    }
    
    /**
     * Set the starting and goal points for the pathfinder. This method uses
     * <code>AStarNode</code>'s <i>x</i> and <i>y</i> variables, the pathfinder sets all
     * the other necessary node parameters.
     * @param start the start node.
     * @param goal the goal node.
     */    
    public void setEndpoints(AStarNode start, AStarNode goal) {
        nodeStart = start;
        nodeGoal  = goal;
    }
    
    /**
     * Returns the start node.
     * @return the start node.
     */    
    public AStarNode getStart() {
        return nodeStart;
    }
    
    /**
     * Set the start node.
     * @param start the start node.
     */    
    public void setStart(AStarNode start) {
        nodeStart = start;
    }
    
    /**
     * Set the goal node.
     * @param goal the goal node.
     */    
    public void setGoal(AStarNode goal) {
        nodeGoal = goal;
    }
    
    /**
     * Returns the goal node.
     * @return the goal node.
     */    
    public AStarNode getGoal() {
        return nodeGoal;
    }
    
    /**
     * Assigns the best node from the open list.
     * @return the best node.
     */    
    protected AStarNode getBest() {
        if (listOpen.size() == 0) return null;
        
        AStarNode first = (AStarNode)listOpen.getFirst();
        
        listOpen.removeFirst();
        listClosed.addFirst(first);
        
        return first;
    }
    
    /**
     * Returns the current best node.
     * @return the best node.
     */    
    public AStarNode getBestNode() {
        return nodeBest;
    }
    
    /**
     * Create the children surrounding the current best node.
     * @param node the node to create the children from.
     */    
    protected void createChildren(AStarNode node) {
        int x = node.x, y = node.y;
        AStarPathfinder.AStarNode tempNode = new AStarPathfinder.AStarNode();
        
        for (int i=-1; i<2; i++) {
            for (int j=-1; j<2; j++) {
                tempNode.x = x+i;
                tempNode.y = y+j;
                // If the node is this node, or invalid continue.
                if ((i == 0 && j == 0) || navMap.isValid(tempNode) == false)
                    continue;
                
                linkChild(node, x+i, y+j);
            }
        }
    }
    
    /**
     * Link the children to the parent node. This method may also update the parent
     * path if a shorter path is found.
     * @param node the parent node.
     * @param x the x-position of the new child.
     * @param y the y-position of the new child.
     */    
    protected void linkChild(AStarNode node, int x, int y) {
        AStarNode child = new AStarNode(x, y);
        child.nodeNumber = navMap.createNodeID(child);
        
        double g = node.g + navMap.getCost(node, child);
        
        AStarNode openCheck   = checkOpen(child);
        AStarNode closedCheck = checkClosed(child);
        
        if (openCheck != null) {
            node.addChild(openCheck);
            
            if (g < openCheck.g) {
                openCheck.parent = node;
                openCheck.g = g;
                openCheck.f = g + openCheck.h;
            }
        } else if (closedCheck != null) {
            node.addChild(closedCheck);
            
            if (g < closedCheck.g) {
                closedCheck.parent = node;
                closedCheck.g = g;
                closedCheck.f = g + closedCheck.h;

                updateParents(closedCheck);
            }
        } else {
            child.parent = node;
            child.g = g;
            child.h = navMap.getDistance(nodeGoal, child);
            child.f = child.g + child.h;
//            child.nodeNumber = navMap.createNodeID(x,y);
            
            addToOpen(child);
            node.addChild(child);
        }
    }
    
    /**
     * Add the new child to the open list, ordering by the f-value.
     * @param node the node to add to the open list.
     */    
    protected void addToOpen(AStarNode node) {
        int index = 0;
        AStarNode openNode = null;
        ListIterator iter = listOpen.listIterator();
        
        if (listOpen.size() == 0) {
            listOpen.addFirst(node);
            return;
        }
        
        do {
            openNode = (AStarNode)iter.next();
            if (node.f < openNode.f) {
                listOpen.add(index,  node);
                return;
            }
            index = index + 1;
        } while (iter.hasNext());
        
        listOpen.addLast(node);
    }
    
    /**
     * Update the parents for the new route.
     * @param node the root node.
     */    
    protected void updateParents(AStarNode node) {
        double g = node.g;
        int c = node.numChildren;
        Stack nodeStack = new Stack();
        
        AStarNode kid = null;
        for (int i=0; i<c; i++) {
            kid = node.children[i];
            
            if (g+1 < kid.g) {
                kid.g = g+1;
                kid.f = kid.g + kid.h;
                kid.parent = node;
                
                nodeStack.push(kid);
            }
        }
        
        AStarNode parent;
        while (nodeStack.size() > 0) {
            parent = (AStarNode)nodeStack.pop();
            c = parent.numChildren;
            for (int i=0; i<c; i++) {
                kid = parent.children[i];
                
                if (parent.g+1 < kid.g) {
                    kid.g = parent.g + navMap.getCost(parent, kid);
                    kid.f = kid.g + kid.h;
                    kid.parent = parent;
                    
                    nodeStack.push(kid);
                }
            }
        }
    }
    
    private AStarNode checkList(ListIterator iter, AStarNode node) {
        AStarNode check = null;
        if (!iter.hasNext()) return null;
        
        do {
            check = (AStarNode)iter.next();
            if (check.nodeNumber == node.nodeNumber)
                return check;
            
        } while (iter.hasNext());
        
        return null;
    }
    
    /**
     * Check the open list for a given node.
     * @param node the node to check for.
     * @return the node, if found, otherwise null.
     */    
    protected AStarNode checkOpen(AStarNode node) {
        return checkList(listOpen.listIterator(), node);
    }
    
    /**
     * Check the closed list for the given node.
     * @param node the node to check for.
     * @return the node, if found, otherwise null.
     */    
    protected AStarNode checkClosed(AStarNode node) {
        return checkList(listClosed.listIterator(), node);
    }
    
    /**
     * Return the open list.
     * @return the open list.
     */    
    public LinkedList getOpen() {
        return listOpen;
    }
    
    /**
     * Return the closed list.
     * @return the closed list.
     */    
    public LinkedList getClosed() {
        return listClosed;
    }
    
    /**
     * The pathfinder node.
     */    
    public static class AStarNode implements Pathfinder.Node {
        
        /**
         * The f-value.
         */
        public double f;
        
        /**
         * The g-value.
         */
        public double g;
        
        /**
         * The h-value.
         */        
        public double   h;
        
        /**
         * The x-position of the node.
         */
        protected int x;
        
        /**
         * The y-position of the node.
         */        
        protected int  y;
        /**
         * The number of children the node has.
         */        
        public int numChildren;
        /**
         * The node identifier.
         */        
        public int nodeNumber;
        /**
         * The parent of the node.
         */        
        protected AStarNode  parent;
        AStarNode[] children = new AStarNode[8];
        
        /**
         * The default constructor.
         */        
        public AStarNode() {
            this(-1, -1);
        }
        
        /**
         * The default constructor with positional information.
         * @param xx the x-position of the node.
         * @param yy the y-position of the node.
         */        
        public AStarNode(int xx, int yy) {
            x = xx;
            y = yy;
        }
        
        /**
         * Resets the node. This involves all f, g and h-values to 0 as well as removing all
         * children.
         */        
        public void reset() {
            f = g = h = 0.0;
            numChildren = 0;
            for (int i=0; i<8; i++) 
                children[i] = null;
        }
        
        /**
         * Add a child to the node.
         * @param node the child node.
         */        
        public void addChild(AStarNode node) {
            children[numChildren++] = node;
        }
        
        /**
         * Return the x-position of the node.
         * @return the x-position of the node.
         */        
        public int getX() {
            return x;
        }
        
        /**
         * Return the y-position of the node.
         * @return the y-position of the node.
         */        
        public int getY() {
            return y;
        }
        
        /**
         * Return the parent node.
         * @return the parent node.
         */        
        public AStarNode getParent() {
            return parent;
        }
    }
}
