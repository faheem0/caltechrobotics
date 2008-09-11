/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package testing;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import info.monitorenter.gui.chart.Chart2D;
import info.monitorenter.gui.chart.ITrace2D;
import info.monitorenter.gui.chart.rangepolicies.RangePolicyFixedViewport;
import info.monitorenter.gui.chart.traces.Trace2DReplacing;
import info.monitorenter.gui.chart.traces.Trace2DSimple;
import info.monitorenter.util.Range;
import javax.swing.*;
import java.awt.Color;
import java.io.*;
import java.util.Scanner;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import serialplot.Robot;
/**
 *
 * @author tonyfwu
 */
public class Arm7{

    /**
     * @param args the command line arguments
     */
    public static final int PLOT_WIDTH = 600;
    public static final int PLOT_HEIGHT = 600;
    public static final int NEXT_TIME_BYTE = 254; //defined in protocol w/MCU
    public static final Color[] pointColor = {Color.RED, Color.GREEN, Color.BLUE, Color.MAGENTA, Color.ORANGE, Color.CYAN, Color.BLACK, Color.GRAY, Color.PINK, Color.YELLOW, Color.LIGHT_GRAY};
    public static String str = "";
    public static int rowCounter = 0;
    public static HSSFWorkbook wb;
    public static HSSFRow row;
    public static HSSFSheet sheet;   
    public static String spreadsheetFileName;

    public static void main(String[] args) {
        wb = new HSSFWorkbook();
        sheet = wb.createSheet();
        spreadsheetFileName = "SerialPlotLog_" + (new SimpleDateFormat("yyyy.MM.dd.hh.mm.ss")).format( Calendar.getInstance().getTime()) + ".xls";
        //while(1 == 1);
        /*row     = sheet.createRow((short)0); 
        HSSFCell cell   = row.createCell((short)0); 
        cell.setCellValue(1); 
        row.createCell((short)1).setCellValue(1.2); 
        row.createCell((short)2).setCellValue("This is a string");
        row.createCell((short)3).setCellValue(true);
        rowCounter = 3;
        row = sheet.createRow((short) rowCounter);
        row.createCell((short) (row.getLastCellNum()+1)).setCellValue(3.14);
        row.createCell((short) (row.getLastCellNum()+1)).setCellValue(3.15);

        try {
            FileOutputStream fileOut = new FileOutputStream("workbook.xls");
            try {
                wb.write(fileOut);
                fileOut.close();
            } catch (IOException e) {}

        } catch (FileNotFoundException f) {}

        row.createCell((short) (row.getLastCellNum()+1)).setCellValue(3.16);
        try {
            FileOutputStream fileOut = new FileOutputStream("workbook.xls");
            try {
                wb.write(fileOut);
                fileOut.close();
            } catch (IOException e) {}

        } catch (FileNotFoundException f) {}*/

        /////////////////////////////////////////////////////////
        JFrame f = new JFrame("SerialPlot™");
        f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        Chart2D chart = new Chart2D();
        final ITrace2D[] trace = new Trace2DSimple[pointColor.length];
        for (int i = 0; i < pointColor.length; i++) {
                trace[i] = new Trace2DReplacing();
                trace[i].setColor(pointColor[i]);
                chart.addTrace(trace[i]);
        }
        chart.getAxisX().setRangePolicy(new RangePolicyFixedViewport(new Range(0, PLOT_WIDTH)));
        f.getContentPane().add(chart);
        f.setSize(400, 300);
        //trace[0].addPoint(PLOT_WIDTH-1, 0);
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
        /*Scanner s = new Scanner(System.in);
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
        r = new Robot(port, baud, data, stop, parity);*/
        r = new Robot("COM14", 115200, SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE); //quick n dirty!
        final InputStream in = r.getInputStream();

        r.setHandler(new SerialPortEventListener() {

            int time = 0;
            int colorIndex = 0;

            public void serialEvent(SerialPortEvent arg0) {

                if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
                    try {
                        //begin arm7 project specific stuff
                        int byte_read = in.read();
                        char c = ((char) byte_read);

                        if (byte_read == -1) {
                                return;
                        }                                                

                        if(c == '\n') { //next line indicates next time frame
                            time = (time + 1) % PLOT_WIDTH;
                            colorIndex = 0;  //reset color index
                            System.out.print('\n');
                            rowCounter ++;  //next row in spreadsheet
                            row = sheet.createRow((short) rowCounter);
                            try {    //now actually write to spreadsheet
                                FileOutputStream fileOut = new FileOutputStream(spreadsheetFileName);
                                try {
                                    wb.write(fileOut);
                                    fileOut.close();
                                } catch (IOException e) {}

                            } catch (FileNotFoundException f) {}
                        }
                        if(Character.isDigit(c) || c == '.' || c == '-') //filter out letters
                            str+=c;
                        else if(!str.equals("")) {  //str now contains a decimal number
                            double numToGraph = Double.parseDouble(str);
                            System.out.print("|"+numToGraph);
                            trace[colorIndex].addPoint(time, (int) numToGraph);
                            if ((colorIndex + 1) < pointColor.length) 
                                colorIndex++;
                            str=""; //reset string                                                    
                            row.createCell((short) (row.getLastCellNum()+1)).setCellValue(numToGraph);
                        }
                        else
                            str="";
                        //end arm7 project specific stuff

                        /*//begin RM project specific stuff
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
                        //end RM project specific stuff 
                         */
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
