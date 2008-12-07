/**
 * ComparableCommand.java
 */
package robomagellan.backend.command;

/**
 * This class is a wrapper class for the Command class. It allows the
 * priority queue to compare the commands by priority.
 * 
 * @author tonyfwu
 *
 * @see Command
 */
@SuppressWarnings("unchecked")
public class ComparableCommand implements Comparable{
	
	private Command cmd;
	/**
	 * Creates an instance of ComparableCommand.
	 * @param c the Command object to wrap around.
	 */
	public ComparableCommand(Command c){
		cmd = c;
	}
	/**
	 * Returns the command.
	 * @return returns the command that this wraps
	 */
	public Command getCommand()
	{
		return cmd;
	}
	/**
	 * This method compares the commands by priority.
	 * 
	 * @return an Integer, either -1, 0, or 1 (Less than, Equal, or Greater than, respectively.
	 */
	@Override
	public int compareTo(Object arg0) {
		return Integer.signum(
				cmd.getPriority() - ((ComparableCommand)arg0).getCommand().getPriority()
				);
	}
	
}
