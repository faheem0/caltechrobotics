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
public class TestFilter implements CamFilter{
	private CamFilter[] myFilters;
	public TestFilter(CamFilter[] filters){
		myFilters = filters;
	}
	public BufferedImage filter(BufferedImage b){
		BufferedImage filtered = b;
		for (int i = 0; i < myFilters.length; i++){
			filtered = myFilters[i].filter(filtered);
		}
		return filtered;
	}
}
