/*
 * Atlas.java
 *
 * Created on November 6, 2007, 6:12 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package RobotLib;
import java.io.*;
/**
 * @version 0.0.1
 * @author tonyfwu
 */
public class Atlas extends Robot{
    
    /**
     *The number of bytes for the Infrared Detector sequence
     */
    public static int IR_BYTE_SIZE = 90;
    /**
     *The number of bytes for the Ultrasonic Detector sequence
     */
    public static int US_BYTE_SIZE = 90;
    /**
     *The number of bytes for the GPS sequence
     */
    public static int GPS_BYTE_SIZE = 90;
    /**
     *The number of bytes for the Compass sequence
     */
    public static int Compass_BYTE_SIZE = 90;
    
    private int[] IR_Data, US_Data, GPS_Data, Compass_Data;
    private AtlasHelper helper;
    
    /** Creates a new instance of Atlas */
    public Atlas(String portName) {
        super(portName);
        IR_Data = new int[IR_BYTE_SIZE];
        IR_Data[0] = -1;
        US_Data = new int[US_BYTE_SIZE];
        US_Data[0] = -1;
        GPS_Data = new int[GPS_BYTE_SIZE];
        GPS_Data[0] = -1;
        Compass_Data = new int[Compass_BYTE_SIZE];
        Compass_Data[0] = -1;
        helper = new AtlasHelper(this.input, IR_Data, US_Data, GPS_Data, Compass_Data);
    }
    /** Retrieves the data from the Infrared Sensor
     * @return data from the infrared sensor
     */
    public int[] getIR(){
        return IR_Data;
    }
    /** Retrieves the data from the Ultrasonic Sensor
     * @return data from the ultrasonic sensor
     */
    public int[] getUS(){
        return US_Data;
    }
    /** Retrieves the data from the GPS
     * @return data from the GPS
     */
    public int[] getGPS(){
        return GPS_Data;
    }
    /** Retrieves the data from the Compass
     * @return data from the Compass
     */
    public int[] getCompass(){
        return Compass_Data;
    }
    /** Shuts down the robot properly
     */
    public void shutdown(){
        //helper.stop();
        try{
            output.close();
            input.close();
        } catch(IOException e){}
        System.exit(0);
    }
    
    //Second Thread to monitor input
    private class AtlasHelper implements Runnable{
        private InputStream in;
        private boolean stop;
        private int[] IR_Data, US_Data, GPS_Data, Compass_Data;
        private Thread t;
        public AtlasHelper(InputStream stream, int[] IR, int[] US, int[] GPS, int[] Compass){
            String tName = "helper";
            in = stream;
            stop = false;
            
            IR_Data = IR;
            US_Data = US;
            GPS_Data = GPS;
            Compass_Data = Compass;
            
            t = new Thread(this, tName);
            t.start();
        }
        /**
         *Stops the thread
         */
        public void stop(){
            stop = true;
            try{
                t.join();
                t.interrupt();
                
            } catch (InterruptedException e){
                
            }
        }
        public void run(){
            /*int[] buffer = new int[
                    + Atlas.IR_BYTE_SIZE
                    + Atlas.US_BYTE_SIZE
                    + Atlas.GPS_BYTE_SIZE
                    + Atlas.Compass_BYTE_SIZE];
                    */
            int[] buffer = new int[9];
            int bytesRead = -1;
            int ir, gps, us, compass;
            int bound1, bound2, bound3, bound4;
            int i,c,j;
	    j = 0;
            System.out.println("Running Loops ...");
            while (!stop){
                ir = -1;
                gps = -1;
                us = -1;
                compass = -1;
                //System.out.println("Trying to Read ...");
                try{
                    //for (int x = 0; x < buffer.length; x++){
                        //buffer[x] = in.read();
                        //System.out.print(buffer[x]);
			int x = in.read();
                        System.out.println(x);
                    //}
                    //System.out.println(in.read());
                } catch(IOException e){
                    //System.err.println("Couldn't Read from Buffer");
                }
                //if (bytesRead == -1) continue;
                //System.out.println(buffer);
                //for (int t = 0; t < buffer.length; t++) System.out.print(buffer[t] + " ");
                //Search for the Next Sequence and skip it.
                /*if (buffer[0] != Atlas.START_BYTE){
                    System.err.println("Recieved Bogus Packet" + buffer[0]);
                    int b = 0;
                    while(b != Atlas.START_BYTE){
                        try {
                            b = in.read();
                        } catch(IOException e) {
                            break;
                        }
                    }
                    try {
                        in.skip(Atlas.IR_BYTE_SIZE
                                + Atlas.US_BYTE_SIZE
                                + Atlas.GPS_BYTE_SIZE
                                + Atlas.Compass_BYTE_SIZE);
                    } catch(IOException e){
                        
                    }
                }
                //Copies the bytes into accessible arrays
                c = 0;
                bound1 = Atlas.IR_BYTE_SIZE;
                bound2 = bound1 + Atlas.US_BYTE_SIZE;
                bound3 = bound2 + Atlas.GPS_BYTE_SIZE;
                bound4 = bound3 + Atlas.Compass_BYTE_SIZE;
                
                for (i = 1; i <= bound1; i++, c++)
                    IR_Data[c] = buffer[i];
                for (c = 0; i <= bound2; i++, c++)
                    US_Data[c] = buffer[i];
                for (c = 0; i <= bound3; i++,c++)
                    GPS_Data[c] = buffer[i];
                for (c = 0; i <= bound4; i++,c++)
                    Compass_Data[0] = buffer[i];
                */
                this.clearBuffer(buffer);
            }
        }
        /**
         *Clears the buffer array
         *@param    buffer  The buffer to clear
         */
        private void clearBuffer(int[] buffer){
            for (int i = 0; i < buffer.length; i++){
                buffer[i] = 0;
            }
        }
    }
}

