precision highp float;

uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

const vec2 TexSize = vec2(400.0, 400.0);
const vec2 MosaicSize = vec2(10.0, 10.0);

void main(){
    //1.计算实际纹理的像素点的位置
    vec2 intXY = vec2(TextureCoordsVarying.x*TexSize.x, TextureCoordsVarying.y*TexSize.y);
    //2.floor(x) 返回小于或等于x的最大整数
    //floor(intXY.x/MosaicSize.x) 如果x小于16 floor(intXY.x/MosaicSize.x) 一直为0 也就是 这时一直取的都是(0.0)点上像素的颜色值
    vec2 XYMosaic = vec2(floor(intXY.x/MosaicSize.x)*MosaicSize.x, floor(intXY.y/MosaicSize.y)*MosaicSize.y);
    //3. 换算纹理坐标 (0,1.0);
    vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x, XYMosaic.y/TexSize.y);
     
    
      gl_FragColor = texture2D(Texture, UVMosaic);

}
