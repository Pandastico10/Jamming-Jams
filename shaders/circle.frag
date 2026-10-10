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
    float time = iTime * 1.;									// adjust time
    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;	// center coordinates
    float radsPercent = atan(uv.x, uv.y) / TWO_PI;           		// get angle to center
    float dist = length(uv) * 5.; // distance(uv, center);   		// multiply radius to achieve smaller rings
    float ringSegments = 1. + floor(dist * 4.);				 		// number of ring segments depends on radius
    if(mod(ringSegments, 2.) == 0.) time = -time;            		// reverse time for even-numbered rings
    time *= ringSegments * 0.2;                              		// increase time/spin moving out from center
    time = 0.02 * sin(time);								 		// remap time into an oscillation
    float ringRadsOffset = 0.; // 6. * sin(ringSegments);    		// possible unique offset per ring
    radsPercent = mod(time + radsPercent + ringRadsOffset, 1.); 	// rotate individual rings
    if(mod(ringSegments, 2.) == 1.) ringSegments++; 				// make sure we have even number of segments
    float segment = radsPercent * ringSegments;						// progress around circle
    float segmentNumber = floor(segment);							// iterate over ring segments - get segment number
    float colFade = pow(fract(segment), 10.);						// go from black to white on a curve at the end
    vec3 col = vec3(colFade);										// default to black
    if(mod(segmentNumber, 2.) == 0.) col = vec3(1. - colFade);		// color every other segment white
    fragColor = vec4(col, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}