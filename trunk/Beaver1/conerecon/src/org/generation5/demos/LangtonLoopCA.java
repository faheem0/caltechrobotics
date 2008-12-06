/*
 * LangtonLoopCA.java
 * Created on 14 July 2004, 21:17
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

package org.generation5.demos;

import java.awt.*;    
import org.generation5.bio.*;

/**
 * Implements Langton's self-replicating loop. The code is heavily based
 * upon the Java applet by Eli Bachmutsky, available at:
 *   http://necsi.org/postdocs/sayama/sdsr/java/
 *
 * @author  James Matthews
 * @author  Eli Bachmutsky
 */
public class LangtonLoopCA extends CellularAutomata {
    /** The rules are stored in a 5-dimensional array */
    protected int[][][][][] rule;
    
    /** Creates a new instance of LangtonLoopCA */
    public LangtonLoopCA() {
        this(0, 0);
    }

    /**
     * Creates an instance of <code>LangtonLoopCA</code> with world size information.
     * @param size_x the x-size of the world.
     * @param size_y the y-size of the world.
     */    
    public LangtonLoopCA(int size_x, int size_y) {
        super(size_x, size_y, DOUBLE_BUFFERING);
    }

    /**
     *
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        LangtonLoopCA loop = new LangtonLoopCA(150, 150);
        
        loop.init();
//        String[] defaultArgs = { "1000", "50", "loop_", "2" };
        iterateCA(loop, args);
    }
    
    /**
     * Iterate the loop one timestep.
     */    
    public void doStep() {
        int c,t,r,b,l;
        int worldX = getSizeX();
        int worldY = getSizeY();
        for (int X=1; X<worldX-1; X++) {
            for (int Y=1; Y<worldY-1; Y++) {
                c = getWorldAt(X,Y);
                t = getWorldAt(X,Y-1);
                r = getWorldAt(X+1,Y);
                b = getWorldAt(X,Y+1);
                l = getWorldAt(X-1,Y);
                setWorldAt(X,Y, rule[c][t][r][b][l]);
            }
        }
        
        flipBuffer();
    }
    
    /**
     * Initialize the Langton loop.
     */    
    public void init() {
        rule   = new int [9][9][9][9][9];
        
        clearWorld();
        
        for (int i = 0, y = caWorld_y / 2; i < langtonLoop.length; i++, y++) {
            for (int j = 0, x = caWorld_x / 2; j < langtonLoop[i].length(); j++, x++) {
                String s =  langtonLoop[i].substring(j, j+1);
                if (s.equals(" ")) s = "0";
                setWorldAt(x, y, Integer.parseInt(s));
            }
        }
        
        int c,t,r,b,l,i;
        for (int len=0; len <langtonRules.length(); len +=7 )   {
            c = Integer.parseInt(langtonRules.substring(len  , len+1));
            t = Integer.parseInt(langtonRules.substring(len+1, len+2));
            r = Integer.parseInt(langtonRules.substring(len+2, len+3));
            b = Integer.parseInt(langtonRules.substring(len+3, len+4));
            l = Integer.parseInt(langtonRules.substring(len+4, len+5));
            i = Integer.parseInt(langtonRules.substring(len+5, len+6));
            
            rule[c][t][r][b][l] = i;     //       T
            rule[c][l][t][r][b] = i;     //    L  C R   >>=>> I (next state)
            rule[c][b][l][t][r] = i;     //       B
            rule[c][r][b][l][t] = i;     //   (with rotations)
        }

        // Now set up the colours
        Color loopColours[]={ Color.black, Color.blue,   Color.red, 
                              Color.green, Color.yellow, Color.magenta, 
                              Color.white, Color.cyan,   Color.orange };

        setWorldColors(loopColours);
        
        flipBuffer();
    }
    
    private String langtonLoop[] = {
        " 22222222",
        "2170140142",
        "2022222202",
        "272    212",
        "212    212",
        "202    212",
        "272    212",
        "21222222122222",
        "207107107111112",
        " 2222222222222" };
        
    private String langtonRules = new String(
        "000000 000012 000020 000030 000050 000063 000071 000112 000122 000132 000212 "+
        "000220 000230 000262 000272 000320 000525 000622 000722 001022 001120 002020 "+
        "002030 002050 002125 002220 002322 005222 012321 012421 012525 012621 012721 "+
        "012751 014221 014321 014421 014721 016251 017221 017255 017521 017621 017721 "+
        "025271 100011 100061 100077 100111 100121 100211 100244 100277 100511 101011 "+
        "101111 101244 101277 102026 102121 102211 102244 102263 102277 102327 102424 "+
        "102626 102644 102677 102710 102727 105427 111121 111221 111244 111251 111261 "+
        "111277 111522 112121 112221 112244 112251 112277 112321 112424 112621 112727 "+
        "113221 122244 122277 122434 122547 123244 123277 124255 124267 125275 200012 "+
        "200022 200042 200071 200122 200152 200212 200222 200232 200242 200250 200262 "+
        "200272 200326 200423 200517 200522 200575 200722 201022 201122 201222 201422 "+
        "201722 202022 202032 202052 202073 202122 202152 202212 202222 202272 202321 "+
        "202422 202452 202520 202552 202622 202722 203122 203216 203226 203422 204222 "+
        "205122 205212 205222 205521 205725 206222 206722 207122 207222 207422 207722 "+
        "211222 211261 212222 212242 212262 212272 214222 215222 216222 217222 222272 "+
        "222442 222462 222762 222772 300013 300022 300041 300076 300123 300421 300622 "+
        "301021 301220 302511 401120 401220 401250 402120 402221 402326 402520 403221 "+
        "500022 500215 500225 500232 500272 500520 502022 502122 502152 502220 502244 "+
        "502722 512122 512220 512422 512722 600011 600021 602120 612125 612131 612225 "+
        "700077 701120 701220 701250 702120 702221 702251 702321 702525 702720 ");
}
