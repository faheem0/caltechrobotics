/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package serialplot;

import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.awt.Color;
/**
 *
 * @author tonyfwu
 */
public class Plot extends BufferedImage{
	
	private int X_SCALE, Y_SCALE;
	private int WIDTH, HEIGHT;
	private int X_AXIS, Y_AXIS;
	private static int AXIS_WIDTH = 1;
	public Plot(int x, int y){
		super(x+AXIS_WIDTH, y+AXIS_WIDTH, BufferedImage.TYPE_3BYTE_BGR);
		setScale(1,1); 
		WIDTH = x;
		HEIGHT = y;
	}
	public void setScale(int xScale, int yScale){
		X_SCALE = xScale;
		Y_SCALE = yScale;
	}
	public void drawAxes(int xPos, int yPos){
		X_AXIS = xPos;
		Y_AXIS = yPos;
		Color c = new Color(255, 255, 255);
		for(int i = 0; i < WIDTH; i++)
			super.setRGB(i, xPos, c.getRGB());
		for(int i = 0; i < HEIGHT; i++)
			super.setRGB(yPos, i, c.getRGB());
	}
	public void drawVerticalLine(int xPos, Color c){
		int x = xPos * X_SCALE + Y_AXIS;
		for(int i = 0;i < HEIGHT; i++){
			if (i != X_AXIS)
				super.setRGB(x, i, c.getRGB());
			else super.setRGB(x, i, Color.WHITE.getRGB());
		}
	}
	public void plotPoint(int x, int y, Color c){
		int xValue = x*X_SCALE + Y_AXIS;
		int yValue = HEIGHT - (y*Y_SCALE + X_AXIS);
		if (xValue < WIDTH && yValue < HEIGHT && xValue >= 0 && yValue >= 0)
			super.setRGB(xValue, yValue, c.getRGB());
	}
}
