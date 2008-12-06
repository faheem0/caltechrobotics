/*
 * RankFilter.java
 * Created on 23 December 2004, 13:56
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

package org.generation5.vision;

import java.awt.image.*;

/**
 * This class implements a simple rank filter: allowing you to select the median,
 * minimum or maximum for any given neighbourhood size. Note that this class is
 * <i>unapologetically slow</i>! There are no optimizations at all, to ensure the
 * best code readability.
 *
 * @author James Matthews
 */
public class RankFilter extends Filter {
    /**
     * Calculate the median for the neighbourhood.
     */    
    public final static int MEDIAN = 0;
    /**
     * Retrieve the minimum from the neighbourhood.
     */    
    public final static int MINIMUM = 1;
    /**
     * Retrieve the maximum from the neighbourhood.
     */    
    public final static int MAXIMUM = 2;
    
    /**
     * The neighbourhood size.
     */    
    protected int neighbourhoodSize;
    /**
     * The type of rank position (median, maximum, minimum).
     */    
    protected int rankPosition;
    
    /** Creates a new instance of RankFilter */
    public RankFilter() {
        this(MEDIAN);
    }
    
    /**
     * Creates a new instance of RankFilter, with the given rank type.
     * @param rank the rank type.
     */    
    public RankFilter(int rank) {
        this(rank, 3);
    }
    
    /**
     * Creates a new instance of RankFilter, with the given rank type and neighbourhood
     * size.
     * @param rank the rank type.
     * @param neighbourhoodSize the neighbourhood size.
     */    
    public RankFilter(int rank, int neighbourhoodSize) {
        setRankPosition(rank);
        setNeighbourhoodSize(neighbourhoodSize);
    }
    
    /**
     * Rank filter an image.
     * @return the rank filtered output.
     * @param output the output image (optional).
     * @param image the input image.
     */    
    public BufferedImage filter(BufferedImage image, BufferedImage output) {
        output = verifyOutput(output, image);
        Raster src = image.getRaster();
        WritableRaster out = output.getRaster();
                
        int nb = neighbourhoodSize;
        int hnb = nb / 2;
        int[] pixel = new int[src.getNumBands()];
        int ppos = 0;
        int[] pixels = new int[nb*nb];
        
        int rank;
        switch (rankPosition) {
            default:
            case MEDIAN: rank = (nb*nb-1) / 2; break;
            case MINIMUM: rank = 0; break;
            case MAXIMUM: rank = nb*nb - 1; break;
        }
        
        for (int y=hnb; y<image.getHeight() - hnb; y++) {
            for (int x=hnb; x<image.getWidth() - hnb; x++) {
                // Get the pixels
                ppos = 0;
                for (int j=-hnb; j<hnb+1; j++) {
                    for (int i=-hnb; i<hnb+1; i++) {
                        pixels[ppos++] = image.getRGB(x+i, y+j);
                    }
                }
                
                java.util.Arrays.sort(pixels);
                
                output.setRGB(x, y, pixels[rank]);
            }
        }
        
        return output;
    }
    
    /**
     * Get the neighbourhood size.
     * @return the current neighbourhood size.
     */
    public int getNeighbourhoodSize() {
        return neighbourhoodSize;
    }
    
    /**
     * Set the neighbourhood size. Note that this must be an odd number, an even numbers
     * will be incremented.
     * @param neighbourhoodSize the new neighbourhood size.
     */
    public void setNeighbourhoodSize(int neighbourhoodSize) {
        // Only odd-sized neighbourhoods allowed
        if (neighbourhoodSize % 2 == 0) neighbourhoodSize++;
        
        this.neighbourhoodSize = neighbourhoodSize;
    }
    
    /**
     * Get the rank position.
     * @return the current rank position.
     */
    public int getRankPosition() {
        return rankPosition;
    }
    
    /**
     * Set the rank position. See {@link #MEDIAN}, {@link #MINIMUM} or {@link #MAXIMUM}.
     * @param rankPosition the new rank position.
     */
    public void setRankPosition(int rankPosition) {
        this.rankPosition = rankPosition;
    }
  
    public String toString() {
        switch (rankPosition) {
            default:
            case MEDIAN: return "Median filter (" + neighbourhoodSize + ")";
            case MINIMUM: return "Minimum filter (" + neighbourhoodSize + ")";
            case MAXIMUM: return "Maximum filter (" + neighbourhoodSize + ")";
        }
    }
    
    /**
     * Utility method for the class.
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("usage: java RankFilter <input> <output> {type} {neighbourhood}");
            return;
        }
        
        try {
            BufferedImage in = javax.imageio.ImageIO.read(new java.io.File(args[0]));
             
            RankFilter rank = new RankFilter();
            
            //
            // Retrieve any possible optional parameters
            //
            if (args.length > 2) {
                if (args[2].compareToIgnoreCase("maximum") == 0) rank.setRankPosition(rank.MAXIMUM);
                if (args[2].compareToIgnoreCase("minimum") == 0) rank.setRankPosition(rank.MINIMUM);
            }
            
            if (args.length > 3) rank.setNeighbourhoodSize(Integer.parseInt(args[3]));
            
            // Do the filtering
            BufferedImage out = rank.filter(in);
            // Write the image (FIXME: currently always JPG...)
            javax.imageio.ImageIO.write(out, "jpg", new java.io.File(args[1]));
            
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }    
}
