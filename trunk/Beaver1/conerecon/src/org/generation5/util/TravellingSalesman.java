/*
 * TravellingSalesman.java
 * Created on 09 August 2004, 19:55
 *
 * TODO: Distances should probably be cached in a lookup table.
 * TODO: Support TSPLIB files for data importing.
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

import org.generation5.*;

/**
 * A utility class that provides the necessary methods for calculating route length,
 * managing cities and rendering the scenario. The route is stored as a simple
 * <code>int[]</code>, with each integer corresponding to the city to visit (as
 * defined within <code>cityCoordinates</code>). The route is circular, so the route
 * is calculated as follows:
 * <code>
 *    for (int i=0; i<route.length; i++) {
 *        i1 route[i];
 *        i2 = route[(i+1) % route.length];
 *        distance += cityDistance(i1, i2);
 *    }
 * </code>
 * <b>Important:</b> no validation of the route is done for flexibility.
 * 
 * My thanks to Simon Cogan for his insight into the life of a travelling salesman.
 *
 * @author James Matthews
 * @author Simon Cogan
 */
public class TravellingSalesman implements Visualizable {
    /**
     * The city coordinates.
     */    
    static protected int[][] cityCoordinates;
    /**
     * The maximum x-dimension for the city coordinates.
     */    
    static protected int maximumX = 100;
    /**
     * The maximum y-dimension for the city coordinates.
     */    
    static protected int maximumY = 100;
    /**
     * The maximum number of cities in the world.
     */    
    static protected int maximumCities = 64;
    /**
     * The number of cities in the world.
     */    
    static protected int numberCities = 0;
    /**
     * Optional labels for each city.
     */    
    static protected String[] nodeLabels;
    /**
     * The gradient rendered for the route. This helps visualize the route from start
     * to finish when rendered.
     */    
    static protected Gradient routeGradient = new Gradient();
    
    /**
     * The route to use.
     */    
    protected int[] route;
   
    /** Creates a new instance of TravellingSalesman */
    public TravellingSalesman() {
    }
    
    /**
     * Set the maximum number of cities allowed within the world. This method allocates
     * the necessary memory, as well as calculating the gradient.
     * @param maxCities the maximum number of cities.
     */    
    static public void setMaximumCities(int maxCities) {
        maximumCities = maxCities;
        cityCoordinates = new int[maxCities][2];

        nodeLabels = new String[maxCities];
        routeGradient.addPoint(java.awt.Color.WHITE);
        routeGradient.addPoint(java.awt.Color.BLUE);
        routeGradient.createGradient(maxCities);
    }
    
    /**
     * Set the maximum world dimensions. World is assumed to extend from 0 to mx, 0 to
     * my.
     * @param mx maximum x-dimension.
     * @param my maximum y-dimension.
     */    
    static public void setDimension(int mx, int my) {
        maximumX = mx;
        maximumY = my;
    }
    
    /**
     * Removes all cities from the world.
     */    
    static public void resetCities() {
        numberCities = 0;
    }
    
    /**
     * Retrieve the x-dimension.
     * @return the x-dimension.
     */    
    static public int getDimensionX() {
        return maximumX;
    }
    
    /**
     * Retrieve the y-dimension.
     * @return the y-dimension.
     */    
    static public int getDimensionY() {
        return maximumY;
    }
    
    /**
     * Add a city to the world at position (x,y). This version of the method adds a
     * default label of the form "<i>i: (x,y)</i>" where i is index of the city.
     * @param x x-position of the house.
     * @param y y-position of the house.
     */    
    static public void addCity(int x, int y) {
        String label = new String();
        label = numberCities + ": (" + x + "," + y + ")";
        
        addCity(x, y, label);
    }
    
    /**
     * Calculates total distance travelled within the world using the given route.
     * @param route the route to take.
     * @return the total distance travelled.
     */    
    static public double routeLength(int[] route) {
        int c1, c2;
        double distance = 0;
        for (int i=0; i<route.length; i++) {
            c1 = route[i];
            c2 = route[(i+1) % route.length];
            distance += getCityDistance(c1, c2);
        }
        
        return distance;
    }
    
    /**
     * Returns the length for this route.
     * @return total distance travelled.
     */    
    public double routeLength() {
        return routeLength(route);
    }
    
    /**
     * Add a city of position x, y with specified label.
     * @param x the x-position.
     * @param y the y-position.
     * @param label the city's label.
     */    
    static public void addCity(int x, int y, String label) {
        if (numberCities > maximumCities)
            throw new IllegalArgumentException("numberCities > maximumCities");
        if (x > maximumX)
            throw new IllegalArgumentException("x greater than dimension");
        if (y > maximumY)
            throw new IllegalArgumentException("y greater than dimension");
        
        cityCoordinates[numberCities][0] = x;
        cityCoordinates[numberCities][1] = y;
        nodeLabels[numberCities] = label;
        
        numberCities++;
    }
    
    /**
     * Retrieves the distance between two cities. The method takes two integers
     * corresponding to the indices within the <code>cityCoordinates</code> array.
     * @param i1 index of city one.
     * @param i2 index of city two.
     * @return the distance between the two cities.
     */    
    public static double getCityDistance(int i1, int i2) {
        return java.awt.Point.distance(
                            cityCoordinates[i1][0], 
                            cityCoordinates[i1][1],
                            cityCoordinates[i2][0],
                            cityCoordinates[i2][1]);
    }
    
    /**
     * Render the map and route with labels on a graphics context.
     * @param g the graphics context.
     * @param width the width of the context.
     * @param height the height of the context.
     */    
    public void render(java.awt.Graphics g, int width, int height) {
        double dx = (double)width / maximumX;
        double dy = (double)height / maximumY;
        if (route != null) {
            int d1, d2;
            for (int i=0; i<route.length; i++) {
                g.setColor(routeGradient.getColour(i));
                d1 = route[i];
                d2 = route[(i+1) % route.length];
                g.drawLine((int)(cityCoordinates[d1][0]*dx), 
                           (int)(cityCoordinates[d1][1]*dy),
                           (int)(cityCoordinates[d2][0]*dx), 
                           (int)(cityCoordinates[d2][1]*dy));
            }
        }
        g.setColor(java.awt.Color.white);
        for (int i=0; i<numberCities; i++) {
            g.drawRect((int)(cityCoordinates[i][0]*dx)-1, 
                       (int)(cityCoordinates[i][1]*dy)-1, 3, 3);
        }
        
        for (int i=0; i<numberCities; i++) {
            g.drawString(nodeLabels[i], 
                       (int)(cityCoordinates[i][0]*dx)-1, 
                       (int)(cityCoordinates[i][1]*dy)-1);
        }
        
    }
    
    /**
     * Write the map, route and labels to an image.
     * @param s the image filename.
     * @param width the image width.
     * @param height the image height.
     */    
    public void writeImage(String s, int width, int height) {
        try {
            ImageHelper.writeVisualizedImage(s, width, height, this);
        } catch (java.io.IOException e) {
            System.err.println("Error writing image.");
        }
    }

    /**
     * A basic test function.
     * @param args command-line arguments (ignored).
     */    
    public static void main(String[] args) {
        TravellingSalesman tsp = new TravellingSalesman();
        
        TravellingSalesman.setMaximumCities(25);
        int[] route = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
        tsp.route = route;
        TravellingSalesman.setDimension(640,480);
        
        for (int i=0; i<25; i++) {
            tsp.addCity((int)(Math.random() * tsp.getDimensionX()),
			(int)(Math.random() * tsp.getDimensionY()));
        }
        
        tsp.writeImage("tsp-world.png", 640, 480);
    }
    
    /**
     * Return the specified city coordinates.
     * @param i the index of the city to return.
     * @return the coordinates of the city.
     */    
    public static int[] getCity(int i) {
        return cityCoordinates[i];
    }
}
