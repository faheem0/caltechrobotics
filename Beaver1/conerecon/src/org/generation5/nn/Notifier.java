/*
 * Notifier.java
 * Created on 24 November 2004, 18:31
 *
 * Copyright 2004, Generation5. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify it under 
 * the terms of the GNU General Public License as published by the Free Software 
 * Foundation; either version 2 of the License, or (at your option) any later 
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple 
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */

package org.generation5.nn;

/**
 * The neural network notifier interface.
 * @author James Matthews
 */
public interface Notifier {
    /**
     * A neural network notification.
     * @param id the message ID.
     * @param from the <code>NeuralNetworkTrainer</code> this message originates from.
     * @param data notification-specific object data, if required.
     * @return notification-specific integer to return, if required.
     */    
    public int notify(int id, NeuralNetworkTrainer from, Object data);
}
