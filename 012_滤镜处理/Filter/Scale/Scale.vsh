//顶点坐标
attribute vec4 Position;
//纹理坐标
attribute vec2 TextureCoords;
//纹理坐标
varying vec2 TextureCoordsVarying;
//时间戳
uniform float Time;
//π
const float PI = 3.1415926;

void main (void) {
   
    //缩放的时间周期
    float duration = 0.6;
    //最大放大倍数
    float maxAmplitude = 0.3;
    
    //Time / duration * PI   当前时间相对多少个PI
    //abs(sin(Time / duration * PI) 计算sin 并取绝对值
    //maxAmplitude * abs(sin(Time / duration * PI)) 求得当前放大系数
    float amplitude = 1.0 + maxAmplitude * abs(sin(Time / duration * PI));
    
    //将顶点坐标的x y分别乘以放大系数, 在纹理坐标不变的情况下达到拉伸效果
    //xy放大 zw不变
    gl_Position = vec4(Position.x * amplitude, Position.y * amplitude, Position.zw);
    TextureCoordsVarying = TextureCoords;
}
