package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.utils.Assets;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-$fileSuffix';
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if MODS_ALLOWED
		if (FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if (Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if (colorOfThisPixel != 0) {
				  if (countByColor.exists(colorOfThisPixel)) {
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  } else if (countByColor[colorOfThisPixel] != 13520687 - (2*13520687)) {
					countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.returnSound('sounds', sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.returnSound('music', sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function getDifficulties(?song:String = '', ?remove:Bool = false) {
		song = Paths.formatToSongPath(song);
		difficulties = defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if ((diffStr == null || diffStr.length == 0) && song.length > 0) {
			var num:Int = 0;
			for (i in WeekData.weeksLoaded.keys()) {
				var songs:Array<Dynamic> = WeekData.weeksLoaded.get(i).songs;
				for (daSong in songs) {
					var name:String = daSong[0];
					name.toLowerCase().trim();
					if (name == song) {
						PlayState.storyWeek = num;
						diffStr = WeekData.getCurrentWeek().difficulties;
						//trace('found difficulties');
						break;
					}
				}
				num++;
			}
		}
		if (diffStr == null || diffStr.length == 0) diffStr = 'Easy,Normal,Hard';
		diffStr = diffStr.trim(); //Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i = 0;
			var len = diffs.length;
			while (i < len)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1 || diffs[i] == null) diffs.remove(diffs[i]);
				}
				else
				{
					diffs.remove(diffs[i]);
				}
				i++;
			}
			
			if (remove && song.length > 0) {
				for (i in 0...diffs.length) {
					if (diffs[i] != null) {
						var suffix = '-${Paths.formatToSongPath(diffs[i])}';
						if (Paths.formatToSongPath(diffs[i]) == defaultDifficulty.toLowerCase()) {
							suffix = '';
						}
						var poop:String = song + suffix;
						#if MODS_ALLOWED
						if (!FileSystem.exists(Paths.modsData('$song/$poop')) && !Assets.exists(Paths.json('$song/$poop')))
						#else
						if (!Assets.exists(Paths.json('$song/$poop')))
						#end
						{
							diffs.remove(diffs[i]);
						}
					} else {
						diffs.remove(diffs[i]);
					}
				}
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				difficulties = diffs;
			}
		}
	}
}