/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.main;

import org.jdesktop.swingx.mapviewer.DefaultTileFactory;
import org.jdesktop.swingx.mapviewer.TileFactory;
import org.jdesktop.swingx.mapviewer.TileFactoryInfo;

/**
 * Google Map Tile Provider from
 * http://www.softonaut.com/2008/06/30/swinglabs-jmapkit-and-google-maps/
 * @author robomagellan
 */
public class GoogleMapsTileProvider {

    private static final String TER_VERSION = "2p.87";
    private static final String STREET_VERSION = "2.92";
    private static final String SAT_VERSION = "37";
    private static final int minZoom = 1;
    private static final int maxZoom = 16;
    private static final int mapZoom = 17;
    private static final int tileSize = 256;
    private static final boolean xr2l = true;
    private static final boolean yt2b = true;
    private static final String terrainBaseURL = "http://mt1.google.com/mt/n=404&v=w" + TER_VERSION;
    private static final String streetBaseURL = "http://mt1.google.com/mt/n=404&v=w" + STREET_VERSION;
    private static final String satBaseURL = "http://khm0.google.com/kh/n=404&v=w" + SAT_VERSION;
    private static final String x = "x";
    private static final String y = "y";
    private static final String z = "zoom";
    private static final TileFactoryInfo GOOGLE_MAPS_TILE_INFO_TERRAIN = new TileFactoryInfo(
            minZoom, maxZoom-1, mapZoom, tileSize, xr2l,
            yt2b, terrainBaseURL, x, y, z);
    private static final TileFactoryInfo GOOGLE_MAPS_TILE_INFO_STREET = new TileFactoryInfo(
            minZoom, maxZoom, mapZoom, tileSize, xr2l,
            yt2b, streetBaseURL, x, y, z);
    private static final TileFactoryInfo GOOGLE_MAPS_TILE_INFO_SAT = new TileFactoryInfo(
            minZoom, maxZoom, mapZoom, tileSize, xr2l,
            yt2b, satBaseURL, x, y, z);

    public static TileFactory getDefaultTileFactory() {

        return (new DefaultTileFactory(
                GOOGLE_MAPS_TILE_INFO_TERRAIN));

    }

    public static TileFactory getStreetTileFactory() {

        return (new DefaultTileFactory(
                GOOGLE_MAPS_TILE_INFO_STREET));

    }

    public static TileFactory getSatTileFactory() {

        return (new DefaultTileFactory(
                GOOGLE_MAPS_TILE_INFO_SAT));

    }
}

