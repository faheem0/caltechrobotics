/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package datacollector;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.gps.*;
/**
 *
 * @author robomagellan
 */
public class Main {

    private FileWriter fstream;
    private BufferedWriter out;
    private static final String directory = "/home/robomagellan/logs/data_captures/";
    private AC12GPS gps;
    private static GPSPacket lastPacket = null;
    private static int number = 0;
    
    public synchronized void log(double east, double north, int type){
        try {
            out.write("<wpt>\n\t<number>" + number + "</number>\n\t<east>" + east + "</east>\n\t<north>" + north + "</north>\t\n<type>" + type + "</type>\n</wpt>\n");
            number++;
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Could not write to file", ex);
        }
    }
    public Main(){
        try {
            fstream = new FileWriter(directory + "Waypoints_" + System.currentTimeMillis() + ".txt");
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Couldn't Create File", ex);
        }
        out = new BufferedWriter(fstream);
        try {
            out.write("<root>\n");
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
        gps = new AC12GPS("/dev/ttyUSB2");
    }
    public void addListeners(){
        try {
            gps.addGPSDataListener(new GPSLogger(this));
            //imu.addIMUDataListener(new IMULogger(this));
            //motors.addEncoderDataListener(new EncoderLogger(this));
        } catch (TooManyListenersException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, "Too Many Listeners", ex);
        }
    }
    public void stop(){
        gps.stop();
        //imu.stop();
        //motors.stop();
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
         main.addListeners();
         Scanner scanner = new Scanner(System.in);
         String scanned;
         scanned = scanner.nextLine();
         while(!scanned.equals("STOP")){
            if (scanned.equals("")){
                System.out.println("Recorded");
                main.log(lastPacket.utmEast, lastPacket.utmNorth, 1);
            } else if (scanned.equalsIgnoreCase("c")){
                main.log(lastPacket.utmEast, lastPacket.utmNorth, 0);
            }
            scanned = scanner.nextLine();
         }
        try {
            main.out.write("</root>");
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
         scanner.close();
        try {
            main.out.close();
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
         main.stop();
    }

    public class GPSLogger implements GPSDataListener{
        Main main;
        public GPSLogger(Main m){
            main = m;
        }
        public void processEvent(GPSPacket p) {
            lastPacket = p;
            System.out.println("GPS: " + p.utmEast + " " + p.utmNorth);
        }
    }
}
