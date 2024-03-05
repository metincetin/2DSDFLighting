package sdf_lighting.rendering;

import dreamengine.core.math.Mathf;
import dreamengine.core.Time;
import js.html.GetNotificationOptions;
import dreamengine.plugins.renderer_base.DefaultTextures;
import dreamengine.plugins.renderer_base.ShaderGlobals;
import dreamengine.device.Screen;
import kha.math.Random;
import kha.math.FastVector4;
import kha.graphics5_.*;
import dreamengine.core.math.Vector3;
import dreamengine.core.Renderer;
import dreamengine.core.RenderPass;

class DrawLight extends RenderPass{

    var lightPos  = new Array<Vector3>();
    var lightCol = new Array<kha.Color>();
    var lightColTarget = new Array<kha.Color>();

    var pipeline:PipelineState;

    var lightPosLocation= new Array<ConstantLocation>();
    var lightColorLocation= new Array<ConstantLocation>();
	var sdfLocation:TextureUnit;



    public function new(){
        super();
        pipeline = new PipelineState();

        pipeline.fragmentShader = kha.Shaders.draw_light_frag;
        pipeline.vertexShader = kha.Shaders.painter_image_vert;

        var struct = new VertexStructure();
        struct.add("vertexPosition", Float3);
        struct.add("vertexUV", Float2);
        pipeline.inputLayout = [struct];

        pipeline.compile();


        sdfLocation = pipeline.getTextureUnit("u_sdf");


        for(i in 0...10){

            var col = getRandomColor();
            lightCol.push(col);
            lightColTarget.push(col);
            lightPos.push(getRandomPosition());
            
            lightPosLocation.push(pipeline.getConstantLocation('u_lightPosition[${i}]'));
            lightColorLocation.push(pipeline.getConstantLocation('u_lightColor[${i}]'));
        }
    }

    override function execute(renderer:Renderer) {

        var cam = renderer.cameras[0];

        var rt = cam.renderTexture;
        var g2 = rt.g2;
        var g4 = rt.g4;

        g2.begin(false);
        g2.pipeline = pipeline;
        g4.setPipeline(pipeline);


        g4.setTexture(sdfLocation, ShaderGlobals.getTexture("u_sdf"));

        for(i in 0...10){
            g4.setVector3(lightPosLocation[i], lightPos[i]);
            lightCol[i] = Mathf.lerpColor(lightCol[i], lightColTarget[i], 8 * Time.getDeltaTime());
            var lightColor = lightCol[i];
            g4.setVector4(lightColorLocation[i], new FastVector4(lightColor.R, lightColor.G, lightColor.B, lightColor.A));

        }

        g2.drawScaledImage(DefaultTextures.getWhite(), 0,0, rt.width,rt.height);

        g2.end();
    }

    function getRandomPosition(){
        return new Vector3(Random.getFloat(), Random.getFloat(), 0);
    }

    function getRandomColor(){
        return kha.Color.fromFloats(Random.getFloat(),Random.getFloat(),Random.getFloat(), 1);
    }

    public function animateLights() {
		for(i in lightPos){
			i.add(Vector3.right() * Math.sin(Time.getTime()) * 0.005 * i);
		}
    }
    public function randomizeLightColors() {
		for(i in 0...lightCol.length){
            lightColTarget[i] = getRandomColor();
		}
    }

    public function reset(){
		for (i in 0...10) {
            var col = getRandomColor();
			lightCol[i] = col;
			lightColTarget[i] = col;

            lightPos[i] = getRandomPosition();
		}
    }
}