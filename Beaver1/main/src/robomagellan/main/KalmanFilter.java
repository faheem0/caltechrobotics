/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import robomagellan.compass.CompassDataListener;
import robomagellan.compass.CompassPacket;
import robomagellan.gps.GPSDataListener;
import robomagellan.gps.GPSPacket;
import robomagellan.imu.IMUDataListener;
import robomagellan.imu.IMUPacket;
import robomagellan.motors.EncoderDataListener;
import robomagellan.motors.EncoderPacket;

/**
 *
 * @author robomagellan
 */
public class KalmanFilter implements GPSDataListener, IMUDataListener, CompassDataListener, EncoderDataListener{

    // TODO: NEED TO IMPLEMENT KALMAN FILTER

    private static final int TYPE_GPS = 0;
    private static final int TYPE_IMU = 1;
    private static final int TYPE_COMPASS = 2;
    private static final int TYPE_ENCODER = 3;

    public GPSPacket getCoordinates(){
        return null;
    }
    public double getBearing(){
        return 0.0;
    }

    public synchronized void process(int type, GPSPacket g, IMUPacket i, CompassPacket c, EncoderPacket p){
        switch (type){
            case TYPE_GPS:
                break;
            case TYPE_IMU:
                break;
            case TYPE_COMPASS:
                break;
            case TYPE_ENCODER:
                break;
        }
    }
    public void processEvent(GPSPacket g) {
        process(TYPE_GPS, g, null, null, null);
    }

    public void processEvent(IMUPacket p) {
        process(TYPE_IMU, null, p, null, null);
    }

    public void processEvent(CompassPacket c) {
        process(TYPE_COMPASS, null, null, c, null);
    }

    public void processEvent(EncoderPacket p) {
        process(TYPE_ENCODER, null, null, null, p);
    }

}
