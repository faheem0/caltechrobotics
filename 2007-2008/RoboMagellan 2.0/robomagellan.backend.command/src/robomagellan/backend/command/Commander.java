/**
 * Commander.java
 */

package robomagellan.backend.command;

import java.util.concurrent.PriorityBlockingQueue;

/**
 * This is a static class that is responsible for sending commands.
 * @author tonyfwu
 *
 */
public class Commander {

	private static PriorityBlockingQueue<ComparableCommand> PQ = new PriorityBlockingQueue<ComparableCommand>();
	
	/**
	 * Enqueues a command and places it based on its relative priority.
	 * @param c the command to send.
	 */
	public static synchronized void Send(Command c){
		PQ.put(new ComparableCommand(c));
	}
	
	/**
	 * Sends out a command.
	 */
	public static synchronized void Dispatch()
	{
		try{
			PQ.take().getCommand().send();
		} catch (InterruptedException e){
			System.err.println("Command was interrupted while trying to send command");
		}
	}
	
}
