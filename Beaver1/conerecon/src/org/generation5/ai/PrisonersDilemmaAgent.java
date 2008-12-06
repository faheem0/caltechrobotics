/*
 * PrisonersDilemmaAgent.java
 * Created on 21 July 2004, 17:21
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

/**
 * A simple implementation of an agent that obeys the rules of the prisoner's
 * dilemma. This implementation contains five commonly-used strategies: all cooperate,
 * all defect, tit-for-tat, pavlov, or random. For a more detailed look at the IPD
 * and different strategies, please see <a href="http://www.generation5.org/content/2001/ipd.asp">the Generation5 essay</a>.
 * @author James Matthews
 * @version 0.1, 07/25/04
 */
public class PrisonersDilemmaAgent {
    /** Cooperate for all */
    public final static int ALL_C = 0;
    /** Defect for all */
    public final static int ALL_D = 1;
    /** Tit-for-tat strategy */
    public final static int TFT = 2;
    /** Random strategy */
    public final static int RANDOM = 3;
    /** Pavlov strategy */
    public final static int PAVLOV = 4;
    /** Number of strategies - for selecting random strategy */
    public static int STRATEGIES = 5;
    /** Cooperate with partner */
    public final static int COOPERATE = 0;
    /** Defect against partner */
    public final static int DEFECT = 1;
    /** Won the last round (returned by run) */
    public final static int WON = 1;
    /** Drew the last round (returned by run)  */
    public final static int DREW = 0;
    /** Lost the last round (returned by run) */
    public final static int LOST = -1;
    /** Number of points agent has acquired */
    protected int agentPoints = 0;
    /** What your opponent last played */
    protected int partnerLastMove = -1;
    /** The move this agent last played */
    protected int myLastMove = -1;
    /** What was the result of the last round? */
    protected int lastRoundResult = DREW;
    
    /**
     * Default constructor (uses TFT strategy).
     */
    public PrisonersDilemmaAgent() {
        this(TFT);
    }
    
    /**
     * Create a new instance of PrisonersDilemmaAgent with a given strategy.
     * @param strategy the strategy to use.
     *
     * @see #ALL_C
     * @see #ALL_D
     * @see #TFT
     * @see #RANDOM
     * @see #PAVLOV
     */    
    public PrisonersDilemmaAgent(int strategy) {
        reset();
        setStrategy(strategy);
    }
    
    /**
     * Retrieve the strategy the PD agent.
     * @return the strategy currently being used.
     */    
    public int getStrategy() {
        return agentStrategy;
    }
    
    /**
     * Set the strategy type.
     * @param strategy the strategy type.
     */    
    public void setStrategy(int strategy) {
        agentStrategy = strategy;
    }
    /** Reset the agent's points, note that strategy remains untouched */
    public void reset() {
        agentPoints = 0;
        partnerLastMove = -1;
    }
    /**
     * Make a run against your 'partner' with prisoner's dilemma rule. A run consists
     * of one iteration using the given strategies of this agent and the partner agent.
     * Points are allocated to either this agent or the partner automatically, according
     * to the result of the run.
     * @param partner your partner for this run.
     * @return WON, LOST or DRAW depending on the result.
     */
    public int run(PrisonersDilemmaAgent partner) {
        int m = getMove();
        int o = partner.getMove();
        int result = DREW;
        
        if (m == DEFECT && o == COOPERATE) {
            this.addPoints(5);
            partner.addPoints(0);
            result = WON;
        } else if (m == COOPERATE && o == COOPERATE) {
            this.addPoints(3);
            partner.addPoints(3);
        } else if (m == DEFECT && o == DEFECT) {
            this.addPoints(1);
            partner.addPoints(1);
        } else {
            this.addPoints(0);
            partner.addPoints(5);
            result = LOST;
        }
        
        myLastMove = m;
        partnerLastMove = o;
        lastRoundResult = result;
        
        return result;
    }
    
    /**
     * Retrieve the agent's next move according to the current strategy.
     * @return either DEFECT or COOPERATE according to strategy.
     */
    public int getMove() {
        if (agentStrategy == ALL_C) return COOPERATE;
        if (agentStrategy == ALL_D) return DEFECT;
        if (agentStrategy == TFT) {
            if (partnerLastMove == -1) return COOPERATE;
            else return partnerLastMove;
        }
        if (agentStrategy == PAVLOV) {
            if (myLastMove != -1) {
                if (lastRoundResult == LOST) return (1 - myLastMove);
                return myLastMove;
            } else {
                return COOPERATE;
            }
        }
        
        // agentStrategy == RANDOM
        return (int)(Math.random() * 2);
    }
    
    /**
     * Increment the points for the agent.
     * @param p the number to increment the agent's point tally by.
     */
    public void addPoints(int p) {
        agentPoints += p;
    }
    
    /**
     * Retrieve the number of points that the agent has acquired.
     * @return the number of points acquired.
     */    
    public int getPoints() {
        return agentPoints;
    }
    
    /**
     * Simple test using an iterated prisoner's dilemma situtation.
     * Results are printed as a simple table with percentage scores.
     *
     * @param args1 not required.
     */    
    public static void main(String args1[]) {
        int[][] scoreTable = new int[5][5];
        PrisonersDilemmaAgent agent1 = new PrisonersDilemmaAgent();
        PrisonersDilemmaAgent agent2 = new PrisonersDilemmaAgent();
        
        for (int i=0; i<4; i++) {
            agent1.setStrategy(i);
            for (int j=0; j<4; j++) {
                agent2.setStrategy(j);
                // Run through 20 iterations
                for (int r=0; r<20; r++) {
                    agent1.run(agent2);
                }
                scoreTable[i][j] = agent1.getPoints();
                // reset
                agent1.reset();
                agent2.reset();
            }
        }
 
        // Print out table
        System.err.println("   ALL_C, ALL_D, TFT, RANDOM");
        for (int i=0; i<4; i++) {
            System.err.println(i + ": " + scoreTable[i][0] + "%, " +
                                          scoreTable[i][1] + "%, " +
                                          scoreTable[i][2] + "%, " +
                                          scoreTable[i][3] + "%.");
        }
    }
    
    private int agentStrategy;
}
