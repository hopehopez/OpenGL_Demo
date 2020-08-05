attribute vec4 position;
attribute vec4 positionColor;
attribute vec2 textCoor;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec4 varyColor;
varying lowp vec2 vTextCoor;
void main() {
    varyColor = positionColor;
    vTextCoor = textCoor;
    
    vec4 vPos;
    //4*4 * 4*4 * 4*1
    vPos = projectionMatrix * modelViewMatrix * position;
    
    gl_Position = vPos;
}
 

