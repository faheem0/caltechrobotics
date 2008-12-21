/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.motors;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.helpers.SerialPortFactory;

/**
 * A class to communicate with the Robomagellan motors.
 * @author robomagellan
 */
public class Motors {

	/**
	 * Indicator for left motor.
	 */
    public static final int LEFT = 1;
	/**
	 * Indicator for right motor.
	 */
    public static final int RIGHT = 2;
    public static final byte START_BYTE = 60;
    /**
     * Baud rate of serial port
     */
    public static final int BAUD_RATE = 115200;
    /**
     * Parity bits of serial port
     */
    public static final int PARITY = SerialPort.PARITY_NONE;
    /**
     * Data bits of serial port
     */
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    /**
     * Stop bits of serial port
     */
    public static final int STOP_BITS = SerialPort.STOPBITS_1;
    /**
     * Time in milliseconds to wait everytime speed information is sent to motors
     */
    public static final int PACKET_RATE = 100;
    
    /**
     * Amount of usefull data in each packet
     */
    public static final int NUM_ENCODER_DATA = 4;
    /*public static final int ENC_LEFT_POS = 0;
    public static final int ENC_RIGHT_POS = 1;
    public static final int ENC_LEFT_VEL = 2;
    public static final int ENC_RIGHT_VEL = 3;*/

    /**
     * Number of motors
     */
    public static final int NUM_MOTORS = 2;
    /**
     * Bytes per segment of the packet
     */
    public static final int BYTES_PER_SEGMENT = 6;
    /**
     * Max number of bytes that is read each time an interrupt occurs
     */
    public static final int BUFFER_SIZE = 128;
    /**
     * ASCII zero for parsing
     */
    public static final int ASCII_ZERO = 48;

    private SerialPort port;
    private volatile ArrayList<String> commands;
    private Thread helperThread;
    private volatile boolean stopHelper;
    private InputStream in;
    private boolean hasListener;
    private EncoderDataListener listener;
    private OutputStream out;
    private volatile String cmd;
    
    /**
     * Starts a connection to the motors given the selected serial port. Does not open for reading yet, but can be written to.
     * @param portName serial port (ie. "COM1" or "/dev/ttyUSB0")
     */
    public Motors(String portName){
        cmd = "<0000";
        hasListener = false;
        commands = new ArrayList<String>();
        commands.add(START_BYTE + "");
        for (int i = 0; i < NUM_MOTORS; i++)
            commands.add("00");
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        stopHelper = false;
        try {
            out = port.getOutputStream();
        } catch (IOException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not get OutputStream", ex);
        }
        Runnable helper = new Runnable(){
            public void run() {
                while(!stopHelper){
                    try {
                        out.write(cmd.getBytes("ASCII"));
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not write to OutputStream", ex);
                    }
                    try {
                        Thread.sleep(PACKET_RATE);
                    } catch (InterruptedException ex) {
                        //Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }
        };
        helperThread = new Thread(helper);
        helperThread.start();
        try {
            in = port.getInputStream();
        } catch (IOException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not get InputStream", ex);
        }
    }
    
    /**
     * Starts reading from serial port and feeds encoder data to the specified EncoderDataListener
     * @param d the object the encoder data will be fed to. 
     * @throws java.util.TooManyListenersException
     */
    public synchronized void addEncoderDataListener(EncoderDataListener d) throws TooManyListenersException{
        if(hasListener) throw new TooManyListenersException("There's already a listener on " + port.getName());
        listener = d;
        port.notifyOnDataAvailable(true);
        port.addEventListener(new SerialPortEventListener(){
            int[] data = new int[NUM_ENCODER_DATA];
            byte[] readBuffer = new byte[BUFFER_SIZE];
            int bytesRead;
            int state = 0;
            int byteCnt = 0;
	    int sign = 1;
            EncoderPacket packet = new EncoderPacket();

            public void serialEvent(SerialPortEvent arg0) {
                if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE){
                    try {
                        bytesRead = in.read(readBuffer);
			for (int i = 0; i < bytesRead; i++){
				switch (state) {
					case 0:
						if (readBuffer[i] == START_BYTE) {
							packet = new EncoderPacket();
							state = 1;
							byteCnt = 0;
							data[0] = 0;
							data[1] = 0;
							data[2] = 0;
							data[3] = 0;
						}
						break;
					case 1:
						if ((char) readBuffer[i] == '-') {
							sign = -1;
						}
						if (byteCnt != 0) {
							data[0] += (int) Math.pow(10, BYTES_PER_SEGMENT - byteCnt - 1) * (readBuffer[i] - ASCII_ZERO);
						}
						byteCnt++;
						if (byteCnt >= BYTES_PER_SEGMENT) {
							state = 2;
							data[0] *= sign;
							sign = 1;
							byteCnt = 0;
						}
						break;
					case 2:
						if ((char) readBuffer[i] == '-') {
							sign = -1;
						}
						if (byteCnt != 0) {
							data[1] += (int) Math.pow(10, BYTES_PER_SEGMENT - byteCnt - 1) * (readBuffer[i] - ASCII_ZERO);
						}
						byteCnt++;
						if (byteCnt >= BYTES_PER_SEGMENT) {
							state = 3;
							data[1] *= sign;
							sign = 1;
							byteCnt = 0;
						}
						break;
					case 3:
						if ((char) readBuffer[i] == '-') {
							sign = -1;
						}
						if (byteCnt != 0) {
							data[2] += (int) Math.pow(10, BYTES_PER_SEGMENT - byteCnt - 1) * (readBuffer[i] - ASCII_ZERO);
						}
						byteCnt++;
						if (byteCnt >= BYTES_PER_SEGMENT) {
							state = 4;
							data[2] *= sign;
							sign = 1;
							byteCnt = 0;
						}
						break;
					case 4:
						if ((char) readBuffer[i] == '-') {
							sign = -1;
						}
						if (byteCnt != 0) {
							data[3] += (int) Math.pow(10, BYTES_PER_SEGMENT - byteCnt - 1) * (readBuffer[i] - ASCII_ZERO);
						}
						byteCnt++;
						if (byteCnt >= BYTES_PER_SEGMENT) {
							state = 0;
							data[3] *= sign;
							sign = 1;
							byteCnt = 0;
							packet.velLeft = data[2];
							packet.velRight = data[3];
							listener.processEvent(packet);
						}
						break;
					default:
						break;
				}
			}
                        //listener.processEvent(null);
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not read from InputStream", ex);
                    }
                }
            }
        });

        hasListener = true;
    }
    /**
     * Sets the speed of a given motor
     * @param motor Motor number, Motors.LEFT or Motors.RIGHT
     * @param speed A speed ranging from 0 to 10, 0 being stop.
     */
    public synchronized void setSpeed(int motor, int speed){
        if (speed > 10) speed = 10;
        if (speed < 0) speed = 0;
        if (speed == 10) commands.set(motor, speed + "");
        else commands.set(motor, "0" + speed);
        String newCmd = "";
        for (int i = 0; i < commands.size(); i++)
            newCmd = newCmd.concat(commands.get(i));
        this.cmd = newCmd;
    }
    /**
     * Shutsdown the serial port connection to the motors.
     * It cannot be opened up again in the same object.
     * A new instance of this class must be created.
     */
    public synchronized void stop(){
        stopHelper = true;
        try {
            if (helperThread != null)
                helperThread.join();
        } catch (InterruptedException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
        }
        port.close();
    }
}
