/*
 * BoardGameAgent.java
 * Created on 10 December 2004, 17:18
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

import org.generation5.ai.*;

/**
 * Abstract class designed to facilitate board game agent development.
 * @author James Matthews
 * @see org.generation5.ai.BoardGameAgent
 */
public abstract class BoardGameAgent {
    /**
     * The player ID.
     */    
    protected int playerID = -1;
    /**
     * The board game this agent is connected with.
     */    
    protected BoardGame boardGame;
    
    /**
     * Create a new instance of BoardGameAgent.
     */    
    public BoardGameAgent() {
        this(-1);
    }
    
    /**
     * Create a new instance of BoardGameAgent.
     * @param pid the player ID.
     */    
    public BoardGameAgent(int pid) {
        playerID = pid;
    }
    
    /**
     * This abstract method should implement the agent's AI. The move returned should
     * be valid according to the board game's <code>validMove</code> method.
     * @return the move to make.
     * @see org.generation5.ai.BoardGame#validMove(int, int[])
     */    
    public abstract int[] think();
    
    /**
     * Initialize the agent.
     */    
    public abstract void init();
    
    /**
     * Set the player ID.
     * @param pid the new player ID.
     */    
    public void setPlayerID(int pid) {
        playerID = pid;
    }
    
    /**
     * Get the player ID.
     * @return the current player ID.
     */    
    public int getPlayerID() {
        return playerID;
    }
    
    /**
     * Set the board game associated with this agent.
     * @param game the new board game.
     */    
    public void setBoardGame(BoardGame game) {
        boardGame = game;
    }
    
    /**
     * Return the board game associated with this agent.
     * @return the currently associated board game.
     */    
    public BoardGame getBoardGame() {
        return boardGame;
    }
}
