/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.gps;

/**
 *
 * @author robomagellan
 */
public interface GPSDataListener {

    public void processEvent(GPSPacket g);
}
