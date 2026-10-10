// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define linesRows 10.0
#define thickness 0.25
#define invert 0

vec2 rotateCoord(vec2 uv, float rads) {
    uv *= mat2(cos(rads), sin(rads), -sin(rads), cos(rads));
	return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // update layout params
    float rows = linesRows * 0.5;//linesRows + 3. * sin(iTime);
    float curThickness = 0.25 + 0.22 * cos(iTime);
  	float curRotation = 0.8 * sin(iTime);
    // get original coordinate, translate & rotate
	vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;
    //uv += curCenter;
    uv = rotateCoord(uv, curRotation);
    // create grid coords
    vec2 uvRepeat = fract(uv * rows);		
    // adaptive antialiasing, draw, invert
    float aa = iResolution.y * 0.00003; 	
    float col = smoothstep(curThickness - aa, curThickness + aa, length(uvRepeat.y - 0.5));
    if(invert == 1) col = 1. - col;			
	fragColor = vec4(vec3(col), texture(iChannel0, fragCoord / iResolution.xy).a);
}


void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}