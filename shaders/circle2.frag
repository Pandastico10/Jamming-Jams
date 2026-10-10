// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime * 2.5;
    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;				// center coordinates
    vec2 uvRepeat = fract(uv * 4.) - 0.5;										// set repeating grid and center the circle (-0.5)
    float distanceOsc = 8. * distance(uv, uvRepeat);							// increase oscillation freq per distance
    float radius = 0.25 + 0.15 * sin(time + distanceOsc);						// use distance from center as oscillation offset
    float col = smoothstep(radius - radius * 0.1, radius, length(uvRepeat));	// smoothstep to antialias edge
    fragColor = vec4(vec3(col), texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}