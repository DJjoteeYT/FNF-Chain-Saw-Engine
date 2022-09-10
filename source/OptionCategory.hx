package;

import Options;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
		return _options;

	public final function addOption(opt:Option)
		_options.push(opt);

	public final function removeOption(opt:Option)
		_options.remove(opt);

	private var _name:String = "New Category";

	public final function getName()
		return _name;

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}
