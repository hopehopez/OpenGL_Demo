precision highp float;

uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

const vec2 TexSize = vec2(400.0, 400.0);
const vec2 MosaicSize = vec2(10.0, 10.0);

void main(){
    
    vec2 intXY = vec2(TextureCoordsVarying.x*TexSize.x, TextureCoordsVarying.y*TexSize.y);
   
    vec2 XYMosaic = vec2(floor(intXY.x/MosaicSize.x)*MosaicSize.x, floor(intXY.y/MosaicSize.y)*MosaicSize.y);
    
    vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x, XYMosaic.y/TexSize.y);
     
    
      gl_FragColor = texture2D(Texture, UVMosaic);

}
