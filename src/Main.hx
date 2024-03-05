package;
import sdf_lighting.GamePlugin;
import dreamengine.core.Engine;
import kha.System;
class Main {
	public static function main() {
				
		Engine.start(function(engine){
			kha.Assets.loadEverything(function(){
				var game = new GamePlugin();
				engine.pluginContainer.addPlugin(game);
			});
		});
									
	}
}