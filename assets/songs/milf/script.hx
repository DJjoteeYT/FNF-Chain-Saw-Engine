function update(elapsed:Float)
{
	FlxG.camera.zoom = FlxMath.lerp(PlayState.instance.defaultCamZoom, FlxG.camera.zoom, 0.95);
	PlayState.instance.camHUD.zoom = FlxMath.lerp(1, PlayState.instance.camHUD.zoom, 0.95);
}

function beatHit(curBeat:Int)
{
	if (curBeat >= 168 && curBeat < 200 && FlxG.camera.zoom < 1.35)
	{
		FlxG.camera.zoom += 0.015;
		PlayState.instance.camHUD.zoom += 0.03;
	}
}
