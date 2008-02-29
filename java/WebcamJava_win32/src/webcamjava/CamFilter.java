/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import java.awt.image.BufferedImage;
/**
 *
 * @author tonyfwu
 */
public interface CamFilter {
	public BufferedImage filter(BufferedImage in);
}
