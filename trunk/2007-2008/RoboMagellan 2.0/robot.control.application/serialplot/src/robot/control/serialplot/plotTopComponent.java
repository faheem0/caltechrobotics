/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robot.control.serialplot;

import gnu.io.CommPortIdentifier;
import gnu.io.NoSuchPortException;
import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import gnu.io.UnsupportedCommOperationException;
import java.awt.Color;
import java.io.IOException;
import java.io.Serializable;
import java.util.Enumeration;
import java.util.TooManyListenersException;
import java.util.logging.Logger;
import javax.swing.DefaultComboBoxModel;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.data.xy.DefaultXYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.RectangleInsets;
import org.openide.util.Exceptions;
import org.openide.util.NbBundle;
import org.openide.windows.TopComponent;
import org.openide.windows.WindowManager;
import org.openide.util.Utilities;

/**
 * Top component which displays something.
 */
final class plotTopComponent extends TopComponent {

    private static plotTopComponent instance;
    /** path to the icon used by the component and its open action */
    static final String ICON_PATH = "robot/control/serialplot/vspk-icon-48.gif";

    private static final String PREFERRED_ID = "plotTopComponent";

    private plotTopComponent() {
	setupChart();
        initComponents();
        setName(NbBundle.getMessage(plotTopComponent.class, "CTL_plotTopComponent"));
        setToolTipText(NbBundle.getMessage(plotTopComponent.class, "HINT_plotTopComponent"));
        setIcon(Utilities.loadImage(ICON_PATH, true));
	setupSerialOptions();
//	setupChart();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
        // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
        private void initComponents() {

                jPanel1 = new javax.swing.JPanel();
                jLabel1 = new javax.swing.JLabel();
                jLabel2 = new javax.swing.JLabel();
                jLabel3 = new javax.swing.JLabel();
                jLabel4 = new javax.swing.JLabel();
                connect = new javax.swing.JToggleButton();
                port = new javax.swing.JComboBox();
                baud = new javax.swing.JComboBox();
                parity = new javax.swing.JComboBox();
                stopbits = new javax.swing.JComboBox();
                jLabel5 = new javax.swing.JLabel();
                databits = new javax.swing.JComboBox();
                chartPanel = new javax.swing.JPanel();
                chartPanel = new ChartPanel(chart);

                org.openide.awt.Mnemonics.setLocalizedText(jLabel1, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.jLabel1.text")); // NOI18N

                org.openide.awt.Mnemonics.setLocalizedText(jLabel2, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.jLabel2.text")); // NOI18N

                org.openide.awt.Mnemonics.setLocalizedText(jLabel3, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.jLabel3.text")); // NOI18N

                org.openide.awt.Mnemonics.setLocalizedText(jLabel4, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.jLabel4.text")); // NOI18N

                org.openide.awt.Mnemonics.setLocalizedText(connect, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.connect.text")); // NOI18N
                connect.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                plotConnectHandler(evt);
                        }
                });

                port.setModel(ports);

                baud.setModel(bauds);

                parity.setModel(parities);

                stopbits.setModel(stopBits);

                org.openide.awt.Mnemonics.setLocalizedText(jLabel5, org.openide.util.NbBundle.getMessage(plotTopComponent.class, "plotTopComponent.jLabel5.text")); // NOI18N

                databits.setModel(dataBits);

                javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
                jPanel1.setLayout(jPanel1Layout);
                jPanel1Layout.setHorizontalGroup(
                        jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(jPanel1Layout.createSequentialGroup()
                                .addContainerGap()
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                        .addGroup(jPanel1Layout.createSequentialGroup()
                                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                                        .addComponent(jLabel1)
                                                        .addComponent(jLabel2))
                                                .addGap(8, 8, 8)
                                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                                        .addComponent(baud, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(port, 0, 95, Short.MAX_VALUE))
                                                .addGap(35, 35, 35)
                                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                                        .addGroup(jPanel1Layout.createSequentialGroup()
                                                                .addComponent(jLabel3)
                                                                .addGap(18, 18, 18)
                                                                .addComponent(parity, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                                                        .addGroup(jPanel1Layout.createSequentialGroup()
                                                                .addComponent(jLabel4)
                                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                                .addComponent(stopbits, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                                .addGap(18, 18, 18)
                                                .addComponent(jLabel5)
                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                .addComponent(databits, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE))
                                        .addComponent(connect))
                                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                );
                jPanel1Layout.setVerticalGroup(
                        jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(jPanel1Layout.createSequentialGroup()
                                .addContainerGap()
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(jLabel1)
                                        .addComponent(jLabel4)
                                        .addComponent(port, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(stopbits, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(jLabel5)
                                        .addComponent(databits, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(jLabel2)
                                        .addComponent(jLabel3)
                                        .addComponent(baud, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(parity, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 7, Short.MAX_VALUE)
                                .addComponent(connect)
                                .addContainerGap())
                );

                javax.swing.GroupLayout chartPanelLayout = new javax.swing.GroupLayout(chartPanel);
                chartPanel.setLayout(chartPanelLayout);
                chartPanelLayout.setHorizontalGroup(
                        chartPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGap(0, 473, Short.MAX_VALUE)
                );
                chartPanelLayout.setVerticalGroup(
                        chartPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGap(0, 174, Short.MAX_VALUE)
                );

                javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
                this.setLayout(layout);
                layout.setHorizontalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                                .addContainerGap()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                                        .addComponent(chartPanel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(jPanel1, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                                .addContainerGap())
                );
                layout.setVerticalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                                .addContainerGap()
                                .addComponent(chartPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
                );
        }// </editor-fold>//GEN-END:initComponents

private void plotConnectHandler(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_plotConnectHandler
	if(connect.isSelected()){
			try {
				CommPortIdentifier id = CommPortIdentifier.getPortIdentifier((String) ports.getSelectedItem());
				serial = (SerialPort) id.open("SerialPort Plot" + id.getName(), 2048);
				
				int baud = ((SerialPortProperty) bauds.getSelectedItem()).Value;
				int stop = ((SerialPortProperty) stopBits.getSelectedItem()).Value;
				int data = ((SerialPortProperty) dataBits.getSelectedItem()).Value;
				int parity = ((SerialPortProperty) parities.getSelectedItem()).Value;
				
				serial.setSerialPortParams(baud, data, stop, parity);
				serial.addEventListener(new SerialPortEventListener(){
					private int index = 0;
					public void serialEvent(SerialPortEvent arg0) {
						if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE){
							try {
								series.add(index, serial.getInputStream().read());
								index++;
								index %= MAX_POINTS;
							} catch (IOException ex) {
								Exceptions.printStackTrace(ex);
							}
						}
					}
				});
				serial.notifyOnDataAvailable(true);
			} catch (NoSuchPortException ex) {
				System.err.println("Can't find port " + ports.getSelectedItem());
			} catch (PortInUseException ex){
				System.err.println("Port in use: " + ports.getSelectedItem());
			} catch (TooManyListenersException ex){
				ex.printStackTrace();
			} catch (UnsupportedCommOperationException ex){
				ex.printStackTrace();
			} 
		
	} else if (!connect.isSelected()){
		if(serial != null){
			serial.close();
		}
	}
}//GEN-LAST:event_plotConnectHandler


        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JComboBox baud;
        private javax.swing.JPanel chartPanel;
        private javax.swing.JToggleButton connect;
        private javax.swing.JComboBox databits;
        private javax.swing.JLabel jLabel1;
        private javax.swing.JLabel jLabel2;
        private javax.swing.JLabel jLabel3;
        private javax.swing.JLabel jLabel4;
        private javax.swing.JLabel jLabel5;
        private javax.swing.JPanel jPanel1;
        private javax.swing.JComboBox parity;
        private javax.swing.JComboBox port;
        private javax.swing.JComboBox stopbits;
        // End of variables declaration//GEN-END:variables
	/**
	 * Gets default instance. Do not use directly: reserved for *.settings files only,
	 * i.e. deserialization routines; otherwise you could get a non-deserialized instance.
	 * To obtain the singleton instance, use {@link findInstance}.
	 */
	public static synchronized plotTopComponent getDefault() {
		if (instance == null) {
			instance = new plotTopComponent();
		}
		return instance;
	}

	/**
	 * Obtain the plotTopComponent instance. Never call {@link #getDefault} directly!
	 */
	public static synchronized plotTopComponent findInstance() {
		TopComponent win = WindowManager.getDefault().findTopComponent(PREFERRED_ID);
		if (win == null) {
			Logger.getLogger(plotTopComponent.class.getName()).warning(
				"Cannot find " + PREFERRED_ID + " component. It will not be located properly in the window system.");
			return getDefault();
		}
		if (win instanceof plotTopComponent) {
			return (plotTopComponent) win;
		}
		Logger.getLogger(plotTopComponent.class.getName()).warning(
			"There seem to be multiple components with the '" + PREFERRED_ID +
			"' ID. That is a potential source of errors and unexpected behavior.");
		return getDefault();
	}

	@Override
	public int getPersistenceType() {
		return TopComponent.PERSISTENCE_ALWAYS;
	}

	@Override
	public void componentOpened() {
		// TODO add custom code on component opening
	}

	@Override
	public void componentClosed() {
		// TODO add custom code on component closing
	}

	/** replaces this in object stream */
	@Override
	public Object writeReplace() {
		return new ResolvableHelper();
	}

	@Override
	protected String preferredID() {
		return PREFERRED_ID;
	}

	final static class ResolvableHelper implements Serializable {

		private static final long serialVersionUID = 1L;

		public Object readResolve() {
			return plotTopComponent.getDefault();
		}
	}

	private JFreeChart chart;
	private XYSeries series;
	public static final int MAX_POINTS = 200;

	private void setupChart(){
		XYSeriesCollection dataset = new XYSeriesCollection();
		dataset.addSeries(series = new XYSeries("Series 1"));
		series.setMaximumItemCount(MAX_POINTS);
		
		chart = ChartFactory.createScatterPlot(
			null, 
			null, 
			"Byte", 
			dataset, 
			PlotOrientation.VERTICAL, 
			false, 
			true, 
			false
			); 

		chart.setBackgroundPaint(Color.WHITE);
		chart.setBorderVisible(true);
		chart.setBorderPaint(Color.BLACK);

		XYPlot plot = chart.getXYPlot();
		plot.setOrientation(PlotOrientation.VERTICAL);
		plot.setBackgroundPaint(Color.LIGHT_GRAY);
		plot.setDomainGridlinePaint(Color.WHITE);
		plot.setRangeGridlinePaint(Color.WHITE);

		plot.setAxisOffset(new RectangleInsets(5.0, 5.0, 5.0, 5.0));
		plot.getRangeAxis().setFixedDimension(15.0);
		XYItemRenderer renderer = plot.getRenderer();
		renderer.setSeriesPaint(0, Color.BLACK);
		

	}
	
	private DefaultComboBoxModel ports = new DefaultComboBoxModel();
	private DefaultComboBoxModel bauds = new DefaultComboBoxModel();
	private DefaultComboBoxModel parities = new DefaultComboBoxModel();
	private DefaultComboBoxModel stopBits = new DefaultComboBoxModel();
	private DefaultComboBoxModel dataBits = new DefaultComboBoxModel();
	private SerialPort serial;

	
	private void setupSerialOptions(){
		
		parities.addElement(new SerialPortProperty("Even", SerialPort.PARITY_EVEN));
		parities.addElement(new SerialPortProperty("Mark", SerialPort.PARITY_MARK));
		parities.addElement(new SerialPortProperty("None", SerialPort.PARITY_NONE));
		parities.addElement(new SerialPortProperty("Odd", SerialPort.PARITY_ODD));
		parities.addElement(new SerialPortProperty("Space", SerialPort.PARITY_SPACE));

		Enumeration portList = CommPortIdentifier.getPortIdentifiers();
		CommPortIdentifier portId;
		
		while(portList.hasMoreElements()){
			portId = (CommPortIdentifier) portList.nextElement();
			if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL){
				ports.addElement(portId.getName());
			}
		}
		
		bauds.addElement(new SerialPortProperty("4800", 4800));
		bauds.addElement(new SerialPortProperty("9600", 9600));
		bauds.addElement(new SerialPortProperty("11250", 11250));
		
		stopBits.addElement(new SerialPortProperty("1", SerialPort.STOPBITS_1));
		stopBits.addElement(new SerialPortProperty("1.5", SerialPort.STOPBITS_1_5));
		stopBits.addElement(new SerialPortProperty("2", SerialPort.STOPBITS_2));
		
		dataBits.addElement(new SerialPortProperty("5", SerialPort.DATABITS_5));
		dataBits.addElement(new SerialPortProperty("6", SerialPort.DATABITS_6));
		dataBits.addElement(new SerialPortProperty("7", SerialPort.DATABITS_7));
		dataBits.addElement(new SerialPortProperty("8", SerialPort.DATABITS_8));
	}
	
}