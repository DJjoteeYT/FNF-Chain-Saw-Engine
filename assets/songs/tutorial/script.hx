function camearaFollow(character:String)
{
	if (character == 'dad')
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
}

function beatHit(curBeat:Int)
{
	if (curBeat % 16 == 15 && PlayState.instance.dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
	{
		PlayState.instance.boyfriend.playAnim('hey', true);
		PlayState.instance.dad.playAnim('cheer', true);
	}
}
