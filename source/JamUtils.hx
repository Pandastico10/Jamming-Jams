package source;
import haxe.io.Path;

class JamUtils {
	public function getList():Array<String> {
		var list:Array<String> = [];

		for (path in Paths.getFolderContent("data/levels/", false)) {
			var extension = Path.extension(path);

			if (extension == "xml" && path != "current.xml")
				list.push(Path.withoutExtension(path));
		}

		return list;
	}
}
