var irisSpr:FlxSprite;
var irisDone:Bool = false;

function create(e)
{
	e.cancelled = true;
	irisDone = false;
	allowSkip = false;

	irisSpr = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
	irisSpr.scrollFactor.set(0, 0);
	irisSpr.shader = new FunkinShader("
		#pragma header

		uniform float uRadius;

		void main() {
			vec2 d = openfl_TextureCoordv - vec2(0.5);
			d.x *= openfl_TextureSize.x / openfl_TextureSize.y;
			gl_FragColor = vec4(vec3(0.0), step(uRadius, length(d)));
		}
	");
	if (transitionCamera != null)
		irisSpr.cameras = [transitionCamera];
	add(irisSpr);

	var startR:Float = e.transOut ? 1.3 : 0.0;
	var endR:Float = e.transOut ? 0.0 : 1.3;

	irisSpr.shader.uRadius = startR;
	FlxTween.num(startR, endR, 0.55, {ease: FlxEase.quadInOut}, function(num)
	{
		if (irisSpr != null && irisSpr.shader != null)
			irisSpr.shader.uRadius = num;
	});

	new FlxTimer().start(0.6, function(tmr:FlxTimer)
	{
		if (!irisDone)
		{
			irisDone = true;
			finish();
		}
	});
}
