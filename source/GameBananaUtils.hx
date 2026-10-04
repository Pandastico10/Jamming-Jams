package;

/**
 * GameBananaUtils - free to use GameBanana API helper for Codename Engine.
 *
 * Fetches member and mod info from GameBanana's Core and apiv11 endpoints.
 *
 * Setup:
 *   in global.hx, call init once inside function new():
 * 
 *	 import GameBananaUtils;
 * 
 *   function new() {
 *       GameBananaUtils.init(yourModId);
 *   }
 *
 * Then in any state or script:
 *   var mod = GameBananaUtils.requestGBMod(); // uses the id from init
 *   trace(mod.name + " by " + mod.owner);
 *
 * Finding your mod id: it's the number at the end of your mod page url,
 *   https://gamebanana.com/mods/YOUR_MOD_ID
 *
 * Note: all requests are synchronous, so run them on a loading screen or a separate thread if you don't want them blocking the menu.
 *
 * Codename Engine only (uses HttpUtil).
 * By HeroEyad - CNE dev and GameBanana moderator.
 */

import haxe.Json;
import haxe.io.Bytes;
import lime.graphics.Image;
import openfl.display.BitmapData;
import funkin.backend.utils.HttpUtil;
import funkin.backend.system.Logs;
import sys.FileSystem;
import sys.io.File;

class GameBananaUtils {
	static inline var avatarDir = ".cache/debugui/gamebanana/avatars";
	static inline var cacheRoot = ".cache/debugui";
	static inline var apiBase = "https://api.gamebanana.com/Core/Item/Data?itemtype=";

	/** Default mod id used when a mod function is called without one. */
	public static var modId:Int;

	/**
	 * Sets the tracked mod id and logs the init line, then fetches basic mod info.
	 * @param id Optional mod id to use as the default (set once, keeps the first value).
	 */
	public static function init(?id:Int) {
		modId ??= id;
		if (modId == null) {
			Logs.warn("[GameBananaUtils] No mod id set, call init(yourModId)");
			return;
		}
		if (!HttpUtil.hasInternet()) {
			Logs.warn("[GameBananaUtils] No internet connection, skipping GameBanana fetch.");
			return;
		}
		logColored("[GameBananaUtils]", "GameBanana Initialized! (mod " + modId + ")");

		var mod = requestGBMod(modId);
		if (mod != null) {
			logColored("[GameBananaUtils]", "Mod: " + mod.name + " by " + mod.owner);
		} else {
			Logs.warn("Couldn't fetch mod info for " + modId);
		}
	}

	/**
	 * Hits the Core Item/Data endpoint and returns the parsed field array.
	 * @param id The member or item id.
	 * @param fields Comma separated GameBanana field string.
	 * @param itemtype The Core itemtype (defaults to Member).
	 * @return The parsed array, or null on error / bad response.
	 */
	static function getData(id:Dynamic, fields:String, itemtype:String = "Member"):Array<Dynamic> {
		if (id == null) return null;
		var idStr = Std.string(id);
		if (idStr == "") return null;
		var res = HttpUtil.requestText(apiBase + itemtype + "&itemid=" + idStr + "&fields=" + fields);
		if (res == null || res == "") return null;
		try {
			var parsed = Json.parse(res);
			// api returns an object instead of an array when the request errors
			if (!Std.isOfType(parsed, Array)) {
				Logs.error("GB API error: " + res);
				return null;
			}
			return parsed;
		} catch (e:Dynamic) {
			Logs.error(e);
			return null;
		}
	}

	/**
	 * Downloads a member's avatar image as raw bytes.
	 * @param id The member id.
	 * @return The image bytes, or null if unavailable.
	 */
	static function getAvatarBytes(id:Dynamic):Bytes {
		var data = getData(id, "name,Url().sAvatarUrl()");
		if (data == null)
			return null;
		var url:String = data[1];
		if (url == null || url == "")
			return null;
		logColored("[GameBananaUtils]", "Fetching avatar for " + data[0]);
		return HttpUtil.requestBytes(url);
	}

	/**
	 * Loads a member's avatar as a BitmapData, falling back to the placeholder.
	 * @param id The member id.
	 * @return The avatar bitmap, or the noavatar placeholder on failure.
	 */
	public static function requestGBPngID(id:Dynamic = null):BitmapData {
		var bytes = getAvatarBytes(id);
		if (bytes != null && bytes.length > 0) {
			var img = Image.fromBytes(bytes);
			if (img != null)
				return BitmapData.fromImage(img);
		}
		Logs.error("Failed to load avatar for ID: " + id);
		return null;
	}

	/**
	 * Fetches a member's mantra (user title).
	 * @param id The member id.
	 * @return The mantra string, or empty on failure.
	 */
	public static function requestGBMantraID(id:Dynamic = null):String {
		var data = getData(id, "user_title,name");
		if (data != null && data[0] != null && data[0] != "") {
			logColored("[GameBananaUtils]", "Getting mantra for " + data[1]);
			return data[0];
		}
		return "";
	}

	/**
	 * Fetches a member's display name.
	 * @param id The member id.
	 * @return The name string, or empty on failure.
	 */
	public static function requestGBNameID(id:Dynamic = null):String {
		var data = getData(id, "name");
		if (data != null && data[0] != null && data[0] != "") {
			logColored("[GameBananaUtils]", "Getting name for " + data[0]);
			return data[0];
		}
		return "";
	}

	/**
	 * Fetches a member's full profile (name, mantra, avatar, profile url, join date).
	 * @param id The member id.
	 * @return An anonymous profile struct, or null on failure.
	 */
	public static function requestGBProfile(id:Dynamic = null):Dynamic {
		var data = getData(id, "name,user_title,Url().sAvatarUrl(),Url().sProfileUrl(),date");
		if (data == null) {
			Logs.error("Failed to load profile for ID: " + id);
			return null;
		}
		logColored("[GameBananaUtils]", "Getting profile for " + data[0]);
		return {
			name: data[0],
			mantra: data[1],
			avatarUrl: data[2],
			profileUrl: data[3],
			registered: Std.string(data[4])
		};
	}

	/**
	 * Fetches mod info from the apiv11 ProfilePage endpoint.
	 * Pulls name, version, stats and the submitter's uPic (falling back to their avatar).
	 * @param id The mod id (defaults to modId).
	 * @return An anonymous mod struct, or null on failure.
	 */
	public static function requestGBMod(id:Dynamic = null):Dynamic {
		id ??= modId;
		var res = HttpUtil.requestText("https://gamebanana.com/apiv11/Mod/" + Std.string(id) + "/ProfilePage");
		if (res == null || res == "") {
			Logs.error("Failed to load mod for ID: " + id);
			return null;
		}
		try {
			var data = Json.parse(res);
			var submitter = data._aSubmitter;
			var upic = "";
			if (submitter != null) {
				// not every member sets a upic, fall back to the avatar
				upic = submitter._sUpicUrl != null && submitter._sUpicUrl != "" ? submitter._sUpicUrl : submitter._sAvatarUrl;
			}
			return {
				name: data._sName,
				version: data._sVersion != null ? data._sVersion : "",
				likes: data._nLikeCount != null ? data._nLikeCount : 0,
				views: data._nViewCount != null ? data._nViewCount : 0,
				downloads: data._nDownloadCount != null ? data._nDownloadCount : 0,
				owner: submitter != null ? submitter._sName : "",
				ownerId: submitter != null ? submitter._idRow : null,
				ownerUpic: upic
			};
		} catch (e:Dynamic) {
			Logs.error(e);
			return null;
		}
	}

	/**
	 * Checks whether the live mod version differs from the installed one.
	 * @param installedVersion The version string the user currently has.
	 * @param id The mod id (defaults to modId).
	 * @return True if the online version differs from installed.
	 */
	public static function checkModUpdate(installedVersion:String, id:Dynamic = null):Bool {
		id ??= modId;
		var latest = requestGBModVersion(id);
		if (latest == "") {
			Logs.warn("Couldn't check update for mod ID: " + id);
			return false;
		}
		if (latest == installedVersion)
			return false;
		logColored("[GameBananaUtils]", "Update available for mod " + id + ": " + installedVersion + " -> " + latest);
		return true;
	}

	/**
	 * Fetches just the mod's current version from apiv11.
	 * @param id The mod id (defaults to modId).
	 * @return The version string, or empty on failure.
	 */
	public static function requestGBModVersion(id:Dynamic = null):String {
		id ??= modId;
		var res = HttpUtil.requestText("https://gamebanana.com/apiv11/Mod/" + Std.string(id) + "/ProfilePage");
		if (res == null || res == "")
			return "";
		try {
			var data = Json.parse(res);
			var v:String = data._sVersion;
			return v != null ? v : "";
		} catch (e:Dynamic) {
			Logs.error(e);
			return "";
		}
	}

	/**
	 * Downloads and caches a member's avatar to disk under the avatar cache dir.
	 * @param id The member id.
	 */
	public static function preCacheAvatarGB(id:Int) {
		if (!FileSystem.exists(avatarDir)) {
			FileSystem.createDirectory(avatarDir);
			logColored("[GameBananaUtils]", "Cache folder created.");
		}
		var bytes = getAvatarBytes(id);
		if (bytes != null && bytes.length > 0) {
			File.saveBytes(avatarDir + "/" + id + ".png", bytes);
			return;
		}
		Logs.error("Failed to precache avatar for ID: " + id);
	}

	/** Deletes the entire debugui cache directory and its contents. */
	public static function removeCache() {
		if (!FileSystem.exists(cacheRoot)) {
			Logs.warn("Cache directory does not exist: " + cacheRoot);
			return;
		}
		try {
			deleteRecursive(cacheRoot);
			logColored("[GameBananaUtils]", "Successfully deleted cache at: " + cacheRoot);
		} catch (e:Dynamic) {
			Logs.error("Failed to delete cache: " + e);
		}
	}

	/**
	 * Recursively deletes a file or directory and everything under it.
	 * @param path The path to remove.
	 */
	static function deleteRecursive(path:String) {
		if (FileSystem.isDirectory(path)) {
			for (item in FileSystem.readDirectory(path))
				deleteRecursive(path + "/" + item);
			FileSystem.deleteDirectory(path);
		} else {
			FileSystem.deleteFile(path);
		}
	}

	/**
	 * Logs a tagged, colored line. Tag defaults to bright yellow (CNE ConsoleColor 14).
	 * @param tag The bracketed tag shown first.
	 * @param text The message body.
	 * @param color Optional CNE ConsoleColor for the tag (defaults to yellow).
	 */
	static function logColored(tag:String, text:String, ?color:Int) {
		color ??= 14;
		Logs.traceColored([
			Logs.logText(tag, color),
			Logs.logText(" " + text)
		], 0);
	}
}