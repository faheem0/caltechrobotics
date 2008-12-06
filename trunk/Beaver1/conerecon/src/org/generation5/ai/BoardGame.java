/*
 * BoardGame.java
 * Created on 10 December 2004, 17:10
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

import java.awt.*;
import org.generation5.*;
import org.generation5.util.*;

/**
 * This class is designed to faciliate development of board games, with AI agent
 * players (see {@link org.generation5.ai.BoardGameAgent}). This class implements
 * both <code>Visualizable</code> and <code>Steppable</code>. The board is visualized
 * simply as celled circles denoting the pieces: colours can be specified at runtime.
 * This class also provides a handy means of displaying an influence map, if used
 * by the AI agents. <code>Steppable</tt> has been implemented for the purposes of
 * running quick  simulations between AI agents without human intervention/participation.
 *
 * Any deriving class handles all the rules of the game, and all moves are supplied
 * using a generic array of integers, allowing for simple {x,y} coordinate moves, or
 * more complicated moves that (for example) require a starting piece too.
 * @author James Matthews
 * @see org.generation5.ai.BoardGameAgent
 * @see org.generation5.ai.InfluenceMap
 */
public abstract class BoardGame implements Visualizable, Steppable {
    /**
     * The game has been drawn.
     * @see #getStatus(int)
     */    
    public static final int STATUS_DRAW = -1;
    /**
     * The game is still in progress.
     * @see #getStatus(int)
     */    
    public static final int STATUS_INPROGRESS = 0;
    /**
     * The width of the board.
     */    
    protected int width;
    /**
     * The height of the board.
     */    
    protected int height;
    /**
     * The size of the pieces when rendered.
     */    
    protected int pieceSize = 25;
    /**
     * The influence map to render.
     */    
    protected InfluenceMap renderMap;
    /**
     * The game board.
     */    
    protected int[][] gameBoard;
    /**
     * The game agents.
     */    
    protected BoardGameAgent[] gameAgents;
    /**
     * The player colours.
     */    
    protected Color[] playerColors = { Color.RED, Color.BLACK, Color.BLUE, Color.GREEN, Color.YELLOW, Color.ORANGE };
    /**
     * The gradient used to render the influence map.
     */    
    protected Gradient influenceGradient;
    
    /**
     * Create an instance of <code>BoardGame</code>, specifying the dimensions and
     * number of players involved. This is the only constructor, to force deriving
     * classes to specify these details upon construction.
     * @param width board width.
     * @param height board height.
     * @param numPlayers number of participating players.
     */    
    public BoardGame(int width, int height, int numPlayers) {
        this.width = width;
        this.height = height;
        
        gameBoard = new int[width][height];        
        gameAgents = new BoardGameAgent[numPlayers];
        
        influenceGradient = new Gradient();
        influenceGradient.addPoint(Color.white);
        influenceGradient.addPoint(Color.yellow);
        influenceGradient.addPoint(Color.red);
        influenceGradient.createGradient();
    }
    
    /**
     * This abstract method must return whether the supplied move is valid for the given
     * player.
     * @param playerID the player ID.
     * @param move the move.
     * @return true if move is valid, otherwise false.
     */    
    public abstract boolean validMove(int playerID, int[] move);
    /**
     * Make the move. This is normally where many of the board game rules will be played
     * out.
     * @param playerID the player moving.
     * @param move the move itself.
     * @return a generic return value, for use by the programmer.
     */    
    public abstract int move(int playerID, int[] move);
    /**
     * Get the total number of participating players.
     * @return total players.
     */    
    public abstract int getTotalPlayers();
    /**
     * Return the status of this game. This function should return <code>STATUS_INPROGRESS</code>
     * (0) if the game is currently running, <code>STATUS_DRAW</code> (-1) if the game
     * has been drawn, otherwise it should return the ID of the player who has won.
     *
     * The method can be called with the current player to satisfy some other board game
     * rules.
     * @param currPlayer the current player.
     * @return game status code (see above).
     */    
    public abstract int getStatus(int currPlayer);
    /**
     * Simply calls <code>getStatus(0)</code>
     * @return the result of <code>getStatus(0)</code>.
     * @see #getStatus(int)
     */    
    public int getStatus() { 
        return getStatus(0); 
    }
        
    /**
     * Get the width of the board.
     * @return the board width.
     */    
    public int getWidth() {
        return width;
    }
    
    /**
     * Get the height of the board.
     * @return the board height.
     */    
    public int getHeight() {
        return height;
    }
    
    /**
     * Set the piece size.
     * @param pieceSize the new piece size.
     */    
    public void setPieceSize(int pieceSize) {
        this.pieceSize = pieceSize;
    }
    
    /**
     * Return the piece size.
     * @return the current piece size.
     */    
    public int getPieceSize() {
        return pieceSize;
    }
    
    /**
     * Set the board at the specified position.
     * @param x x-position to set.
     * @param y y-position to set.
     * @param board the value to set.
     */    
    public void setBoardAt(int x, int y, int board) {
        if (isWithinBoard(x, y) == false) return;   // throw exception?
        
        gameBoard[x][y] = board;
    }
    
    /**
     * Return the board value.
     * @param x the x-position.
     * @param y the y-position.
     * @return the board value.
     */    
    public int getBoardAt(int x, int y) {
        if (isWithinBoard(x, y) == false) 
            return -1;
        
        return gameBoard[x][y];
    }
    
    /**
     * Return the number of values with a specified value (player ID).
     * @param type the piece type/player ID to count.
     * @return the number of pieces specified as <code>type</code>.
     */    
    public int getCountOf(int type) {
        int count = 0;
        for (int i=0; i<gameBoard.length; i++) {
            for (int j=0; j<gameBoard[i].length; j++) {
                if (gameBoard[i][j] == type) count++;
            }
        }
        
        return count;
    }
    
    /**
     * Set the piece colours. Note that Player <i>x</i> will be rendered in colour
     * <i>x-1</i>.
     * @param pieceColors the array of piece colours.
     */    
    public void setPieceColors(Color[] pieceColors) {
        playerColors = pieceColors;
    }
    
    /**
     * Add a player to the game. This method sets the player's board game pointer and
     * player ID accordingly. Note that player IDs start at 1 (as in, there is no player 0).
     * @param playerID the player ID.
     * @param agent the agent to add.
     */    
    public void addPlayer(int playerID, BoardGameAgent agent) {
        if (playerID == 0)
            throw new IllegalArgumentException("playerID must be greater than zero.");
        
        gameAgents[playerID-1] = agent;
        gameAgents[playerID-1].setBoardGame(this);
        
        agent.setPlayerID(playerID);        
        agent.init();
    }
    
    /**
     * Add a player, and specify the colour.
     * @param playerID the player ID.
     * @param agent the agent.
     * @param pieceColor the piece colour.
     * @see #addPlayer(int, BoardGameAgent)
     */    
    public void addPlayer(int playerID, BoardGameAgent agent, Color pieceColor) {
        // Now add the player agent
        addPlayer(playerID, agent);
        // Set up the piece colour if necessary
        playerColors[(playerID - 1) % playerColors.length] = pieceColor;
    }
    
    /**
     * A utility method to check whether the given coordinate is within the board game
     * bounds.
     * @param x the x-coordinate.
     * @param y the y-coordinate.
     * @return true, if a valid position, otherwise false.
     */    
    public boolean isWithinBoard(int x, int y) {
        if (x < 0 || x >= width || y < 0 || y >= height)
            return false;
        
        return true;
    }
    
    /**
     * Reset the board to zero.
     */    
    public void resetBoard() {
        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                gameBoard[i][j] = 0;
            }
        }
    }
    
    /**
     * Step the board game. This method is defined as:
     * <code>
     *        int[] nextMove;
     *        int players = getTotalPlayers();
     *
     *        for (int p=0; p&lt;players; p++) {
     *            do {
     *                nextMove = gameAgents[p].think();
     *            } while (validMove(p+1, nextMove) == false);
     *
     *            move(p+1, nextMove);
     *        }
     * </code>
     */    
    public void doStep() {
        int[] nextMove;
        int players = getTotalPlayers();
        
        for (int p=0; p<players; p++) {
            do {
                nextMove = gameAgents[p].think();
            } while (validMove(p+1, nextMove) == false);
            
            move(p+1, nextMove);
        }
    }
    
    /**
     * Initialize the board game.
     */    
    public abstract void init();
    
    /**
     * Set the influence map to render.
     * @param map the influence map to render.
     */    
    public void setRenderMap(InfluenceMap map) {
        renderMap = map;
    }
    
    /**
     * Set the influence map to render, along with a gradient. The default gradient is
     * white to yellow to red.
     * @param map the influence map to render.
     * @param gradient the gradient with which to render it.
     */    
    public void setRenderMap(InfluenceMap map, Gradient gradient) {
        setRenderMap(map);
        
        influenceGradient = gradient;
    }
    
    /**
     * Render the board game.
     * @param g the graphics context.
     * @param ww the width of the context.
     * @param hh the height of the context.
     */    
    public void render(java.awt.Graphics g, int ww, int hh) {
        g.setColor(new java.awt.Color(192, 192, 192));
        g.fillRect(0, 0, ww, hh);
        
        int cellSize = pieceSize;
        int border = cellSize / 8;
        
        // Centre everything
        int sx = (ww / 2) - (width * cellSize / 2);
        int sy = (hh / 2) - (height * cellSize / 2);
        
        if (renderMap == null) {
            g.setColor(Color.WHITE);
            g.fillRect(sx, sy, width * cellSize, height * cellSize);
        } else {
            int gradient = 0;
            int influence = 0;
            int maximum = renderMap.getMaximum(InfluenceMap.FIRST)[2];
            for (int y=0; y<renderMap.getHeight(); y++) {
                for (int x=0; x<renderMap.getWidth(); x++) {
                    influence = renderMap.getAt(x, y);
                    gradient = (int)(influence / (double)maximum * 255);
                    g.setColor(influenceGradient.getColour(gradient));
                    
                    g.fillRect(sx + x * cellSize, sy + y * cellSize, cellSize, cellSize);
                }
            }
        }
        
        // Draw the grid
        g.setColor(Color.lightGray);
        for (int i=1; i<width; i++)
            g.drawLine(sx + i * cellSize, sy, sx + i * cellSize, sy + height * cellSize);
        for (int i=1; i<height; i++)
            g.drawLine(sx, sy + i * cellSize, sx + width * cellSize, sy + i * cellSize);
        // Draw the pieces        
        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                if (gameBoard[i][j] != 0) {
                    g.setColor(playerColors[gameBoard[i][j]-1]);                    
                    g.fillOval(sx + border + i * cellSize, sy + border + j * cellSize, 
                               cellSize - border*2, cellSize - border*2);
                }
            }
        }
        // Border everything
        g.setColor(Color.BLACK);
        g.drawRect(sx - 1, sy - 1, width * cellSize + 1, height * cellSize + 1);
    }
    
    /**
     * Reset the board game (simply calls <code>init</code>).
     */    
    public void reset() {
        init();
    }
    
    /**
     * Write an image to disk.
     * @param s the filename.
     * @param width the image width.
     * @param height the image height.
     */    
    public void writeImage(String s, int width, int height) {
        try {
            org.generation5.util.ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }    
}
