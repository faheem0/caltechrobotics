/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import jama.Matrix;
import java.awt.EventQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
import jkalman.JKalman;
import robomagellan.compass.CompassDataListener;
import robomagellan.compass.CompassPacket;
import robomagellan.gps.GPSDataListener;
import robomagellan.gps.GPSPacket;
import robomagellan.imu.IMUDataListener;
import robomagellan.imu.IMUPacket;
import robomagellan.motors.EncoderDataListener;
import robomagellan.motors.EncoderPacket;

/**
 * Kalman Filter wrapper for JKalman
 * @author robomagellan
 */
public class KalmanFilter 
        implements GPSDataListener, IMUDataListener, CompassDataListener, EncoderDataListener{

    // TODO: NEED TO IMPLEMENT KALMAN FILTER

    private static final int TYPE_GPS = 0;
    private static final int TYPE_IMU = 1;
    private static final int TYPE_COMPASS = 2;
    private static final int TYPE_ENCODER = 3;

    /**
     * Number of Measurement Parameters: (GPS) + (Compass) + (Accel)
     */
    private static final int NUM_MEASUREMENT_PARAM = 2 + 1 + 3;

    /**
     * Number of Control Parameters: (Accel) + (Gyro)
     */
    private static final int NUM_CONTROL_PARAM = 3 + 3;

    /**
     * Number of Dynamic Parameters (State variables): (Position) + (Velocity) + (Heading)
     */
    private static final int NUM_DYNAMIC_PARAM = 3 + 3 + 3;

    private static final int STATE_POS_X = 0;
    private static final int STATE_POS_Y = 1;
    private static final int STATE_POS_Z = 2;
    private static final int STATE_PITCH = 6;
    private static final int STATE_ROLL = 7;
    private static final int STATE_YAW = 8;

    private static final int CONTROL_ACC_X = 0;
    private static final int CONTROL_ACC_Y = 1;
    private static final int CONTROL_ACC_Z = 2;
    private static final int CONTROL_GYRO_X = 3;
    private static final int CONTROL_GYRO_Y = 4;
    private static final int CONTROL_GYRO_Z = 5;

    private boolean gps_corrected, compass_corrected;

    private long last_time;
    private double currentEast, currentEastVel;
    private double currentNorth, currentNorthVel;
    private double currentHeading;
    private volatile boolean gps_connected, compass_connected;
    private static double gRatio = 0.80;
    private static double cRatio = 0.80;


    public KalmanFilter() throws Exception{
        
        gps_corrected = false;
        compass_corrected = false;

        last_time = System.nanoTime();
        currentEast = 0;
        currentNorth = 0;
        currentEastVel = 0;
        currentNorthVel = 0;
        currentHeading = 0;
        gps_connected = false;
        compass_connected = false;
    }
    /**
     * Retrieves the current, filtered coordinates of the robot
     * @return Coordinates of robot
     */
    public GPSPacket getHorizPosition(){
        while (!gps_connected){
            try {
                Thread.sleep(100);
            } catch (InterruptedException ex) {
                Logger.getLogger(KalmanFilter.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        GPSPacket packet = new GPSPacket();
        packet.utmEast = currentEast;
        packet.utmNorth = currentNorth;

        final GPSPacket p = packet;
        EventQueue.invokeLater(new Runnable(){
            public void run() {
                MainView.statTableData.setValueAt(p.utmEast, MainView.STATTABLE_KALMAN_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
                MainView.statTableData.setValueAt(p.utmNorth, MainView.STATTABLE_KALMAN_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
            }
        });

        return packet;
        /*GPSPacket p = new GPSPacket();
        Matrix state;
        if (gps_corrected) {
            state = this.getState_post();
        } else {
            state = this.getState_pre();
        }
        p.utmEast = state.get(STATE_POS_X, 0);
        p.utmNorth = state.get(STATE_POS_Y, 0);
        return p;*/
    }
    /**
     * Retrieves the current heading of the robot. 0 being North, rotating clockwise.
     * @return The current heading in degrees
     */
    public double getHeading(){
        while(!compass_connected){
            try {
                Thread.sleep(100);
            } catch (InterruptedException ex) {
                Logger.getLogger(KalmanFilter.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

        final double deg = Math.toDegrees(currentHeading);
         EventQueue.invokeLater(new Runnable(){
            public void run() {
                MainView.statTableData.setValueAt(deg, MainView.STATTABLE_KALMAN_ROW_LOC, MainView.STATTABLE_Z_COL_LOC);
            }
        });

        return deg;
        /*Matrix state;
        if (compass_corrected) {
            state = this.getState_post();
        } else {
            state = this.getState_pre();
        }
        return state.get(STATE_YAW, 0);*/
    }

    //Helper Function
    private synchronized void process(int type, GPSPacket g, IMUPacket i, CompassPacket c, EncoderPacket p){
        long current_time = System.nanoTime();
        double dt = (current_time - last_time)*10^-9;
        last_time = current_time;

        switch (type){
            case TYPE_GPS:
                currentNorth = (1-gRatio)*currentNorth + gRatio*g.utmNorth;
                currentEast = (1-gRatio)*currentEast + gRatio*g.utmEast;
                gps_corrected = true;
                gps_connected = true;
                break;
            case TYPE_IMU:
                /*double northAcc = (i.accX*Math.cos(currentHeading) - i.accY*Math.sin(currentHeading));
                double eastAcc = (i.accX*Math.sin(currentHeading) + i.accY*Math.cos(currentHeading));
                currentNorth += currentNorthVel*dt;
                currentEast += currentEastVel*dt;
                currentNorthVel += northAcc*dt;
                currentEastVel += eastAcc*dt;
                currentHeading -= i.gyroZ*dt;*/
                gps_corrected = false;
                compass_corrected = false;
                break;
            case TYPE_COMPASS:
                currentHeading = (1-cRatio)*Math.toRadians(c.heading) + cRatio*currentHeading;
                compass_connected = true;
                compass_corrected = true;
                //System.out.println("Current Heading:" + currentHeading);
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
        final GPSPacket p = g;
        EventQueue.invokeLater(new Runnable(){
            public void run() {
                MainView.statTableData.setValueAt(p.utmEast, MainView.STATTABLE_GPS_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
                MainView.statTableData.setValueAt(p.utmNorth, MainView.STATTABLE_GPS_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
            }
        });

        MainView.log("GPS Update: " + g.utmEast + " " + g.utmNorth);
        process(TYPE_GPS, g, null, null, null);
    }

    /**
     * IMU Calls this function
     * @param p Input IMU Packet
     */
    public void processEvent(IMUPacket p) {
        final IMUPacket i = p;
        EventQueue.invokeLater(new Runnable(){
            public void run() {
                MainView.statTableData.setValueAt(i.accX, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
                MainView.statTableData.setValueAt(i.accY, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
                MainView.statTableData.setValueAt(i.accZ, MainView.STATTABLE_ACC_ROW_LOC, MainView.STATTABLE_Z_COL_LOC);
                MainView.statTableData.setValueAt(i.gyroX, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
                MainView.statTableData.setValueAt(i.gyroY, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
                MainView.statTableData.setValueAt(i.gyroZ, MainView.STATTABLE_GYRO_ROW_LOC, MainView.STATTABLE_Z_COL_LOC);
            }
        });
       

        //MainView.log("IMU Update");
        process(TYPE_IMU, null, p, null, null);
    }
    /**
     * Compass Calls this function
     * @param c Input Compass Packet
     */
    public void processEvent(CompassPacket c) {
        final CompassPacket p = c;
        EventQueue.invokeLater(new Runnable(){

            public void run() {
                MainView.statTableData.setValueAt(p.heading, MainView.STATTABLE_COMPASS_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
            }
        });

        //MainView.log("Compass Update: " + c.heading);
        process(TYPE_COMPASS, null, null, c, null);
    }

    /**
     * Motors Call this function
     * @param p Input Encoder Packet
     */
    public void processEvent(EncoderPacket p) {
        //MainView.statTableData.setValueAt(p.velLeft, MainView.STATTABLE_ENCODER_ROW_LOC, MainView.STATTABLE_X_COL_LOC);
        //MainView.statTableData.setValueAt(p.velRight, MainView.STATTABLE_ENCODER_ROW_LOC, MainView.STATTABLE_Y_COL_LOC);
        process(TYPE_ENCODER, null, null, null, p);
    }

}
