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

    /**
     * Retrieves the current, filtered coordinates of the robot
     * @return Coordinates of robot
     */
    public GPSPacket getCoordinates(){
        return null;
    }
    /**
     * Retrieves the current heading of the robot. 0 being North, rotating clockwise.
     * @return The current heading in degrees
     */
    public double getBearing(){
        return 0.0;
    }

    //Helper Function
    private synchronized void process(int type, GPSPacket g, IMUPacket i, CompassPacket c, EncoderPacket p){
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
    /**
     * GPS Calls this function
     * @param g Input GPS Packet
     */
    public void processEvent(GPSPacket g) {
        MainView.wpTableData.setValueAt(g.utmEast, MainView.STATTABLE_GPS_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
        MainView.wpTableData.setValueAt(g.utmNorth, MainView.STATTABLE_GPS_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
        process(TYPE_GPS, g, null, null, null);
    }

    /**
     * IMU Calls this function
     * @param p Input IMU Packet
     */
    public void processEvent(IMUPacket p) {
        MainView.wpTableData.setValueAt(p.accX, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
        MainView.wpTableData.setValueAt(p.accY, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
        MainView.wpTableData.setValueAt(p.accZ, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_Z_COL_LOC);
        MainView.wpTableData.setValueAt(p.gyroX, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
        MainView.wpTableData.setValueAt(p.gyroY, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
        MainView.wpTableData.setValueAt(p.gyroZ, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_Z_COL_LOC);

        process(TYPE_IMU, null, p, null, null);
    }
    /**
     * Compass Calls this function
     * @param c Input Compass Packet
     */
    public void processEvent(CompassPacket c) {
        MainView.wpTableData.setValueAt(c.heading, MainView.STATTABLE_COMPASS_ROW_LOC, MainView.STATTABLE_X_COL_LOC);

        process(TYPE_COMPASS, null, null, c, null);
    }

    /**
     * Motors Call this function
     * @param p Input Encoder Packet
     */
    public void processEvent(EncoderPacket p) {
        MainView.wpTableData.setValueAt(p.velLeft, MainView.STATTABLE_ENCODER_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
        MainView.wpTableData.setValueAt(p.velRight, MainView.STATTABLE_ENCODER_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
        process(TYPE_ENCODER, null, null, null, p);
    }

}
