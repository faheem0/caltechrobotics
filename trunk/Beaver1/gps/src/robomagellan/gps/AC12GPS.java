/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.gps;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import robomagellan.helpers.SerialPortFactory;

/**
 * A class to communicate with the GPS
 * @author robomagellan
 */
public class AC12GPS {

	/**
	 * Baud rate of the GPS
	 */
	public static final int BAUD_RATE = 4800;
	/**
	 * Number of data bits for the GPS serial port
	 */
	public static final int DATA_BITS = SerialPort.DATABITS_8;
	/**
	 * Number of parity bits for the GPS serial port
	 */
	public static final int PARITY = SerialPort.PARITY_NONE;
	/**
	 * Number of stop bits for the GPS serial port
	 */
	public static final int STOP_BITS = SerialPort.STOPBITS_1;
	/**
	 * Regular expession to detect UTM coordinates. Used for parsing.
	 */
	private static final Pattern utm = Pattern.compile("^\\$PASHR,UTM");
	/**
	 * Multiplier to calculate the precision of the received data
	 */
	private static final double PRECISION_MULT = 3.0;
	/**
	 * Buffer size to read into for parsing
	 */
	private static final int BUFFER_SIZE = 64;
	private SerialPort port;
	private boolean hasListener;
	private GPSDataListener listener;
	private InputStream in;

	/**
	 * Connects to the GPS and sends the start commands to start acquiring satellites.
	 * @param portName the port to connect to (ie. "COM1" or "/dev/ttyUSB0")
	 */
	public AC12GPS(String portName) {
		hasListener = false;
		port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
		try {
			in = port.getInputStream();
			OutputStream out = port.getOutputStream();
			String cmd;
			cmd = "$PASHS,PWR,ON\r\n";
			cmd = cmd + "$PASHQ,PRT\r\n";
			cmd = cmd + "$PASHQ,RID\r\n";
			cmd = cmd + "$PASHS,OUT,A,NMEA\r\n";
			cmd = cmd + "$PASHS,NME,UTM,A,ON\r\n";
			out.write(cmd.getBytes("ASCII"));
		} catch (IOException ex) {
			Logger.getLogger(AC12GPS.class.getName()).log(Level.SEVERE, "COuld not get OutputStream or InputStream or could not write to OutputStream", ex);
		}

	}

	/**
	 * Starts reading and parsing data from the serial port. The data is passed to the GPSDataListener for processing.
	 * @param g the processEvent method of this object is called to process the GPS coordinates.
	 * @throws java.util.TooManyListenersException
	 */
	public synchronized void addGPSDataListener(GPSDataListener g) throws TooManyListenersException {
		if (hasListener) {
			throw new TooManyListenersException("There's already a listener on " + port.getName());
		}
		listener = g;
		port.notifyOnDataAvailable(true);
		port.addEventListener(new SerialPortEventListener() {

			String str = "";
			byte[] buffer = new byte[BUFFER_SIZE];
			int bytesRead;
			String[] strs;
			String[] params;
			Matcher m;

			public void serialEvent(SerialPortEvent arg0) {
				if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
					try {
						bytesRead = in.read(buffer);
						str = str.concat(new String(buffer, 0, bytesRead, "ASCII"));
						//str = new String(buffer, 0, bytesRead, "ASCII");
						strs = str.split("\r\n");
						str = strs[strs.length - 1];
						for (int i = 0; i < strs.length - 1; i++) {
							m = utm.matcher(strs[i]);
							if (m.find()) {
								GPSPacket packet = getPacket(strs[i]);
								listener.processEvent(packet);
							}

						}
						System.out.print(str);

					//listener.processEvent(null);
					} catch (IOException ex) {
						Logger.getLogger(AC12GPS.class.getName()).log(Level.SEVERE, "Could not read from InputStream", ex);
					}
				}
			}
		});

		hasListener = true;
	}

	/**
	 * Stops reading from the GPS and shuts down the port. This object cannot reconnect to the port after so
	 * another instance of this class needs to be instantiated.
	 */
	public void stop() {
		port.close();
	}

	/**
	 * Changes the timestamp from the GPS to a number in seconds
	 * @param timestamp the timestamp number from the GPS
	 * @return a timestamp number in seconds
	 */
	public static double processTime(double timestamp) {
		double time;
		timestamp /= 10000;
		time = Math.floor(timestamp) * 3600;
		timestamp = 100 * timestamp - 100 * Math.floor(timestamp);
		time += Math.floor(timestamp) * 60;
		timestamp = 100 * timestamp - 100 * Math.floor(timestamp);
		time += timestamp;
		return time;
	}

	/**
	 * Used to create a GPSPacket from the NMEA UTM string from the GPS
	 * @param str the string from the GPS
	 * @return a new GPSPacket
	 * @see GPSPacket
	 */
	public static GPSPacket getPacket(String str) {
		GPSPacket packet = new GPSPacket();
		String[] params = str.split(",");
		if (!params[4].equals("")) {
			packet.utmEast = Double.parseDouble(params[4]);
		}
		if (!params[5].equals("")) {
			packet.utmNorth = Double.parseDouble(params[5]);
		}
		if (!params[8].equals("")) {
			packet.precision = Double.parseDouble(params[8]) * PRECISION_MULT;
		}
		double timestamp = 0;
		if (!params[2].equals("")) {
			timestamp = Double.parseDouble(params[2]);
		}
		packet.time = processTime(timestamp);
		return packet;
	}
}
