precistion highp float;

varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;

void main(){
    //1.拿到纹理对应坐标下纹素
    //纹理对象像素点颜色值 120*120
    //texture2D(纹理, 纹理坐标) 返回值 颜色值
    lbwp vec4 temp = texture2D(colorMap, varyTextCoord);
    
    
    //2.gl_FragColor
    //片元着色器执行代码  结果 
    gl_FragColor = temp;
    
}

