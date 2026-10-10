// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define PI     3.14159265358
#define TWO_PI 6.28318530718

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // set time & centered position
    float time = iTime * 2.5;
    vec2 uv = (2. * fragCoord.xy - iResolution.xy) / iResolution.y;
    // deform uv - spin a little
    float dist = length(uv);
    float rot = 0.03 * sin(dist * 3. + time);							// oscillate rotation
    uv *= mat2(cos(rot), sin(rot), -sin(rot), cos(rot));				// rotate
    // find position on circle
    float rads = PI + atan(uv.x, uv.y);
    float segments = 32.;
    float segmentRads = segments / TWO_PI;
    float segmentIndex = floor((rads/TWO_PI) * segments);
    // color
    float scroll = (mod(segmentIndex, 2.) == 0.) ? time : -time;		// reverse direction on odd segments
    float col = abs(sin(29. * pow(0.75 + length(uv), 1.8) + scroll));	// concentric lines width - progressively smaller
    col = smoothstep(0.4, 0.53, col);									// tighten up line definition
    if(scroll > 0.) col = 1. - col;										// invert colors on odd segments
	col -= (2.0 - length(uv)) * 0.5;									// reverse vignette
    fragColor = vec4(vec3(col), texture(iChannel0, fragCoord / iResolution.xy).a);
}



void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}