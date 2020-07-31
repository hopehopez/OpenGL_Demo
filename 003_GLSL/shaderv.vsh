
attribute vec4 positon;
attribute vec2 textCoordinate;
varying lowp vec2 varyTextCoord;

void main(){
    varyTextCoord = textCoordinate;
    //内建变量: gl_position 顶点着色器计算之后的 顶点结果
    gl_Position = position;
    
}

