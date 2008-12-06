/*
 * FlockingAgent.java
 * Created on 21 July 2004, 19:27
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

import java.util.*;
import java.awt.Graphics;

/**
 * Implements an agent that flocks with other similar agents.
 * This code is based on Mike Miller's Java code conversion for 
 * <a href="http://mitpress.mit.edu/books/FLAOH/cbnhtml/home.html" target="_top">The Computational
 * Beauty of Nature</a> by Gary William Flake. The code has been converted to the
 * Generation5 SDK style and system (using Visualizable etc.).
 *
 * @see FlockingAgent
 * @author  James Matthews
 * @author  Mike Miller 
 * @author  Gary William Flake
 *
 */
public class FlockingAgent {
    //    protected static final int tailLen = 10;
    
    /** The random seed used to generate positional data. */
    protected static Random rnd;
    /** The width of the flocking agent's world. */
    protected static int rows;
    /** The height of the flocking agent's world. */
    protected static int cols;
    /** The viewing angle of the agent. */
    protected static double viewA;
    protected static double vAvoidA;
    protected static double minV;
    protected static double copyR;
    protected static double centroidR;
    protected static double avoidR;
    protected static double vAvoidR;
    protected static double copyW;
    protected static double centroidW;
    protected static double avoidW;
    protected static double vAvoidW;
    protected static double randW;
    protected static double dt;
    protected static double ddt;
    
    /** The flock this agent is in. */
    protected static FlockingAgent[] myFlock;
    
    protected static double nx;
    protected static double ny;
    
    /** The x-position of this agent. */
    protected double positionX;
    /** The positionY-position of this agent. */
    protected double positionY;
    /** The x-velocity of this agent. */
    protected double vx;
    /** The y-velocity of this agent. */
    protected double vy;
    /** The x-velocity to be used in the next frame. Remember that the flocking
     *  agents are updated "simultaneously", so they should all have their new values
     *  computed using <code>computeNewHeading</code>, then all have them updated
     *  using <code>update</code>. */
    protected double nvx;
    /** The y-velocity to be used in the next frame. Remember that the flocking
     *  agents are updated "simultaneously", so they should all have their new values
     *  computed using <code>computeNewHeading</code>, then all have them updated
     *  using <code>update</code>. */
    protected double nvy;
    
    /** Creates a new instance of FlockingAgent. Random values are automatically
     * assigned to the positional and velocity variables. */
    public FlockingAgent() {
        // Set the random position of the FA
        positionX = Math.abs(rnd.nextInt() % cols);
        positionY = Math.abs(rnd.nextInt() % rows);
        // Set the random velocity
        vx = 2*rnd.nextDouble()-1;
        vy = 2*rnd.nextDouble()-1;
        // Normalize the results
        normalize(vx, vy);   vx = nx;   vy = ny;
    }
    
    public static void initMisc(Random r, int rr, int cc, /*Viewer v,*/
    double va, double vaa, double mv) {
        rnd     = r;
        rows    = rr;
        cols    = cc;
        viewA   = va * Math.PI / 180.0;
        vAvoidA = vaa * Math.PI / 180.0;
        minV    = mv;
    }
    
    public static void initRadii(double cr, double ccr, double ar, double vr) {
        copyR     = cr;
        centroidR = ccr;
        avoidR    = ar;
        vAvoidR   = vr;
    }
    
    public static void initWeights(double cw, double ccw, double aw, double vw,
    double rw) {
        copyW     = cw;
        centroidW = ccw;
        avoidW    = aw;
        vAvoidW   = vw;
        randW     = rw;
    }
    
    public static void initTime(double t, double tt) {
        dt  = t;
        ddt = tt;
    }
    
    public static void setFlock(FlockingAgent[] flock) {
        // FIXME: Check to see if this is member flock?s
        // FIXME: This shouldn't be static if we want multiple flocks.
        myFlock = flock;
    }
    
    protected static void normalize(double x, double y) {
        // FIXME: Don't like the way this is done, not very OOP. Returning an
        // FIXME: array might have a performance hit though.
        double l = len(x, y);
        if (l != 0.0) {
            nx = x/l;
            ny = y/l;
        }
    }
    
    protected static double len(double x, double y) {
        // TODO: Is it worth sqrting this?
        return Math.sqrt(x*x + y*y);
    }
    
    protected static double dist(double x1, double y1, double x2, double y2) {
        return len(x2-x1, y2-y1);
    }
    
    protected static double dot(double x1, double y1, double x2, double y2) {
        return (x1*x2 + y1*y2);
    }
    
    /**
     *
     * @param self
     */    
    public void computeNewHeading(int self) {
        int numcent = 0;
        double xa = 0, ya = 0, xb = 0, yb = 0;
        double xc = 0, yc = 0, xd = 0, yd = 0, xt = 0, yt = 0;
        double mindist, mx = 0, my = 0, d;
        double cosangle, cosvangle, costemp;
        double xtemp, ytemp, maxr, u, v;
        double ss;
        
        // Maximum radius of visual avoidance, copy, centroid and avoidance.
        maxr = Math.max(vAvoidR,Math.max(copyR,Math.max(centroidR, avoidR)));
        // The cosine of the viewing and visual avoidance angles.
        cosangle = Math.cos(viewA / 2);
        cosvangle = Math.cos(vAvoidA / 2);
        
        int numBoids = myFlock.length;
        for (int b=0; b<numBoids; b++) {
            if (b == self) continue;
            
            mindist = Double.MAX_VALUE;
            for (int j=-cols; j<=cols; j+=cols) {
                for (int k=-rows; k<=rows; k+=rows) {
                    d = dist(myFlock[b].positionX+j, myFlock[b].positionY+k, 
                             positionX, positionY);
                    if (d < mindist) {
                        mindist = d;
                        mx = myFlock[b].positionX+j;
                        my = myFlock[b].positionY+k;
                    }
                }
            }
            
            if (mindist > maxr) continue;
            
            xtemp = mx-positionX;   ytemp = my-positionY;
            costemp = dot(vx, vy, xtemp, ytemp) /
                     (len(vx, vy) * len(xtemp, ytemp));
            if (costemp < cosangle) continue;
            
            if ((mindist <= centroidR) && (mindist > avoidR)) {
                xa += mx-positionX;
                ya += my-positionY;
                numcent++;
            }
            
            if ((mindist <= copyR) && (mindist > avoidR)) {
                xb += myFlock[b].vx;
                yb += myFlock[b].vy;
            }
            
            if (mindist <= avoidR) {
                xtemp = positionX-mx;
                ytemp = positionY-my;
                d = 1 / len(xtemp, ytemp);
                xtemp *= d;
                ytemp *= d;
                xc += xtemp;
                yc += ytemp;
            }
            
            if ((mindist <= vAvoidR) && (cosvangle < costemp)) {
                xtemp = positionX-mx;
                ytemp = positionY-my;
                
                u = v = 0;
                if ((xtemp != 0) && (ytemp != 0)) {
                    ss = (ytemp/xtemp);
                    ss *= ss;
                    u = Math.sqrt(ss / (1+ss));
                    v = -xtemp * u/ytemp;
                } else if (xtemp != 0) {
                    u=1;
                } else if (ytemp != 0) {
                    v=1;
                }
                
                if ((vx*u + vy*v) < 0) {
                    u = -u;
                    v = -v;
                }
                
                u = positionX - mx + u;
                v = positionY - my + v;
                
                d = len(xtemp, ytemp);
                if (d != 0) {
                    u /= d;
                    v /= d;
                }
                xd += u;
                yd += v;
            }
        }
        
        if (numcent < 2) xa = ya = 0;
        
        if (len(xa, ya) > 1.0) { normalize(xa, ya);  xa = nx;  ya = ny; }
        if (len(xb, yb) > 1.0) { normalize(xb, yb);  xb = nx;  yb = ny; }
        if (len(xc, yc) > 1.0) { normalize(xc, yc);  xc = nx;  yc = ny; }
        if (len(xd, yd) > 1.0) { normalize(xd, yd);  xd = nx;  yd = ny; }
        
        xt = centroidW*xa + copyW*xb + avoidW*xc + vAvoidW*xd;
        yt = centroidW*ya + copyW*yb + avoidW*yc + vAvoidW*yd;
        
        if (randW > 0) {
            xt += randW * (2*rnd.nextDouble() - 1);
            yt += randW * (2*rnd.nextDouble() - 1);
        }
        
        nvx = vx*ddt + xt*(1-ddt);
        nvy = vy*ddt + yt*(1-ddt);
        d = len(nvx, nvy);
        if (d < minV) {
            nvx *= minV/d;
            nvy *= minV/d;
        }
    }
    
    public void update() {
        vx = nvx;
        vy = nvy;
        positionX += vx*dt;
        positionY += vy*dt;
        
        // Apply torodial geometry (wrap around)
        if (positionX < 0) positionX += cols;
        else if (positionX >= cols) positionX -= cols;
        if (positionY < 0) positionY += rows;
        else if (positionY >= rows)	positionY -= rows;
    }
    
    public void render(Graphics graphics, int sx, int sy) {
        double x1, x2, x3, y1, y2, y3, a, t, aa;
        double tailLen = 10.0;
        
        // direction line
        x3 = vx;
        y3 = vy;
        normalize(x3, y3);   x3 = nx;   y3 = ny;
        x1 = positionX;
        y1 = positionY;
        x2 = x1 - x3*tailLen;
        y2 = y1 - y3*tailLen;
        graphics.drawLine((int) x1+sx, (int) y1+sy,
                          (int) x2+sx, (int) y2+sy);

        // head
        t = (x1-x2) / tailLen;
        t = (t < -1) ? -1 : (t > 1) ? 1 : t;
        a = Math.acos(t);
        a = (y1-y2) < 0 ? -a : a;
 
        // head	(right)
        aa = a + viewA/2;
        x3 = x1 + Math.cos(aa) * tailLen / 3.0;
        y3 = y1 + Math.sin(aa) * tailLen / 3.0;
        graphics.drawLine((int) x1+sx, (int) y1+sy,
                          (int) x3+sx, (int) y3+sy);
 
        // head	(left)
        aa = a - viewA/2;
        x3 = x1 + Math.cos(aa) * tailLen / 3.0;
        y3 = y1 + Math.sin(aa) * tailLen / 3.0;
        graphics.drawLine((int) x1+sx, (int) y1+sy,
                          (int) x3+sx, (int) y3+sy);
    }
}
