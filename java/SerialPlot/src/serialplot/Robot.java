/*
 * Robot.java
 *
 * Created on October 29, 2007, 11:33 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package serialplot;

import java.io.*;
import gnu.io.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @version 0.3
 * @author tonyfwu
 */
public class Robot {

	/**
	 *Control sequence byte to notify the robot that its about to send a command
	 */
	public static final int START_BYTE = 0xfe;
	private Enumeration portList;
	private CommPortIdentifier commID;
	private int BAUD_RATE = 4800;
	private int PARITY = SerialPort.PARITY_NONE;
	private int DATA_BITS = SerialPort.DATABITS_8;
	private int STOP_BITS = SerialPort.STOPBITS_1;
	/**
	 *Serial Port
	 */
	protected SerialPort port;
	/** Output Stream to send the robot commands
	 */
	protected OutputStream output;
	/** Input Stream to recieve data
	 */
	protected InputStream input;

	/**
	 * Creates a new instance of Robot and connects to the Robot.
	 * This initiates the serial port and prepares the robot to transmit and recieve data.
	 * @param portName the name of the serial port to connect to. (i.e. "/dev/ttyUSB0")
	 */
	public Robot(String portName) {
		connect(portName);
	}

	public Robot(String portName, int baud, int data, int stop, int parity) {
		BAUD_RATE = baud;
		DATA_BITS = data;
		STOP_BITS = stop;
		PARITY = parity;
		connect(portName);
	}

	public InputStream getInputStream() {
		return input;
	}

	/**
	 *Disconnects the robot
	 */
	public void shutdown() {
		try {
			output.close();
			input.close();
		} catch (IOException e) {
		}
		port.close();
		System.exit(0);
	}

	private void connect(String portName) {
		boolean foundPort = false;
		//recieveListener = new SerialPortRecieveListener();
		portList = CommPortIdentifier.getPortIdentifiers();
		while (portList.hasMoreElements()) {
			if (((CommPortIdentifier) portList.nextElement()).getName().equals(portName)) {
				System.out.println("Found port " + portName);
				foundPort = true;
				break;
			}
		}
		if (!foundPort) {
			System.out.println("Couldn't find port " + portName);
			System.exit(1);
		}
		System.out.println("Attempting to Connect to " + portName);
		try {
			commID = CommPortIdentifier.getPortIdentifier(portName);
			port = (SerialPort) commID.open(portName, 2000);
			port.setSerialPortParams(BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
			System.out.println("Baud Rate is: " + port.getBaudRate());
			System.out.println("Data Bits is: " + port.getDataBits());
			System.out.println("Stop Bits is: " + port.getStopBits());
			System.out.println("Parity Bits is: " + port.getParity());
		} catch (UnsupportedCommOperationException ex) {
			Logger.getLogger(Robot.class.getName()).log(Level.SEVERE, null, ex);
		} catch (gnu.io.NoSuchPortException e1) {
			System.exit(2);
		} catch (gnu.io.PortInUseException e2) {
			System.err.println("Port Already in Use!");
			System.exit(3);
		}
		System.out.println("Connected!");
		try {
			output = port.getOutputStream();
			input = port.getInputStream();
		} catch (IOException e) {
			System.err.println("Caught IO Exception");
			System.exit(4);
		}
	}

	public void setHandler(SerialPortEventListener arg0) {
		try {
			port.addEventListener(arg0);
			port.notifyOnDataAvailable(true);
		} catch (TooManyListenersException ex) {
			Logger.getLogger(Robot.class.getName()).log(Level.SEVERE, null, ex);
		}
	}
}
