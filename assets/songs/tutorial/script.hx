function beatHit(curBeat:Int)
{
	if (curBeat % 16 == 15 && PlayState.dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
	{
		PlayState.instance.boyfriend.playAnim('hey', true);
		PlayState.instance.dad.playAnim('cheer', true);
	}
}
