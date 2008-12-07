/**
 * Command.java
 */
package robomagellan.backend.command;

/**
 * All commands in Robomagellan must implement the Command interface so
 * priority handling may be kept.
 * @author tonyfwu
 *
 */
public interface Command {
	
	/**
	 * This is the default priority level of a command.
	 */
	public static final int DEFAULT_PRIORITY = 15;
	/**
	 * This method should return the priority level of the command. The lower the
	 * number, the higher the priority.
	 * @return the priority of the command.
	 */
	public int getPriority();
	/**
	 * This method is run by the Commander class when executing the command.
	 */
	public void send();
}
