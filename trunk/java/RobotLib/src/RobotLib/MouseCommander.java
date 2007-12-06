/*
 * MouseCommander.java
 *
 * Created on October 30, 2007, 6:03 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package RobotLib;
import java.awt.event.*;

/**
 * @version 0.0.1
 * @author tonyfwu
 */
public class MouseCommander implements MouseMotionListener{
    /** 
     * Left most coordinate of the picture
     */
    public static int X_MIN;
    /**
     *Bottom most coordinate of the picture
     */
    public static int Y_MIN;
    /**
     *Right most coordinate of the picture
     */
    public static int X_MAX;
    /**
     *Top most coordinate of the picture
     */
    public static int Y_MAX;
    /**
     *The angle of the line of sight of the camera
     */
    public static int CAMERA_PAN;
    
    private int previousX;
    private Robot r;
    /** Creates a new instance of MouseCommander 
     * @param   robot   the Robot object to control
     */
    public MouseCommander(Robot robot) {
        r = robot;
        X_MIN = 0;
        Y_MIN = 0;
        X_MAX = 100;
        Y_MAX = 100;
        CAMERA_PAN = 60;
        r.setServo1(0);
        previousX = 0;
    }
    public void mouseMoved(MouseEvent e){
        
    }
    /** 
     * When the mouse is dragged to the left, the camera follows the cursor 
     * left. When the mouse is dragged to the right, the camera follows the 
     * cursor right.
     */ 
    public void mouseDragged(MouseEvent e){
        int relativeX = previousX - e.getX();
        int newAngle = r.SERVO1_ANGLE - Integer.signum(relativeX);
        if (newAngle <= Robot.MAX_SERVO1_ANGLE && newAngle >= Robot.MIN_SERVO1_ANGLE){
            r.SERVO1_ANGLE = newAngle;
            previousX = e.getX();
            if (relativeX < 0){
                r.setServo1(r.SERVO1_ANGLE);
            }
            else if (relativeX > 0){
                r.setServo1(r.SERVO1_ANGLE);
            }
        }
    }
    
}
