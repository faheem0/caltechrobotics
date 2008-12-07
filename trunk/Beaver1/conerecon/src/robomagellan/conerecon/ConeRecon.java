/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.conerecon;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author robomagellan
 */
public class ConeRecon {
    private Webcam webcam;
    private static int camNumber = 0;
    private ConeFilter myFilter;
    private volatile int refreshRate;
    private Thread helperThread;
    private volatile ConeInfo info;

    private volatile boolean stopHelper;

    public ConeRecon(String dev){
        try {
            webcam = new Webcam(dev);
            camNumber++;
            myFilter = new ConeFilter();
            refreshRate = 10;
            info = new ConeInfo();
            stopHelper = false;
        } catch (Exception ex) {
            Logger.getLogger(ConeRecon.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public synchronized void setRefresh(int r){
        refreshRate = r;
    }
    public synchronized boolean start(){
        if (helperThread != null && helperThread.isAlive()) return false;
        else {
            webcam.startCapture();
            Runnable runnable = new Runnable(){

                public void run() {
                    BufferedImage tmp, buffer;
                    while(!stopHelper){
                        tmp = webcam.getFrame();
                        buffer = null;
                        buffer = myFilter.filter(tmp, buffer);
                        if (myFilter.isDetected()){
                            int[] coord = myFilter.getCoords();
                            updateInfo(new ConeInfo(true, coord[0], coord[1], buffer));
                        } else {
                            updateInfo(new ConeInfo(false, 0, 0, buffer));
                        }
                    }
                    Logger.getLogger("Webcam Capture Thread Stopped", null);
                }

            };
            helperThread = new Thread(runnable);
            helperThread.start();
            return true;
        }
    }
    public ConeInfo getInfo(){
        return updateInfo(null);
    }
    public synchronized void stop(){
        stopHelper = true;
        try {
            if (helperThread != null)
                helperThread.join();
        } catch (InterruptedException ex) {
            Logger.getLogger(ConeRecon.class.getName()).log(Level.SEVERE, "Interrupted while waiting for helper thread to stop", ex);
        }
        updateInfo(new ConeInfo());

    }
    private synchronized ConeInfo updateInfo(ConeInfo i){
        if (i != null){
            info = i;
            return null;
        }
        else return info;
    }
    public class ConeInfo {
        public boolean detected;
        public int x;
        public int y;
        public Image image;

        public ConeInfo(){
            detected = false;
            x = 0;
            y = 0;
            image = null;
        }
        public ConeInfo(boolean b, int x, int y, Image i){
            detected = b;
            this.x = x;
            this.y = y;
            image = i;
        }
    }
}
