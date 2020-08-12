precision highp float;

uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

const float mosaicSize = 0.03;
const float TW = 1.5;
const float TH = 0.866025;

void main(){
    
    float x = TextureCoordsVarying.x;
    float y = TextureCoordsVarying.y;
    
    int wx = int(x/mosaicSize/TW);
    int wy = int(y/mosaicSize/TH);
    
    vec2 v1, v2, vn;
    if ((wx + wy)/2 * 2 == (wx + wy)) {
        v1 = vec2(float(wx)*mosaicSize*TW, float(wy)*mosaicSize*TH);
        v2 = vec2(float(wx+1)*mosaicSize*TW, float(wy+1)*mosaicSize*TH);
    } else {
        v1 = vec2(float(wx+1)*mosaicSize*TW, float(wy)*mosaicSize*TH);
        v2 = vec2(float(wx)*mosaicSize*TW, float(wy+1)*mosaicSize*TH);
    }
    float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    if (s1 < s2) {
        vn = v1;
    } else {
        vn = v2;
    }
    
    
    
    vec4 color = texture2D(Texture, vn);
    
    gl_FragColor = color;
    
}
