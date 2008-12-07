/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package datacollector;
import datacollector.Main.CompassLogger;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.compass.*;
import robomagellan.gps.*;
import robomagellan.imu.*;
import robomagellan.motors.*;
/**
 *
 * @author robomagellan
 */
public class Main {

    private FileWriter fstream;
    private BufferedWriter out;
    private static final String directory = "/home/robomagellan/logs/data_captures/";
    private Compass compass;
    private AC12GPS gps;
    private CristaIMU imu;
    private Motors motors;
    
    public synchronized void log(String s){
        try {
            out.write(System.currentTimeMillis() + s);
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Could not write to file", ex);
        }
    }
    public Main(){
        try {
            fstream = new FileWriter(directory + System.currentTimeMillis() + ".txt");
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Couldn't Create File", ex);
        }
        out = new BufferedWriter(fstream);

        compass = new Compass("/dev/ttyUSB0");
        gps = new AC12GPS("/dev/ttyUSB1");
        imu = new CristaIMU("/dev/ttyUSB2");
        motors = new Motors("/dev/ttyUSB3");
    }
    public void addListeners(){
        try {
            compass.addCompassDataListener(new CompassLogger(this));
            gps.addGPSDataListener(new GPSLogger(this));
            imu.addIMUDataListener(new IMULogger(this));
            motors.addEncoderDataListener(new EncoderLogger(this));
        } catch (TooManyListenersException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Too Many Listeners", ex);
        }
    }
    public void stop(){
        compass.stop();
        gps.stop();
        imu.stop();
        motors.stop();
        try {
            out.close();
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Could not close BufferedWriter", ex);
        }
    }
    /**
     * @param args the command line arguments
     */

    public static void main(String[] args) {
         Main main = new Main();
         Scanner scanner = new Scanner(System.in);
         while(!scanner.nextLine().equals("STOP")){

         }
         main.stop();
    }

    public class CompassLogger implements CompassDataListener{
        Main main;
        public CompassLogger(Main m){
            main = m;
        }
        public void processEvent(CompassPacket c) {
            main.log("<Compass>" + c.heading + "</Compass>");
        }
    }

    public class GPSLogger implements GPSDataListener{
        Main main;
        public GPSLogger(Main m){
            main = m;
        }
        public void processEvent(GPSPacket p) {
            main.log("<GPS>" + p.utmEast + ":" + p.utmNorth + ":" + p.precision + ":" + p.time + "</GPS>");
        }
    }
    public class IMULogger implements IMUDataListener{
        Main main;
        public IMULogger(Main m){
            main = m;
        }
        public void processEvent(IMUPacket p) {
            main.log("<IMU>" + p.gyroX + ":" + p.gyroY + ":" + p.gyroZ + ":" + p.accX + ":" + p.accY + ":" + p.accZ + ":" + "</IMU>");
        }
    }
    public class EncoderLogger implements EncoderDataListener{
         Main main;
        public EncoderLogger(Main m){
            main = m;
        }
        public void processEvent(EncoderPacket p) {
            main.log("<Encoder>" +  "</Encoder>");
        }
    }
}
