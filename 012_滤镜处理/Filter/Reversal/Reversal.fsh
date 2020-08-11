precision highp float;
uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

void main(){
      gl_FragColor = texture2D(Texture, vec2(TextureCoordsVarying.x, 1.0-TextureCoordsVarying.y));

}
