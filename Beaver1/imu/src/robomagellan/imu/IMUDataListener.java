/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.imu;

/**
 *
 * @author robomagellan
 */
public interface IMUDataListener {
    public void processEvent(IMUPacket p);
}
