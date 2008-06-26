/**
 * Dispatcher.java
 */
package robomagellan.backend.command;

import java.lang.Thread.UncaughtExceptionHandler;

/**
 * This class polls the commander and sends out commands.
 * @author tonyfwu
 *
 */
public class Dispatcher {
	private static DispatcherThread DT;
	/**
	 * Creates an instance of the Dispatcher
	 */
	public Dispatcher(){
		if (DT == null){
			DT = new DispatcherThread();
			DT.setDaemon(true);
			DT.setName("Dispatcher");
			DT.setUncaughtExceptionHandler(new UncaughtExceptionHandler(){

				@Override
				public void uncaughtException(Thread arg0, Throwable arg1) {
					System.err.println(arg0.getName() + " Thread with ID" + arg0.getId() 
							+ " received an uncaught exception of type " + arg1.getClass());
				} }
			);
			DT.start();
		} else System.err.println("Can only create one Dispatcher!");
	}
	
	private class DispatcherThread extends Thread{
		private static final int SLEEP_MILLIS = 10;
		
		public void run(){
			while (true){
				Commander.Dispatch();
				try{
					sleep(SLEEP_MILLIS);
				} catch(InterruptedException e){
					System.err.println("Dispatcher Thread could not sleep");
				}
			}
		}
	}
	//private class DispatcherUnhandledE
}
