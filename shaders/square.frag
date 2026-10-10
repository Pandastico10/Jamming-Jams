// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

#define audio 0.

vec2 rotateCoord(vec2 uv, float rads) {
    return uv * mat2(cos(rads), sin(rads), -sin(rads), cos(rads));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 10. * (2. * fragCoord - iResolution.xy) / iResolution.y;
    uv = rotateCoord(uv, length(uv) * 0.11 * sin(iTime * 0.5));
    float lines = (audio == 1.) ? 5. + texture( iChannel0, vec2(0.4, 0.2) ).r * 10. : 10.;
    float col = 0.5 + 0.5 * sin(max(abs(uv.x), abs(uv.y)) * lines + iTime * 5.);
    float aa = 100. / iResolution.y;
    fragColor = vec4(vec3(smoothstep(0.5 - aa, 0.5 + aa, col)), texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}