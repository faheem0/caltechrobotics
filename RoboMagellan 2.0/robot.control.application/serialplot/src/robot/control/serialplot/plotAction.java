/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robot.control.serialplot;

import java.awt.event.ActionEvent;
import javax.swing.AbstractAction;
import javax.swing.ImageIcon;
import org.openide.util.NbBundle;
import org.openide.util.Utilities;
import org.openide.windows.TopComponent;

/**
 * Action which shows plot component.
 */
public class plotAction extends AbstractAction {

	public plotAction() {
		super(NbBundle.getMessage(plotAction.class, "CTL_plotAction"));
		putValue(SMALL_ICON, new ImageIcon(Utilities.loadImage(plotTopComponent.ICON_PATH, true)));
	}

	public void actionPerformed(ActionEvent evt) {
		TopComponent win = plotTopComponent.findInstance();
		win.open();
		win.requestActive();
	}
}
