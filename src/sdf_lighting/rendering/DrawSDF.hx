package sdf_lighting.rendering;

import dreamengine.core.Time;
import dreamengine.plugins.dreamui.containers.ScreenContainer;
import js.html.NodeIterator;
import kha.System;
import js.html.ScreenOrientation;
import dreamengine.plugins.renderer_base.DefaultTextures;
import js.html.Animation;
import kha.Scaler;
import dreamengine.plugins.renderer_base.ShaderGlobals;
import kha.Image;
import dreamengine.device.Screen;
import kha.math.Random;
import kha.math.FastVector4;
import kha.graphics5_.*;
import dreamengine.core.math.Vector3;
import dreamengine.core.Renderer;
import dreamengine.core.RenderPass;

class DrawSDF extends RenderPass {
	var pipeline:PipelineState;

	var renderTarget:Image;
	var intermediate:Image;

	var occluderPos = new Array<Vector3>();
	var radiusLocation:ConstantLocation;
	var positionLocation = new Array<ConstantLocation>();

	public function new() {
		super();
		pipeline = new PipelineState();

		var res = Screen.getResolution();
		renderTarget = Image.createRenderTarget(res.x, res.y, TextureFormat.RGBA64);
		intermediate = Image.createRenderTarget(res.x, res.y, TextureFormat.RGBA64);

		pipeline.fragmentShader = kha.Shaders.draw_sdf_frag;
		pipeline.vertexShader = kha.Shaders.painter_image_vert;

		var struct = new VertexStructure();
		struct.add("vertexPosition", Float3);
		struct.add("vertexUV", Float2);
		pipeline.inputLayout = [struct];

		pipeline.compile();

		ShaderGlobals.setTexture("u_sdf", renderTarget);
		radiusLocation = pipeline.getConstantLocation("u_radius");

		for (i in 0...10) {
			occluderPos.push(getRandomPosition());
            positionLocation.push(pipeline.getConstantLocation('u_position[${i}]'));
		}
	}

	override function execute(renderer:Renderer) {
		var res = Screen.getResolution();

        renderTarget.g2.begin(false);
        renderTarget.g2.pipeline = pipeline;
        renderTarget.g4.setPipeline(pipeline);
        renderTarget.g2.drawScaledImage(DefaultTextures.getWhite(), 0, 0, res.x, res.y);

		for (i in 0...10) {
            var p = occluderPos[i];
            renderTarget.g4.setFloat2(positionLocation[i], p.x, p.y);
		}
        renderTarget.g4.setFloat(radiusLocation, 0.05);

        renderTarget.g2.end();

	}

	public function animateOccluders() {
		for(i in occluderPos){
			i.add(Vector3.up() * Math.sin(Time.getTime()) * 0.005 * i);
		}
	}

	function getRandomPosition(){
		return new Vector3(Random.getFloat(), Random.getFloat(),0);
	}

	public function reset() {
		for (i in 0...10) {
			occluderPos[i]=getRandomPosition();
		}
	}
}
