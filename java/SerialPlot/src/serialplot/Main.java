/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package serialplot;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import info.monitorenter.gui.chart.Chart2D;
import info.monitorenter.gui.chart.ITrace2D;
import info.monitorenter.gui.chart.traces.Trace2DReplacing;
import info.monitorenter.gui.chart.traces.Trace2DSimple;
import javax.swing.*;
import java.awt.Color;
import java.io.*;
import java.util.Scanner;

/**
 *
 * @author tonyfwu
 */
public class Main {

	/**
	 * @param args the command line arguments
	 */
	public static final int PLOT_WIDTH = 600;
	public static final int PLOT_HEIGHT = 600;
	public static final int NEXT_TIME_BYTE = 254; //defined in protocol w/MCU
	public static final Color[] pointColor = {Color.RED, Color.GREEN, Color.BLUE, Color.MAGENTA, Color.ORANGE};

	public static void main(String[] args) {


		JFrame f = new JFrame("SEGWAY!!!");
		f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		Chart2D chart = new Chart2D();
		final ITrace2D[] trace = new Trace2DSimple[pointColor.length];
		for (int i = 0; i < pointColor.length; i++) {
			trace[i] = new Trace2DReplacing();
			trace[i].setColor(pointColor[i]);
			chart.addTrace(trace[i]);
		}
		f.getContentPane().add(chart);
		f.setSize(400, 300);
		//Plot a function
		//y = x^2;

		/*
		Color c = new Color(0,255,0);
		for (int x = -10; x <= 10; x++){
		trace[0].addPoint(5*x, x*x);
		//		p.plotPoint(5*x, x*x);
		}
		f.setVisible(true);
		while(true); */

		//Connect to Robot
		Robot r;
		Scanner s = new Scanner(System.in);
		int baud, stop, parity, data;
		String port;
		System.out.print("Port: ");
		port = s.nextLine();
		port.trim();
		System.out.print("Baud: ");
		baud = s.nextInt();
		System.out.print("Data Bits: ");
		switch (s.nextInt()) {
			case 5:
				data = SerialPort.DATABITS_5;
				break;
			case 6:
				data = SerialPort.DATABITS_6;
				break;
			case 7:
				data = SerialPort.DATABITS_7;
				break;
			case 8:
			default:
				data = SerialPort.DATABITS_8;
				break;
		}
		System.out.print("Stop Bits: ");
		float t = s.nextFloat();
		if (t == 1.5f) {
			stop = SerialPort.STOPBITS_1_5;
		} else if (t == 2f) {
			stop = SerialPort.STOPBITS_2;
		} else {
			stop = SerialPort.STOPBITS_1;
		}
		parity = SerialPort.PARITY_NONE;
		r = new Robot(port, baud, data, stop, parity);
		final InputStream in = r.getInputStream();

		r.setHandler(new SerialPortEventListener() {

			int time = 0;
			int colorIndex = 0;

			public void serialEvent(SerialPortEvent arg0) {
				if (arg0.equals(SerialPortEvent.DATA_AVAILABLE)) {
					try {
						int byte_read = in.read();

						if (byte_read == -1) {
							return;
						}
						if (byte_read == NEXT_TIME_BYTE) {
							time = (time + 1) % PLOT_WIDTH;
							colorIndex = 0;  //reset color index
						} else {
							byte_read = convertTwosComplement(byte_read);
							System.out.println("Time: " + time + "\t" + "Byte read: " + byte_read);
							trace[colorIndex].addPoint(time, byte_read);
							if ((colorIndex + 1) < pointColor.length) {
								colorIndex++;
							}
						}
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		});
		f.setVisible(true);
	}

	/**
	 * Basically, this function takes a number and converts it into
	 * 8-bit two's complement.  The number it takes has unknown format,
	 * it could be unsigned or 16-bit signed.  It just works.
	 */
	public static int convertTwosComplement(int num) {
		if (num > 127) {
			return -1 * (256 - num);
		}
		return num;
	}
}
