/**
 * ...
 * @author Franco Ponticelli
 */

package thx.util;

import utest.Runner;
import utest.ui.Report;

class TestAll
{
	public static function addTests(runner : Runner)
	{
		TestTypeFactory.addTests(runner);
		TestTypeServiceLocator.addTests(runner);
	}
	
	public static function main()
	{
		var runner = new Runner();
		addTests(runner);
		Report.create(runner);
		runner.run();
	}
}