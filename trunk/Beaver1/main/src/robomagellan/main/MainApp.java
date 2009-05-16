/*
 * MainApp.java
 */

package robomagellan.main;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.Task;
import robomagellan.compass.Compass;
import robomagellan.conerecon.ConeRecon;
import robomagellan.gps.AC12GPS;
import robomagellan.imu.CristaIMU;
import robomagellan.motors.Motors;

/**
 * The main class of the application.
 */
public class MainApp extends SingleFrameApplication {
    public static List<String> serialPortList;

    public static String motorPort, gpsPort, imuPort, compassPort, webcamPort;
    public static Compass compass;
    public static AC12GPS gps;
    public static CristaIMU imu;
    public static Motors motors;
    public static ConeRecon cam;
    public static KalmanFilter filter;
    public static Task runTask;

    /**
     * Queue of waypoints that need to be processed
     */
    public static LinkedBlockingQueue<Waypoint> wpts = new LinkedBlockingQueue<Waypoint>();

    /**
     * The current waypoint
     */
    public static volatile Waypoint currentWpt;


    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        try {
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.motif.MotifLookAndFeel");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(MainApp.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            Logger.getLogger(MainApp.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            Logger.getLogger(MainApp.class.getName()).log(Level.SEVERE, null, ex);
        } catch (UnsupportedLookAndFeelException ex) {
            Logger.getLogger(MainApp.class.getName()).log(Level.SEVERE, null, ex);
        }
        show(new MainView(this));
    }

    /**
     * This method is to initialize the specified window by injecting resources.
     * Windows shown in our application come fully initialized from the GUI
     * builder, so this additional configuration is not needed.
     */
    @Override protected void configureWindow(java.awt.Window root) {
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of MainApp
     */
    public static MainApp getApplication() {
        return Application.getInstance(MainApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(MainApp.class, args);
    }

    public static List<String> getVideoDevices() {
        List<String> dev = new ArrayList<String>();
        try {
            Process p = Runtime.getRuntime().exec("ls /dev");
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String s;
            while ((s = stdInput.readLine()) != null) {
                if (s.matches("video\\d*")){
                    s = s.trim();
                    dev.add("/dev/" + s);
                }
            }
            stdInput.close();
        } catch (IOException ex) {
            Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
        }
        return dev;
    }
}
