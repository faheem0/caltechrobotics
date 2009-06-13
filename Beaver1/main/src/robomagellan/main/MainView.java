/*
 * MainView.java
 */

package robomagellan.main;

import com.bbn.openmap.LatLonPoint;
import com.bbn.openmap.proj.Ellipsoid;
import com.bbn.openmap.proj.Ellipsoid;
import com.bbn.openmap.proj.coords.UTMPoint;
import java.awt.Color;
import java.awt.Image;
import java.awt.Rectangle;
import java.io.IOException;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.jdesktop.application.Action;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.FrameView;
import org.jdesktop.application.Task;
import org.jdesktop.application.TaskMonitor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import javax.swing.Timer;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.table.DefaultTableModel;
import robomagellan.compass.Compass;
import robomagellan.conerecon.ConeRecon;
import robomagellan.flow.Flow;
import robomagellan.gps.AC12GPS;
import robomagellan.helpers.SerialPortFactory;
import robomagellan.imu.CristaIMU;
import robomagellan.motors.Motors;
import org.jdesktop.swingx.mapviewer.GeoPosition;
import javax.swing.filechooser.FileFilter;
import javax.swing.table.TableModel;
import org.jdesktop.swingx.mapviewer.WaypointPainter;
import robomagellan.conerecon.ConeRecon.ConeInfo;
import robomagellan.gps.GPSPacket;
import uk.me.jstott.jcoord.LatLng;
import uk.me.jstott.jcoord.OSRef;

/**
 * The application's main frame.
 */
public class MainView extends FrameView{

    /**
     * The Current Flow
     */
    private Flow flow;
    /**
     * Statistics Table Data
     */
    public static DefaultTableModel statTableData;
    /**
     * Waypoint Table Data
     */
    public static DefaultTableModel wpTableData;

    /**
     * Waypoint Table UTM Easting Column Location
     */
    public static final int WPTABLE_EAST_COL_LOC = 0;
    /**
     * Waypoint Table UTM Northing Column Location
     */
    public static final int WPTABLE_NORTH_COL_LOC = 1;
    /**
     * Waypoint Table Waypoint Type Column Location
     */
    public static final int WPTABLE_TYPE_COL_LOC = 2;
    /**
     * Waypoint Table Reached Indicator Column Location
     */
    public static final int WPTABLE_REACHED_COL_LOC = 3;

    public static final int STATTABLE_SENSOR_COL_LOC = 0;
    public static final int STATTABLE_DEV_COL_LOC = 1;
    public static final int STATTABLE_X_COL_LOC = 2;
    public static final int STATTABLE_Y_COL_LOC = 3;
    public static final int STATTABLE_Z_COL_LOC = 4;

    public static final int STATTABLE_GPS_ROW_LOC = 0;
    public static final int STATTABLE_ACC_ROW_LOC = 1;
    public static final int STATTABLE_GYRO_ROW_LOC = 2;
    public static final int STATTABLE_COMPASS_ROW_LOC = 3;
    public static final int STATTABLE_ENCODER_ROW_LOC = 4;
    public static final int STATTABLE_KALMAN_ROW_LOC = 5;

    private static final String LOG_FILE_NAME = "/home/robomagellan/logs/run";
    private static BufferedWriter fileOut;

    public static final String UTM_ZONE = "11S";

    private static Thread camUpdateThread;

    public MainView(SingleFrameApplication app) {
        super(app);
        FileWriter fstream;
        try {
            fstream = new FileWriter(LOG_FILE_NAME + System.currentTimeMillis() + ".txt");
            fileOut = new BufferedWriter(fstream);
        } catch (IOException ex) {
            Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
        }

        MainApp.serialPortList = SerialPortFactory.getPortList();
        initComponents();

        // status bar initialization - message timeout, idle icon and busy animation, etc
        ResourceMap resourceMap = getResourceMap();
        int messageTimeout = resourceMap.getInteger("StatusBar.messageTimeout");
        messageTimer = new Timer(messageTimeout, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                statusMessageLabel.setText("");
            }
        });
        messageTimer.setRepeats(false);
        int busyAnimationRate = resourceMap.getInteger("StatusBar.busyAnimationRate");
        for (int i = 0; i < busyIcons.length; i++) {
            busyIcons[i] = resourceMap.getIcon("StatusBar.busyI cons[" + i + "]");
        }
        busyIconTimer = new Timer(busyAnimationRate, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                busyIconIndex = (busyIconIndex + 1) % busyIcons.length;
                statusAnimationLabel.setIcon(busyIcons[busyIconIndex]);
            }
        });
        idleIcon = resourceMap.getIcon("StatusBar.idleIcon");
        statusAnimationLabel.setIcon(idleIcon);
        progressBar.setVisible(false);

        // connecting action tasks to status bar via TaskMonitor
        TaskMonitor taskMonitor = new TaskMonitor(getApplication().getContext());
        taskMonitor.addPropertyChangeListener(new java.beans.PropertyChangeListener() {
            public void propertyChange(java.beans.PropertyChangeEvent evt) {
                String propertyName = evt.getPropertyName();
                if ("started".equals(propertyName)) {
                    if (!busyIconTimer.isRunning()) {
                        statusAnimationLabel.setIcon(busyIcons[0]);
                        busyIconIndex = 0;
                        busyIconTimer.start();
                    }
                    progressBar.setVisible(true);
                    progressBar.setIndeterminate(true);
                } else if ("done".equals(propertyName)) {
                    busyIconTimer.stop();
                    statusAnimationLabel.setIcon(idleIcon);
                    progressBar.setVisible(false);
                    progressBar.setValue(0);
                } else if ("message".equals(propertyName)) {
                    String text = (String)(evt.getNewValue());
                    statusMessageLabel.setText((text == null) ? "" : text);
                    messageTimer.restart();
                } else if ("progress".equals(propertyName)) {
                    int value = (Integer)(evt.getNewValue());
                    progressBar.setVisible(true);
                    progressBar.setIndeterminate(false);
                    progressBar.setValue(value);
                }
            }
        });
        //initStatTable();
    }

    @Action
    public void createFlow(){
        int option = openXMLChooser.showOpenDialog(MainApp.getApplication().getMainFrame());
        if (option == JFileChooser.APPROVE_OPTION){
            flow = FlowFactory.buildFlow(openXMLChooser.getSelectedFile());
        }
    }
    @Action
    public void importWaypoints() {
        int option = openXMLChooser.showOpenDialog(MainApp.getApplication().getMainFrame());
        if (option == JFileChooser.APPROVE_OPTION){
            ArrayList<Waypoint> importedWpts= WaypointFactory.importWaypoints(openXMLChooser.getSelectedFile());
            Set<org.jdesktop.swingx.mapviewer.Waypoint> s = new HashSet<org.jdesktop.swingx.mapviewer.Waypoint>();
            for (int i = 0; i < importedWpts.size(); i++){
                MainApp.wpts.add(importedWpts.get(i));
                System.out.println((float)importedWpts.get(i).coord.utmEast + " " + (float)importedWpts.get(i).coord.utmNorth);
                LatLonPoint ll = UTMPoint.UTMtoLL(Ellipsoid.WGS_84, (float)importedWpts.get(i).coord.utmNorth, (float)importedWpts.get(i).coord.utmEast, UTM_ZONE, null);
                System.out.println(ll.getLatitude()+90.26957 + " " + (ll.getLongitude()+0.542945));
                s.add(new org.jdesktop.swingx.mapviewer.Waypoint(ll.getLatitude()+90.26957, ll.getLongitude()+0.542945));
                jXMapKit1.setCenterPosition(new GeoPosition(ll.getLatitude()+90.26957, ll.getLongitude()+0.542945));

                GPSPacket pack = importedWpts.get(i).coord;
                wpTableData.addRow(new Object[]{pack.utmEast, pack.utmNorth,  importedWpts.get(i).type, false});
            }
            wpTable.updateUI();
            WaypointPainter painter = new WaypointPainter();
            painter.setWaypoints(s);
            jXMapKit1.getMainMap().setOverlayPainter(painter);

        }
    }

    @Action
    public void showAboutBox() {
        if (aboutBox == null) {
            JFrame mainFrame = MainApp.getApplication().getMainFrame();
            aboutBox = new MainAboutBox(mainFrame);
            aboutBox.setLocationRelativeTo(mainFrame);
        }
        MainApp.getApplication().show(aboutBox);
    }

    @Action
    public void openConnections() {
        JFrame mainFrame = MainApp.getApplication().getMainFrame();
        connectionOptions = new MainConnectionOptions();
        connectionOptions.setLocationRelativeTo(mainFrame);
        MainApp.getApplication().show(connectionOptions);
    }

    /**
     * Logs data to the log pane. Thread safe.
     * @param s string to be appended to the log.
     */
    public static synchronized void log(String s){
        logPane.setText(logPane.getText() + "\n" + s);
        logPane.scrollRectToVisible(new Rectangle(0,logPane.getHeight()-2,1,1));
        try {
            fileOut.write(s + "\n");
            fileOut.flush();
        } catch (IOException ex) {
            Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        mainPanel = new javax.swing.JPanel();
        jTabbedPane1 = new javax.swing.JTabbedPane();
        jPanel1 = new javax.swing.JPanel();
        jScrollPane2 = new javax.swing.JScrollPane();
        statTable = new javax.swing.JTable();
        camPanel = new javax.swing.JPanel();
        camIcon = new javax.swing.JLabel();
        jPanel3 = new javax.swing.JPanel();
        jXMapKit1 = new org.jdesktop.swingx.JXMapKit();
        jPanel4 = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        logPane = new javax.swing.JTextPane();
        jPanel5 = new javax.swing.JPanel();
        jScrollPane3 = new javax.swing.JScrollPane();
        wpTable = new javax.swing.JTable();
        jToolBar1 = new javax.swing.JToolBar();
        openButton = new javax.swing.JButton();
        connectButton = new javax.swing.JToggleButton();
        startButton = new javax.swing.JToggleButton();
        jSeparator2 = new javax.swing.JToolBar.Separator();
        menuBar = new javax.swing.JMenuBar();
        javax.swing.JMenu fileMenu = new javax.swing.JMenu();
        openFlowMenuItem = new javax.swing.JMenuItem();
        importMenuItem = new javax.swing.JMenuItem();
        jSeparator1 = new javax.swing.JSeparator();
        javax.swing.JMenuItem exitMenuItem = new javax.swing.JMenuItem();
        toolsMenu = new javax.swing.JMenu();
        jMenuItem1 = new javax.swing.JMenuItem();
        mapMenu = new javax.swing.JMenu();
        satRadioButton = new javax.swing.JRadioButtonMenuItem();
        terRadioButton = new javax.swing.JRadioButtonMenuItem();
        streetRadioButton = new javax.swing.JRadioButtonMenuItem();
        openStreetRadioButton = new javax.swing.JRadioButtonMenuItem();
        javax.swing.JMenu helpMenu = new javax.swing.JMenu();
        javax.swing.JMenuItem aboutMenuItem = new javax.swing.JMenuItem();
        statusPanel = new javax.swing.JPanel();
        javax.swing.JSeparator statusPanelSeparator = new javax.swing.JSeparator();
        statusMessageLabel = new javax.swing.JLabel();
        statusAnimationLabel = new javax.swing.JLabel();
        progressBar = new javax.swing.JProgressBar();
        openXMLChooser = new javax.swing.JFileChooser();
        mapGroup = new javax.swing.ButtonGroup();

        mainPanel.setName("mainPanel"); // NOI18N

        jTabbedPane1.setName("jTabbedPane1"); // NOI18N

        jPanel1.setName("jPanel1"); // NOI18N

        jScrollPane2.setName("jScrollPane2"); // NOI18N

        statTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null}
            },
            new String [] {
                "Sensor", "Device", "Reading X", "Reading Y", "Reading Z"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.String.class, java.lang.String.class, java.lang.Double.class, java.lang.Double.class, java.lang.Double.class
            };
            boolean[] canEdit = new boolean [] {
                false, false, false, false, false
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        statTable.setName("statTable"); // NOI18N
        statTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane2.setViewportView(statTable);
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(robomagellan.main.MainApp.class).getContext().getResourceMap(MainView.class);
        statTable.getColumnModel().getColumn(0).setHeaderValue(resourceMap.getString("statTable.columnModel.title0")); // NOI18N
        statTable.getColumnModel().getColumn(1).setHeaderValue(resourceMap.getString("statTable.columnModel.title1")); // NOI18N
        statTable.getColumnModel().getColumn(2).setHeaderValue(resourceMap.getString("statTable.columnModel.title2")); // NOI18N
        statTable.getColumnModel().getColumn(3).setHeaderValue(resourceMap.getString("statTable.columnModel.title3")); // NOI18N
        statTable.getColumnModel().getColumn(4).setHeaderValue(resourceMap.getString("statTable.columnModel.title4")); // NOI18N
        initStatTable();

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 678, Short.MAX_VALUE)
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 198, Short.MAX_VALUE)
        );

        jTabbedPane1.addTab(resourceMap.getString("jPanel1.TabConstraints.tabTitle"), jPanel1); // NOI18N

        camPanel.setName("camPanel"); // NOI18N

        camIcon.setText(resourceMap.getString("camIcon.text")); // NOI18N
        camIcon.setName("camIcon"); // NOI18N

        javax.swing.GroupLayout camPanelLayout = new javax.swing.GroupLayout(camPanel);
        camPanel.setLayout(camPanelLayout);
        camPanelLayout.setHorizontalGroup(
            camPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(camPanelLayout.createSequentialGroup()
                .addComponent(camIcon)
                .addContainerGap(678, Short.MAX_VALUE))
        );
        camPanelLayout.setVerticalGroup(
            camPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(camPanelLayout.createSequentialGroup()
                .addComponent(camIcon)
                .addContainerGap(198, Short.MAX_VALUE))
        );

        jTabbedPane1.addTab(resourceMap.getString("camPanel.TabConstraints.tabTitle"), camPanel); // NOI18N

        jPanel3.setName("jPanel3"); // NOI18N

        jXMapKit1.setDefaultProvider(org.jdesktop.swingx.JXMapKit.DefaultProviders.OpenStreetMaps);
        //jXMapKit1.setTileFactory(GoogleMapsTileProvider.getDefaultTileFactory());
        jXMapKit1.setDataProviderCreditShown(true);
        jXMapKit1.setName("jXMapKit1"); // NOI18N
        jXMapKit1.setAddressLocation(new GeoPosition(34.138577, -118.125494));

        javax.swing.GroupLayout jPanel3Layout = new javax.swing.GroupLayout(jPanel3);
        jPanel3.setLayout(jPanel3Layout);
        jPanel3Layout.setHorizontalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jXMapKit1, javax.swing.GroupLayout.DEFAULT_SIZE, 678, Short.MAX_VALUE)
        );
        jPanel3Layout.setVerticalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jXMapKit1, javax.swing.GroupLayout.DEFAULT_SIZE, 198, Short.MAX_VALUE)
        );

        jTabbedPane1.addTab(resourceMap.getString("jPanel3.TabConstraints.tabTitle"), jPanel3); // NOI18N

        jPanel4.setName("jPanel4"); // NOI18N

        jScrollPane1.setName("jScrollPane1"); // NOI18N

        logPane.setName("logPane"); // NOI18N
        jScrollPane1.setViewportView(logPane);

        javax.swing.GroupLayout jPanel4Layout = new javax.swing.GroupLayout(jPanel4);
        jPanel4.setLayout(jPanel4Layout);
        jPanel4Layout.setHorizontalGroup(
            jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 678, Short.MAX_VALUE)
        );
        jPanel4Layout.setVerticalGroup(
            jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 198, Short.MAX_VALUE)
        );

        jTabbedPane1.addTab(resourceMap.getString("jPanel4.TabConstraints.tabTitle"), jPanel4); // NOI18N

        jPanel5.setName("jPanel5"); // NOI18N

        jScrollPane3.setName("jScrollPane3"); // NOI18N

        wpTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {
                "UTM East", "UTM North", "Type", "Reached"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.Double.class, java.lang.Double.class, java.lang.String.class, java.lang.Boolean.class
            };
            boolean[] canEdit = new boolean [] {
                false, false, false, false
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        wpTable.setName("wpTable"); // NOI18N
        wpTable.getTableHeader().setReorderingAllowed(false);
        jScrollPane3.setViewportView(wpTable);
        wpTable.getColumnModel().getColumn(0).setHeaderValue(resourceMap.getString("wpTable.columnModel.title0")); // NOI18N
        wpTable.getColumnModel().getColumn(1).setHeaderValue(resourceMap.getString("wpTable.columnModel.title1")); // NOI18N
        wpTable.getColumnModel().getColumn(2).setHeaderValue(resourceMap.getString("wpTable.columnModel.title2")); // NOI18N
        wpTable.getColumnModel().getColumn(3).setHeaderValue(resourceMap.getString("wpTable.columnModel.title3")); // NOI18N
        initWPTable();

        javax.swing.GroupLayout jPanel5Layout = new javax.swing.GroupLayout(jPanel5);
        jPanel5.setLayout(jPanel5Layout);
        jPanel5Layout.setHorizontalGroup(
            jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 678, Short.MAX_VALUE)
        );
        jPanel5Layout.setVerticalGroup(
            jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 198, Short.MAX_VALUE)
        );

        jTabbedPane1.addTab(resourceMap.getString("jPanel5.TabConstraints.tabTitle"), jPanel5); // NOI18N

        jToolBar1.setRollover(true);
        jToolBar1.setName("jToolBar1"); // NOI18N

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(robomagellan.main.MainApp.class).getContext().getActionMap(MainView.class, this);
        openButton.setAction(actionMap.get("createFlow")); // NOI18N
        openButton.setText(resourceMap.getString("openButton.text")); // NOI18N
        openButton.setFocusable(false);
        openButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        openButton.setName("openButton"); // NOI18N
        openButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        jToolBar1.add(openButton);

        connectButton.setAction(actionMap.get("connectAction")); // NOI18N
        connectButton.setText(resourceMap.getString("connectButton.text")); // NOI18N
        connectButton.setFocusable(false);
        connectButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        connectButton.setName("connectButton"); // NOI18N
        connectButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        jToolBar1.add(connectButton);

        startButton.setAction(actionMap.get("startAction")); // NOI18N
        startButton.setText(resourceMap.getString("startButton.text")); // NOI18N
        startButton.setFocusable(false);
        startButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        startButton.setName("startButton"); // NOI18N
        startButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        jToolBar1.add(startButton);

        jSeparator2.setName("jSeparator2"); // NOI18N
        jToolBar1.add(jSeparator2);

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jToolBar1, javax.swing.GroupLayout.DEFAULT_SIZE, 683, Short.MAX_VALUE)
            .addComponent(jTabbedPane1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 683, Short.MAX_VALUE)
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(mainPanelLayout.createSequentialGroup()
                .addComponent(jToolBar1, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTabbedPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 225, Short.MAX_VALUE))
        );

        menuBar.setName("menuBar"); // NOI18N

        fileMenu.setText(resourceMap.getString("fileMenu.text")); // NOI18N
        fileMenu.setName("fileMenu"); // NOI18N

        openFlowMenuItem.setAction(actionMap.get("createFlow")); // NOI18N
        openFlowMenuItem.setText(resourceMap.getString("openFlowMenuItem.text")); // NOI18N
        openFlowMenuItem.setName("openFlowMenuItem"); // NOI18N
        fileMenu.add(openFlowMenuItem);

        importMenuItem.setAction(actionMap.get("importWaypoints")); // NOI18N
        importMenuItem.setText(resourceMap.getString("importMenuItem.text")); // NOI18N
        importMenuItem.setName("importMenuItem"); // NOI18N
        fileMenu.add(importMenuItem);

        jSeparator1.setName("jSeparator1"); // NOI18N
        fileMenu.add(jSeparator1);

        exitMenuItem.setAction(actionMap.get("quit")); // NOI18N
        exitMenuItem.setName("exitMenuItem"); // NOI18N
        fileMenu.add(exitMenuItem);

        menuBar.add(fileMenu);

        toolsMenu.setText(resourceMap.getString("toolsMenu.text")); // NOI18N
        toolsMenu.setName("toolsMenu"); // NOI18N

        jMenuItem1.setAction(actionMap.get("openConnections")); // NOI18N
        jMenuItem1.setText(resourceMap.getString("jMenuItem1.text")); // NOI18N
        jMenuItem1.setName("jMenuItem1"); // NOI18N
        toolsMenu.add(jMenuItem1);

        mapMenu.setText(resourceMap.getString("mapMenu.text")); // NOI18N
        mapMenu.setName("mapMenu"); // NOI18N

        satRadioButton.setAction(actionMap.get("satMapSelected")); // NOI18N
        satRadioButton.setText(resourceMap.getString("satRadioButton.text")); // NOI18N
        satRadioButton.setName("satRadioButton"); // NOI18N
        mapMenu.add(satRadioButton);

        terRadioButton.setAction(actionMap.get("terMapSelected")); // NOI18N
        terRadioButton.setText(resourceMap.getString("terRadioButton.text")); // NOI18N
        terRadioButton.setName("terRadioButton"); // NOI18N
        mapMenu.add(terRadioButton);

        streetRadioButton.setAction(actionMap.get("streetMapSelected")); // NOI18N
        streetRadioButton.setText(resourceMap.getString("streetRadioButton.text")); // NOI18N
        streetRadioButton.setName("streetRadioButton"); // NOI18N
        mapMenu.add(streetRadioButton);

        openStreetRadioButton.setAction(actionMap.get("openStreetMapSelected")); // NOI18N
        openStreetRadioButton.setSelected(true);
        openStreetRadioButton.setText(resourceMap.getString("openStreetRadioButton.text")); // NOI18N
        openStreetRadioButton.setName("openStreetRadioButton"); // NOI18N
        mapMenu.add(openStreetRadioButton);

        toolsMenu.add(mapMenu);

        menuBar.add(toolsMenu);

        helpMenu.setText(resourceMap.getString("helpMenu.text")); // NOI18N
        helpMenu.setName("helpMenu"); // NOI18N

        aboutMenuItem.setAction(actionMap.get("showAboutBox")); // NOI18N
        aboutMenuItem.setName("aboutMenuItem"); // NOI18N
        helpMenu.add(aboutMenuItem);

        menuBar.add(helpMenu);

        statusPanel.setName("statusPanel"); // NOI18N

        statusPanelSeparator.setName("statusPanelSeparator"); // NOI18N

        statusMessageLabel.setName("statusMessageLabel"); // NOI18N

        statusAnimationLabel.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);
        statusAnimationLabel.setName("statusAnimationLabel"); // NOI18N

        progressBar.setName("progressBar"); // NOI18N

        javax.swing.GroupLayout statusPanelLayout = new javax.swing.GroupLayout(statusPanel);
        statusPanel.setLayout(statusPanelLayout);
        statusPanelLayout.setHorizontalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(statusPanelSeparator, javax.swing.GroupLayout.DEFAULT_SIZE, 683, Short.MAX_VALUE)
            .addGroup(statusPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(statusMessageLabel)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 499, Short.MAX_VALUE)
                .addComponent(progressBar, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(statusAnimationLabel)
                .addContainerGap())
        );
        statusPanelLayout.setVerticalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(statusPanelLayout.createSequentialGroup()
                .addComponent(statusPanelSeparator, javax.swing.GroupLayout.PREFERRED_SIZE, 2, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(statusMessageLabel)
                    .addComponent(statusAnimationLabel)
                    .addComponent(progressBar, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(3, 3, 3))
        );

        openXMLChooser.setFileFilter(new ExtensionFileFilter("XML Files", new String[] { "xml" }));
        openXMLChooser.setName("openXMLChooser"); // NOI18N
        mapGroup.add(satRadioButton);
        mapGroup.add(terRadioButton);
        mapGroup.add(streetRadioButton);
        mapGroup.add(openStreetRadioButton);

        setComponent(mainPanel);
        setMenuBar(menuBar);
        setStatusBar(statusPanel);
    }// </editor-fold>//GEN-END:initComponents

    @Action
    public void connectAction() {
        if (connectButton.isSelected()){
            try {
                MainApp.filter = new KalmanFilter();
            } catch (Exception ex) {
                Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
            }
            progressBar.setIndeterminate(false);
            progressBar.setStringPainted(true);
            if (MainApp.gpsPort != null){
                try {
                    MainView.log("Connecting to GPS at " + MainApp.gpsPort);
                    MainApp.gps = new AC12GPS(MainApp.gpsPort);
                    MainApp.gps.addGPSDataListener(MainApp.filter);
                    progressBar.setValue(20);
                    statTableData.setValueAt(MainApp.gpsPort, STATTABLE_GPS_ROW_LOC, STATTABLE_DEV_COL_LOC);
                } catch (TooManyListenersException ex) {
                    Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            if (MainApp.compassPort != null){
                try {
                    MainView.log("Connecting to Compass at " + MainApp.compassPort);
                    MainApp.compass = new Compass(MainApp.compassPort);
                    MainApp.compass.addCompassDataListener(MainApp.filter);
                    progressBar.setValue(40);
                    statTableData.setValueAt(MainApp.compassPort, STATTABLE_COMPASS_ROW_LOC, STATTABLE_DEV_COL_LOC);
                }  catch (TooManyListenersException ex) {
                    Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                }
            }

            if (MainApp.imuPort != null){
                try {
                    MainView.log("Connecting to IMU at " + MainApp.imuPort);
                    MainApp.imu = new CristaIMU(MainApp.imuPort);
                    MainApp.imu.addIMUDataListener(MainApp.filter);
                    progressBar.setValue(80);
                    statTableData.setValueAt(MainApp.imuPort, STATTABLE_ACC_ROW_LOC, STATTABLE_DEV_COL_LOC);
                    statTableData.setValueAt(MainApp.imuPort, STATTABLE_GYRO_ROW_LOC, STATTABLE_DEV_COL_LOC);
                }  catch (TooManyListenersException ex) {
                    Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                }
            }

            if (MainApp.motorPort != null){
                try {
                    MainView.log("Connecting to Motors at " + MainApp.motorPort);
                    MainApp.motors = new Motors(MainApp.motorPort);
                    MainApp.motors.addEncoderDataListener(MainApp.filter);
                    MainApp.motors.setSpeed(Motors.LEFT, 0);
                    MainApp.motors.setSpeed(Motors.RIGHT, 0);
                    progressBar.setValue(100);
                    statTableData.setValueAt(MainApp.motorPort, STATTABLE_ENCODER_ROW_LOC, STATTABLE_DEV_COL_LOC);
                }  catch (TooManyListenersException ex) {
                    Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                }
            }

            if (MainApp.webcamPort != null){
                MainView.log("Connecting to Webcam at " + MainApp.webcamPort);
                MainApp.cam = new ConeRecon(MainApp.webcamPort);
                MainApp.cam.start();
            }

            camUpdateThread= new Thread(new Runnable(){
                final ConeRecon cam = MainApp.cam;
                final JLabel icon = camIcon;
                public void run() {

                    while (!Thread.currentThread().isInterrupted()){
                        if (cam != null) {
                            ConeInfo info = cam.getInfo();
                            Image im = info.image;
                            if (im != null) {
                                if (info.detected) {
                                    BufferedImage bi = (BufferedImage) im;
                                    im.getGraphics().setColor(Color.BLACK);
                                    im.getGraphics().drawLine(info.x, 0, info.x, bi.getHeight());
                                    im.getGraphics().drawLine(0, info.y, bi.getWidth(), info.y);
                                    im.getGraphics().fillOval(info.x - 5, info.y - 5, 10, 10);
                                }
                                icon.setIcon(new ImageIcon(cam.getInfo().image));
                            }
                        }
                            try {
                                Thread.sleep(33);
                            } catch (InterruptedException ex) {
                                Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                            }
                        
                    }

                }
            });
            camUpdateThread.start();
            
            statusMessageLabel.setText("Connected");
            progressBar.setValue(0);
            progressBar.setStringPainted(false);
        } else {
            if (MainApp.motors != null)
                MainApp.motors.stop();
            if (MainApp.compass != null)
                MainApp.compass.stop();
            if (MainApp.imu != null)
                MainApp.imu.stop();
            if (MainApp.gps != null)
                MainApp.gps.stop();
            if (MainApp.cam != null)
                MainApp.cam.stop();
            if (camUpdateThread != null){
                camUpdateThread.interrupt();
                try {
                    MainApp.cam.stop();
                    camUpdateThread.join();
                } catch (InterruptedException ex) {
                    Logger.getLogger(MainView.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            progressBar.setIndeterminate(false);
            progressBar.setValue(0);
            progressBar.setStringPainted(false);
            statusMessageLabel.setText("Disconnected");
        }
    }

    @Action
    public Task startAction() {
        if (startButton.isSelected()){
            MainView.log("Starting");
            MainApp.runTask = new StartActionTask(getApplication());
            return MainApp.runTask;
        } else {
            MainApp.runTask.cancel(true);
            return null;
        }
    }

    private void initStatTable() {
        statTableData = (DefaultTableModel) statTable.getModel();
        statTableData.setValueAt("GPS", STATTABLE_GPS_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
        statTableData.setValueAt("IMU Acc", STATTABLE_ACC_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
        statTableData.setValueAt("IMU Gyro", STATTABLE_GYRO_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
        statTableData.setValueAt("Compass", STATTABLE_COMPASS_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
        statTableData.setValueAt("Encoders", STATTABLE_ENCODER_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
        statTableData.setValueAt("Kalman Filter", STATTABLE_KALMAN_ROW_LOC, STATTABLE_SENSOR_COL_LOC);
    }
    private void initWPTable(){
        wpTableData = (DefaultTableModel) wpTable.getModel();
    }

    private class StartActionTask extends org.jdesktop.application.Task<Object, Void> {
        StartActionTask(org.jdesktop.application.Application app) {
            // Runs on the EDT.  Copy GUI state that
            // doInBackground() depends on from parameters
            // to StartActionTask fields, here.
            super(app);
        }
        @Override protected Object doInBackground() {
            // Your Task's code here.  This method runs
            // on a background thread, so don't reference
            // the Swing GUI from here.
            flow.execute();
            return null;  // return your result
        }
        @Override protected void succeeded(Object result) {
            // Runs on the EDT.  Update the GUI based on
            // the result computed by doInBackground().
            MainView.log("Flow Complete");
        }
    }

    @Action
    public void satMapSelected() {
        GeoPosition gp = jXMapKit1.getCenterPosition();
        jXMapKit1.setTileFactory(GoogleMapsTileProvider.getSatTileFactory());
        jXMapKit1.setCenterPosition(gp);
    }

    @Action
    public void terMapSelected() {
        GeoPosition gp = jXMapKit1.getCenterPosition();
        jXMapKit1.setTileFactory(GoogleMapsTileProvider.getDefaultTileFactory());
        jXMapKit1.setCenterPosition(gp);
    }

    @Action
    public void streetMapSelected() {
        GeoPosition gp = jXMapKit1.getCenterPosition();
        jXMapKit1.setTileFactory(GoogleMapsTileProvider.getStreetTileFactory());
        jXMapKit1.setCenterPosition(gp);
    }

    @Action
    public void openStreetMapSelected() {
        GeoPosition gp = jXMapKit1.getCenterPosition();
        jXMapKit1.setDefaultProvider(org.jdesktop.swingx.JXMapKit.DefaultProviders.OpenStreetMaps);
        jXMapKit1.setCenterPosition(gp);
    }
    


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel camIcon;
    private javax.swing.JPanel camPanel;
    private javax.swing.JToggleButton connectButton;
    private javax.swing.JMenuItem importMenuItem;
    private javax.swing.JMenuItem jMenuItem1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JPanel jPanel4;
    private javax.swing.JPanel jPanel5;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JSeparator jSeparator1;
    private javax.swing.JToolBar.Separator jSeparator2;
    private javax.swing.JTabbedPane jTabbedPane1;
    private javax.swing.JToolBar jToolBar1;
    private org.jdesktop.swingx.JXMapKit jXMapKit1;
    private static javax.swing.JTextPane logPane;
    private javax.swing.JPanel mainPanel;
    private javax.swing.ButtonGroup mapGroup;
    private javax.swing.JMenu mapMenu;
    private javax.swing.JMenuBar menuBar;
    private javax.swing.JButton openButton;
    private javax.swing.JMenuItem openFlowMenuItem;
    private javax.swing.JRadioButtonMenuItem openStreetRadioButton;
    private javax.swing.JFileChooser openXMLChooser;
    private javax.swing.JProgressBar progressBar;
    private javax.swing.JRadioButtonMenuItem satRadioButton;
    private javax.swing.JToggleButton startButton;
    private volatile javax.swing.JTable statTable;
    private javax.swing.JLabel statusAnimationLabel;
    private javax.swing.JLabel statusMessageLabel;
    private javax.swing.JPanel statusPanel;
    private javax.swing.JRadioButtonMenuItem streetRadioButton;
    private javax.swing.JRadioButtonMenuItem terRadioButton;
    private javax.swing.JMenu toolsMenu;
    private volatile javax.swing.JTable wpTable;
    // End of variables declaration//GEN-END:variables

    private final Timer messageTimer;
    private final Timer busyIconTimer;
    private final Icon idleIcon;
    private final Icon[] busyIcons = new Icon[15];
    private int busyIconIndex = 0;

    private JDialog aboutBox;
    private JFrame connectionOptions;

    class ExtensionFileFilter extends FileFilter {

        String description;
        String extensions[];

        public ExtensionFileFilter(String description, String extension) {
            this(description, new String[]{extension});
        }

        public ExtensionFileFilter(String description, String extensions[]) {
            if (description == null) {
                this.description = extensions[0];
            } else {
                this.description = description;
            }
            this.extensions = (String[]) extensions.clone();
            toLower(this.extensions);
        }

        private void toLower(String array[]) {
            for (int i = 0, n = array.length; i < n; i++) {
                array[i] = array[i].toLowerCase();
            }
        }

        public String getDescription() {
            return description;
        }

        public boolean accept(File file) {
            if (file.isDirectory()) {
                return true;
            } else {
                String path = file.getAbsolutePath().toLowerCase();
                for (int i = 0, n = extensions.length; i < n; i++) {
                    String extension = extensions[i];
                    if ((path.endsWith(extension) && (path.charAt(path.length() - extension.length() - 1)) == '.')) {
                        return true;
                    }
                }
            }
            return false;
        }
    }



}
