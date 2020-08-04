precision highp float;
varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;

void main(){
   
    gl_FragColor = texture2D(colorMap, varyTextCoord);
    //修改片元着色器,纹理坐标 解决纹理导致(方法4)
//    gl_FragColor = texture2D(colorMap, vec2(varyTextCoord.x, 1.0-varyTextCoord.y));
}
