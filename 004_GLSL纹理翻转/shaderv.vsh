attribute vec4 position;
attribute vec2 textCoordinate;
uniform mat4 rotateMatrix;

varying lowp vec2 varyTextCoord;

void main(){
    varyTextCoord = textCoordinate;
    
    //旋转矩阵翻转图形,不翻转纹理
//    vec4 vPos = position;
//    vPos = vPos * rotateMatrix;
//    gl_Position = vPos;
    
//    修改顶点着色器,纹理坐标 解决纹理导致(方法4)
//    varyTextCoord = vec2(textCoordinate.x,1.0-textCoordinate.y);

    gl_Position = position;
}


