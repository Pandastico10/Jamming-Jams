// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

// #define FADES  1

// 2D Random
float random (in vec2 st) { 
    return fract(sin(dot(st.xy,vec2(12.9898,78.233))) * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f*f*(3.0-2.0*f);
    return mix(a, b, u.x) + 
            (c - a)* u.y * (1.0 - u.x) + 
            (d - b) * u.x * u.y;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime * 0.1;									// adjust time
    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;	// center coordinates
    float rowThickness = uv.y * 20.;								// break y lines up
    float rowIndex = floor(rowThickness);							// break y lines up & get current index
    float lineProgress = rowThickness - rowIndex;					// get line progress 0-1
    float dashLength = noise(vec2(time + rowIndex * 4., 1.)); 		// each line gets a random dash length
    uv *= vec2(dashLength * 7., 1.);								// calc dash lengths by multiplying x
    float timeAdd = (mod(rowIndex, 2.) == 0.) ? time : -time;		// move x in different directions
    timeAdd *= 5.1;													// increase x movement
    float xOffset = rowIndex / 3.;									// give lines x offset so they don't line up
    uv += vec2(timeAdd + dashLength + xOffset, 0.);					// move x position
    float col = 0.;													// default black
    if(fract(uv.x) > 0.5) {											// dash    
        col = ceil(0.15 - distance(0.5, lineProgress));				// only draw middle portion of line
    }
    // fade in/out
    #ifdef FADES
        float loopSecs = 2.;
        float fadeTime = 1.;
        if(abs(mod(time, loopSecs)) < fadeTime * 2.) {				// fade in/out for looping purposes
            col = mix(0., col, abs(-fadeTime + mod(time, loopSecs)));	
        }
    #endif
	fragColor = vec4(vec3(col), texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}