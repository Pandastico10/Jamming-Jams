
import flixel.effects.FlxFlicker;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;

class Flashlight {
    public var isOn:Bool = false;
    public var flash1:FlxSprite;
    public var flash0:FlxSprite;

    public var sprites:FlxGroup;
    public var flashSprites:FlxGroup;

    var bar:FlxBar;
    var border:FlxSprite;

    public var batteryTimer:Float = 0;
    public var maxBattery:Float = 0;
    public var rechargeTime:Int = 6;
    public var isRecharging:Bool = false;

    public function new(leftAi:Int, rightAi:Int, backAi:Int, upAi:Int) {
        maxBattery = 5 - (7 / 80) * ((leftAi + rightAi + backAi + upAi)/2);
        batteryTimer = maxBattery;

        sprites = new FlxGroup();
        flashSprites = new FlxGroup();

        var barX = FlxG.width - 45;
        var barY = (FlxG.height - 600) / 2;

        border = new FlxSprite(barX - 2, barY - 2);
        border.makeGraphic(29, 604, 0xFF000000);

        bar = new FlxBar(barX, barY, FlxBarFillDirection.BOTTOM_TO_TOP, 25, 600, null, null, 0, maxBattery);
        bar.createFilledBar(0xFF000000, 0xFFFFFFFF);

        sprites.add(border);
        sprites.add(bar);

        flash1 = new FlxSprite().loadGraphic(Paths.image("game/flash1"));
        flash1.setGraphicSize(Std.int(FlxG.width * 7.5), Std.int(FlxG.height * 6));
        flash1.updateHitbox();
        flash1.alpha = 0.8;

        flash0 = new FlxSprite().loadGraphic(Paths.image("game/flash0"));
        flash0.setGraphicSize(Std.int(FlxG.width * 7.5), Std.int(FlxG.height * 6));
        flash0.updateHitbox();
        flash0.alpha = 0.8;

        flashSprites.add(flash0);
        flashSprites.add(flash1);
    }

    public function update(elapsed:Float, input:Bool, mouseX:Float, mouseY:Float) {
        isOn = input && !isRecharging && batteryTimer > 0;

        for (flash in [flash0, flash1]) {
            flash.x = mouseX - flash.width / 2;
            flash.y = mouseY - flash.height / 2;
        }

        flash1.visible = isOn;
        flash0.visible = !isOn;

        if (!isRecharging) {
            if (isOn)
                batteryTimer -= elapsed;
            else
                batteryTimer += elapsed / 4;

            batteryTimer = FlxMath.bound(batteryTimer, 0, maxBattery);

            if (batteryTimer <= 0) {
                batteryTimer = 0;
                isOn = false;
                flash1.visible = false;
                flash0.visible = true;
                isRecharging = true;

                FlxG.sound.play(Paths.sound("sfxFlashDie"));
                FlxFlicker.flicker(bar, rechargeTime, 0.125, true);

                FlxTween.num(0, maxBattery / 2, rechargeTime, {
                    onComplete: function(tween:FlxTween) {
                        batteryTimer = maxBattery / 2;
                        isRecharging = false;
                    }
                }, function(value:Float) {
                    batteryTimer = value;
                });
            }
        }

        bar.value = batteryTimer;
    }
}
