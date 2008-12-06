
import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import robomagellan.conerecon.ConeRecon;
import robomagellan.conerecon.ConeRecon.ConeInfo;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author robomagellan
 */
public class ConeReconTest {
    public static void main(String[] args){
        ConeRecon cr = new ConeRecon("/dev/video0");
        cr.start();
        JFrame frame = new JFrame();
        JLabel label = new JLabel();
        ImageIcon ii = new ImageIcon();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(label);
        label.setIcon(ii);
        frame.setVisible(true);
        frame.setSize(320, 280);

        while(true){
            ConeInfo ci = cr.getInfo();
            if (ci.detected) System.out.println("Detected At " + ci.x + "," + ci.y);
            if (ci.image != null){
                BufferedImage bi = (BufferedImage) ci.image;
                WritableRaster wr = bi.getRaster();
                if (ci.detected){
                    for (int i = 0; i < wr.getWidth(); i++) wr.setSample(i, ci.y, 0, 255);
                    for (int i = 0; i < wr.getHeight(); i++) wr.setSample(ci.x, i, 0, 255);
                }
                ii = new ImageIcon(bi);
                label.setIcon(ii);
                
            }
            else System.out.println("Null");
            try {
                Thread.sleep(300);
            } catch (InterruptedException ex) {
                Logger.getLogger(ConeReconTest.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
}
