package drc.graphics;

import drc.backend.native.NativeTexture;
import drc.core.Context;
import drc.display.Graphic;
import drc.display.Profile;
import drc.data.Texture;
import drc.utils.Common;
import opengl.WebGL;
import drc.buffers.Float32Array;
import drc.utils.Resources;

class Canvas extends Graphic
{
	/** Publics. **/

	public var drawCalls:UInt = 0;

	/** Privates. **/

	private var __context:Context;

	var img:Image;

	public function new(profile:Profile) 
	{
		super(profile);
		
		__context = Common.context;

		textures = new Array<Texture>();

		textures[0] = new NativeTexture();

		textures[0].create(640, 480);

		vertices.upload(
		[
			64, 64, 0, 0, 0,
			64, 480, 0, 0, 1,
			640, 480, 0, 1, 1,
			640, 64, 0, 1, 0
		]);
		
		indices.upload([0, 1, 2, 0, 2, 3]);
		
		__verticesToRender = 4;
		
		__indicesToRender = 6;

		img = new Image(Resources.getProfile("res/profiles/default.json"));

		img.textures[0] = Resources.loadTexture('res/graphics/grid.png');

		uniform_MP = WebGL.getUniformLocation(profile.program.innerData, "uMatrix");
		uniform_MV = WebGL.getUniformLocation(profile.program.innerData, "modelview");
		uniform_TEX = WebGL.getUniformLocation(profile.program.innerData, "uImage0");
	}

	public function setToDraw():Void {
		
		__context.setRenderToTexture(textures[0]);

		renderToTexture = true;

		__context.setViewport(0, 0, textures[0].width, textures[0].height);

		projection = createOrthoMatrix(projection, 0, 640, 480, 0, 1000, -1000 );

		__context.clear(0, 1, 0, 1);
	}

	public function present():Void {

		//textures[0] = Resources.loadTexture('res/graphics/grid.png');

		//textures[0].create(640, 480);
		
		renderToTexture = false;

		__context.setViewport(0, 0, 640, 480);

		projection = createOrthoMatrix(projection, 0, 640, 480, 0, 1000, -1000 );

		__drawTriangles(this);
	}

	public function draw():Void {
		
		__drawTriangles(img);
	}

	var projection:Float32Array;
	var modelview:Float32Array;

	var uniform_MP:Int = 0;
	var uniform_MV:Int = 0;
	var uniform_TEX:Int = 0;

	var renderToTexture:Bool = false;

	private function __drawTriangles(img:Graphic):Void {
		
		__context.generateVertexBuffer();
		
		__context.loadVertexBuffer(img.vertices.innerData);
		
		__context.generateIndexBuffer();
		
		__context.loadIndexBuffer(img.indices.innerData);
		
		
		
		//__context.clear(0, 0, 0, 1);
		
		WebGL.enable(WebGL.DEPTH_TEST);
		
		
		
		modelview = create2DMatrix(modelview, 0, 0, 1, 0 );
		
		WebGL.useProgram(img.profile.program.innerData);
		
		WebGL.uniformMatrix4fv(uniform_MP, false, projection);
		WebGL.uniformMatrix4fv(uniform_MV, false, modelview);
		
		//WebGL.bindBuffer(WebGL.ARRAY_BUFFER, glBuffer);
		__context.generateVertexBuffer();
		
		//WebGL.vertexAttribPointer(aPosition, 3, WebGL.FLOAT, false, 0, 0);
		
		//__context.setAttributePointer(aPosition, 3, false, 0, 0);
		
		var offset:Int = 0;
		
		for (i in 0...profile.attributes.length) 
		{
			__context.setAttributePointer(profile.attributes[i].location, profile.attributes[i].format, false, 5 * Float32Array.BYTES_PER_ELEMENT, offset * Float32Array.BYTES_PER_ELEMENT);
			
			offset += profile.attributes[i].format;
		}

		//var glTexture = WebGL.createTexture();

		//__context.generateTexture();

		//__context.loadTextureUniform(uniform_TEX, img.textures[0]);

		//WebGL.bindTexture(WebGL.TEXTURE_2D, glTexture);

		//WebGL.uniform1i(uniform_TEX, 0);

		WebGL.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
		WebGL.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);

		WebGL.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
		WebGL.enable(WebGL.BLEND);

		//Webgl.texImage2D (Webgl.TEXTURE_2D, 0, __context.gl.RGBA, __context.gl.RGBA, __context.gl.UNSIGNED_BYTE, image.src);

		//WebGL.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, img.textures[0].width, img.textures[0].height, 0, WebGL.RGBA, WebGL.UNSIGNED_BYTE, Uint8Array.fromBytes(Bytes.ofData(img.textures[0].bytes)));

		WebGL.bindTexture(WebGL.TEXTURE_2D, img.textures[0].glTexture);

		WebGL.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
		WebGL.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);

		WebGL.activeTexture(WebGL.TEXTURE0);

		WebGL.enable(WebGL.TEXTURE_2D);

		//__context.gl.bindTexture (__context.gl.TEXTURE_2D, null);

		//__context.setUniform(profile.uniforms[0], projection);
		//__context.setUniform(profile.uniforms[1], projection);
		
		//WebGL.drawArrays(WebGL.TRIANGLES, 0, 3);
		
		__context.generateIndexBuffer();
		
		//__context.drawArrays(0, img.__verticesToRender);
		
		if (renderToTexture) {

			__context.bindFrameBuffer();
		}

		__context.drawElements(0, img.__indicesToRender);

		WebGL.bindTexture(WebGL.TEXTURE_2D, null);
	}

	function createOrthoMatrix( ?into:Float32Array, x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float ) : Float32Array {

        var i = into;
        if(i == null) i = new Float32Array(16);

        var sx = 1.0 / (x1 - x0);
        var sy = 1.0 / (y1 - y0);
        var sz = 1.0 / (zFar - zNear);

            i[ 0] = 2.0*sx;        i[ 1] = 0;            i[ 2] = 0;                 i[ 3] = 0;
            i[ 4] = 0;             i[ 5] = 2.0*sy;       i[ 6] = 0;                 i[ 7] = 0;
            i[ 8] = 0;             i[ 9] = 0;            i[10] = -2.0*sz;           i[11] = 0;
            i[12] = -(x0+x1)*sx;   i[13] = -(y0+y1)*sy;  i[14] = -(zNear+zFar)*sz;  i[15] = 1;

        return i;

    } //createOrthoMatrix
	
	function create2DMatrix( ?into:Float32Array, x:Float, y:Float, scale:Float = 1, rotation:Float = 0 ) {

        var i = into;
        if(i == null) i = new Float32Array(16);

        var theta = rotation * Math.PI / 180.0;
        var c = Math.cos(theta);
        var s = Math.sin(theta);

            i[ 0] = c*scale;  i[ 1] = -s*scale;  i[ 2] = 0;      i[ 3] = 0;
            i[ 4] = s*scale;  i[ 5] = c*scale;   i[ 6] = 0;      i[ 7] = 0;
            i[ 8] = 0;        i[ 9] = 0;         i[10] = 1;      i[11] = 0;
            i[ 12] = x;       i[13] = y;         i[14] = 0;      i[15] = 1;

        return i;

    } //create2DMatrix
}