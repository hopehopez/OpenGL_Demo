precision highp float;

uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

//时间戳
uniform float Time;

void main (void) {
    //时间周期
    float duration = 0.7;
    //透明度上限
    float maxAlpha = 0.4;
    //放大上限
    float maxScale = 1.8;
    
    //进度(0-1)
    float progress = mod(Time, duration)/duration;
    //透明度(0-4)
    float alpha = maxAlpha * (1.0 - progress);
    //缩放比例
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    //放大纹理坐标
    //将顶点坐标对应的纹理坐标的x值到纹理中点的距离,放大一定的比例. 这次我们是改变了纹理坐标, 而保持顶点坐标不变, 同样达到了拉伸的效果
    float weakX = 0.5 + (TextureCoordsVarying.x - 0.5) / scale;
    float weakY = 0.5 + (TextureCoordsVarying.y - 0.5) / scale;
    
    //得到放大的纹理坐标
    vec2 weakTextureCoords = vec2(weakX, weakY);
    
    //读取放大后的纹理坐标对应纹素的颜色值
    vec4 weakMask = texture2D(Texture, weakTextureCoords);
    
    //读取原始的纹理坐标对应纹素的颜色值
    vec4 mask = texture2D(Texture, TextureCoordsVarying);
    
    //在GLSL 实现颜色混合方程式. 默认颜色混合方程式 = mask * (1.0 - alpha) + weakMask *alpha
    //混合后的颜色 赋值给gl_FragColor
    gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;

}
