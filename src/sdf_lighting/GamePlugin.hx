package sdf_lighting;
import haxe.io.Input;
import dreamengine.plugins.input.devices.BaseKeyboard.KeyboardKey;
import kha.input.Keyboard;
import dreamengine.plugins.input.IInputHandler;
import dreamengine.plugins.dreamui.DreamUIPlugin;
import haxe.Timer;
import kha.System;
import kha.math.Random;
import kha.Color;
import dreamengine.core.math.Rect;
import dreamengine.plugins.renderer_base.ShaderGlobals;
import dreamengine.plugins.imgui.IMGUI;
import dreamengine.plugins.imgui.IMGUIRenderPass;
import dreamengine.plugins.imgui.IMGUIPlugin;
import sdf_lighting.rendering.DrawSDF;
import dreamengine.core.math.Vector3;
import dreamengine.core.math.Quaternion;
import dreamengine.plugins.renderer_base.components.Transform;
import dreamengine.plugins.renderer_base.components.Camera;
import dreamengine.plugins.renderer_2d.Renderer2D;
import dreamengine.plugins.input.InputPlugin;
import dreamengine.plugins.renderer_3d.Renderer3D;
import dreamengine.plugins.ecs.ECS;
import sdf_lighting.rendering.DrawLight;
import dreamengine.core.*;
import dreamengine.core.Plugin.IPlugin;

class GamePlugin extends Game {
	var inputHandler:IInputHandler;

	var drawLightPass:DrawLight;
	var drawSDFPass:DrawSDF;

	override function beginGame() {
				
		// Called when game starts and all plugins loaded. You can access the engine via "engine" variable
		
		Random.init(Std.int(Date.now().getTime()));
		// register tick (update) event
		engine.registerLoopEvent(onTick);

		drawLightPass = new DrawLight();
		drawSDFPass = new DrawSDF();

		engine.getRenderer().pipeline.unshift(drawLightPass);
		engine.getRenderer().pipeline.unshift(drawSDFPass);


		var ecs = engine.pluginContainer.getPlugin(ECS);
		inputHandler = engine.pluginContainer.getPlugin(InputPlugin).getInputHandler();

		ecs.spawn([
			Camera.orthogonal(5, [0.01, 100]),
			Transform.prs([0,0,0], Quaternion.identity(), Vector3.one())
		]);


									
	}

	function onTick() {
		// Called every frame
		renderGUI();
		handleInput();

	}

	function handleInput(){
		var keyboard = inputHandler.getKeyboard(0);

		if (keyboard.isKeyPressed(C)){
			drawLightPass.animateLights();
		}
		if (keyboard.isKeyPressed(O)){
			drawSDFPass.animateOccluders();
		}
		if (keyboard.isKeyJustPressed(L)){
			drawLightPass.randomizeLightColors();
		}

		if (keyboard.isKeyJustPressed(R)){
			drawLightPass.reset();
			drawSDFPass.reset();
		}
	}

	function renderGUI(){
		if (inputHandler.getKeyboard(0).isKeyPressed(H)) return;
		IMGUI.fontSize = 16;
		var sdfBuffer = ShaderGlobals.getTexture("u_sdf");
		IMGUI.text(Rect.create(0,0,0,0), "Occluder SDF");
		IMGUI.image(Rect.create(0,16,100 * (sdfBuffer.width / sdfBuffer.height),100), sdfBuffer);

		IMGUI.fontSize = 24;
		IMGUI.text(Rect.create(0,116,0,0), "\"C\" to animate lights");
		IMGUI.text(Rect.create(0,144,0,0), "\"L\" to animate light colors");
		IMGUI.text(Rect.create(0,172,0,0), "\"O\" to animate occluders");
		IMGUI.text(Rect.create(0,200,0,0), "\"R\" to reset the scene");
		IMGUI.text(Rect.create(0,228,0,0), "\"H\" to hide UI");
	}

	override function endGame() {
				
		// Called when game is finalized
		
		// unregister loop event
		engine.unregisterLoopEvent(onTick);
	}

	override function getDependentPlugins():Array<Class<IPlugin>> {
				
		// You can specify what plugins this game plugin needs in order to work.
		// e.g. to use Renderer3D, DreamUI and input. use: return [Renderer3D, DreamUIPlugin, InputPlugin];
		return [ECS, Renderer2D, IMGUIPlugin, InputPlugin];
	}

	override function handleDependency(ofType:Class<IPlugin>):IPlugin {
				
		// This is where you "create" the dependencies. Each plugin you passed on getDependentPlugins, should be instantiated in here
		// for example:
		switch(ofType){
			case ECS:
				return new ECS();
			case Renderer2D:
				return new Renderer2D();
			case InputPlugin:
				return new InputPlugin();
			case IMGUIPlugin:
				return new IMGUIPlugin();
		}
		return null;
									
	}
}