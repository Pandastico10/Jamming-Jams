//really tried to use FunkinSave but i havent slept in like
//18 hours and im really sleepy like hella


class DeathCounter {
    public static function load(level:String):Int {
        var value:Dynamic = Reflect.field(FlxG.save.data, level);

        if (value == null) {
            Reflect.setField(FlxG.save.data, level, 0);
            FlxG.save.flush();
            return 0;
        }

        return Std.int(value);
    }

    public static function add(level:String):Int {
        var value:Int = load(level);
        value++;

        Reflect.setField(FlxG.save.data, level, value);
        FlxG.save.flush();

        return value;
    }

    public static function loadBestTime(level:String):Float {
        var value:Dynamic = Reflect.field(FlxG.save.data, level + "_bestTime");

        if (value == null)
            return 0;

        return value;
    }

    public static function saveBestTime(level:String, time:Float):Bool {
        var previous:Dynamic = Reflect.field(FlxG.save.data, level + "_bestTime");

        if (previous == null || time < previous) {
            Reflect.setField(FlxG.save.data, level + "_bestTime", time);
            FlxG.save.flush();
        }
    }

    public static function reset(level:String) {
        Reflect.setField(FlxG.save.data, level, 0);
        FlxG.save.flush();
    }
}