/*
 * KeyboardCommander.java
 *
 * Created on October 30, 2007, 12:32 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package RobotLib;
import java.awt.event.*;
/**
 * @version 0.2
 * @author tonyfwu
 */
public class KeyboardCommander implements KeyListener{
    private Robot r;
    private int leftSpeed;
    private int rightSpeed;
    /** Creates a new instance of KeyboardCommander .
     * @param   robot   the Robot object to control
     */
    public KeyboardCommander(Robot robot) {
        r = robot;
        leftSpeed = 100;
        rightSpeed = 100;
    }
    /** When a key is typed, this function executes
     */
    public void keyTyped(KeyEvent e){

    }
    /** When a key is pressed, this function executes
     */
    public void keyPressed(KeyEvent e){
        int key = e.getKeyCode();
        switch(key){
            case KeyEvent.VK_W: // w is forward
                r.setLeftWheelSpeed(leftSpeed);
                r.setRightWheelSpeed(rightSpeed);
                System.out.println("\tRobot: Forward");
                break;
            case KeyEvent.VK_A: // a is turn left
                r.setLeftWheelSpeed(-1 * leftSpeed);
                r.setRightWheelSpeed(rightSpeed);
                System.out.println("\tRobot: Turn Left");
                break;
            case KeyEvent.VK_S: // s is backward
                r.setLeftWheelSpeed(-1 * leftSpeed);
                r.setRightWheelSpeed(-1 * rightSpeed);
                System.out.println("\tRobot: Backward");
                break;
            case KeyEvent.VK_D: // d is turn right
                r.setLeftWheelSpeed(leftSpeed);
                r.setRightWheelSpeed(-1 * rightSpeed);
                System.out.println("\tRobot: Turn Right");
                break;
            case KeyEvent.VK_SPACE: // spacebar is stop
                r.setLeftWheelSpeed(0);
                r.setRightWheelSpeed(0);
                System.out.println("\tRobot: Stop");
                break;
            case KeyEvent.VK_ESCAPE: //escape shuts down
                System.out.println("Shutting Down...");
                r.shutdown();
                System.exit(0);
                break;
            case KeyEvent.VK_LEFT: //Left moves the servo left 5 degrees
                if (r.SERVO1_ANGLE > Robot.MIN_SERVO1_ANGLE + 1){
                    r.SERVO1_ANGLE -= 1;
                    r.setServo1(r.SERVO1_ANGLE);
                }
                break;
            case KeyEvent.VK_RIGHT: //Right moves the servo right 5 degrees
                if (r.SERVO1_ANGLE < Robot.MAX_SERVO1_ANGLE - 1){
                    r.SERVO1_ANGLE += 1;
                    r.setServo1(r.SERVO1_ANGLE);
                }
                break;
            case KeyEvent.VK_MINUS:
                if (leftSpeed > 10){
                    leftSpeed -= 10;
                    rightSpeed -= 10;
                    System.out.println("\tRobot: Speed: " + leftSpeed);
                }
                break;
            case KeyEvent.VK_EQUALS:
                if (leftSpeed < 100){
                    leftSpeed += 10;
                    rightSpeed += 10;
                    System.out.println("\tRobot: Speed: " + leftSpeed);
                }
                break;
            default: 
                r.setLeftWheelSpeed(0);
                r.setRightWheelSpeed(0);
                System.out.println("Unmapped Key Pressed: Robot: Stop");
                break;
        }
    }
    /** When a key is released, this function executes
     */
    public void keyReleased(KeyEvent e){
    }
    
}
