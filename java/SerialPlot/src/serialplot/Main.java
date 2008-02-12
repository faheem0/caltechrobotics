/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package serialplot;
import javax.swing.*;
import java.awt.Dimension;
import java.awt.Color;
import java.io.*;
import gnu.io.*;
import java.util.*;
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

    public static void main(String[] args) {
	

	    JFrame f = new JFrame("SEGWAY!!!");
	    Plot p = new Plot(PLOT_WIDTH, PLOT_HEIGHT);
	    p.setScale(1, 3);
	    f.setPreferredSize(new Dimension(PLOT_WIDTH + 10,PLOT_HEIGHT + 50));
	    ImagePanel panel = new ImagePanel(p);
	    f.add(panel);
	    panel.setVisible(true);
	    f.setVisible(true);
	    p.drawAxes(PLOT_HEIGHT/2, 0);
	    f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    f.pack();

	    //Plot a function
	    //y = x^2;
	    /*
	    Color c = new Color(0,255,0);
	    for (int x = -10; x <= 10; x++){
		p.plotPoint(5*x, x*x, c);
	    }*/

	    //Connect to Robot
	    Color c = new Color(0,255,0);
	    Robot r = new Robot("COM5");
	    InputStream in = r.getInputStream();
	    int byte_read;
	    int time = 0;
	    int radar_time = 1;
	    while(true){
		try{
			byte_read = in.read();
			if (byte_read == -1) continue;
			System.out.println(time + "\t" + byte_read);
			byte_read -= 128;
			if(byte_read < 0 ) byte_read = -1*(128+byte_read);
			p.drawVerticalLine(radar_time, Color.CYAN);
			p.drawVerticalLine(time, Color.BLACK);
			p.plotPoint(time, byte_read, c);
			time = (time+1) % PLOT_WIDTH;
			radar_time = (radar_time+1) % PLOT_WIDTH;
			panel.repaint();
		} catch (IOException e){
			e.printStackTrace();
		}

	    }

    }

}
