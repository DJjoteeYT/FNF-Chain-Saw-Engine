function beatHit(curBeat:Int)
{
	switch (curBeat)
	{
		case 128, 129, 130:
			PlayState.instance.vocals.volume = 0;
	}

	if (curBeat % 8 == 7)
		PlayState.boyfriend.playAnim('hey', true);
}