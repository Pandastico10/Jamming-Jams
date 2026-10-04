
/*
 * Makes 6 2D sprites behave as the walls of a 3D cube.
 *
 * Uniforms:
 *   yaw   = horizontal camera rotation
 *   pitch = vertical camera rotation
 *   side  = which cube face this sprite represents
 *   cameraX  = camera position on X
 *   cameraY  = camera position on Y
 *   cameraZ  = camera position on Z
 *
 * Side values:
 *   0 = Front / Middle
 *   1 = Left
 *   2 = Back
 *   3 = Right
 *   4 = Top
 *   5 = Bottom
 *
 * Camera position:
 *   X/Y/Z are relative to the center of the cube.
 *   The cube extends from -1 to 1 on each axis.
 *
 * Example:
 *   shader.data.cameraX.value = [cameraX];
 *   shader.data.cameraY.value = [cameraY];
 *   shader.data.cameraZ.value = [cameraZ];
 *   shader.data.yaw.value = [yaw];
 *   shader.data.pitch.value = [pitch];
 *   shader.data.side.value = [0];
 */
 #pragma header

uniform float yaw;
uniform float pitch;
uniform float side; // mid 0, left 1, back 2, right 3, top 4, bottom 5
 
uniform float cameraX;
uniform float cameraY;
uniform float cameraZ;

const float PI = 3.14159265;

void main()
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 p = uv * 2.0 - 1.0;

    float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
    p.x *= aspect;

    float fov = 0.5;

    vec3 ro = vec3(cameraX, cameraY, cameraZ);
    vec3 rd = normalize(vec3(p, fov));

    float cp = cos(pitch);
    float sp = sin(pitch);

    mat3 pitchRot = mat3(
        1.0, 0.0,  0.0,
        0.0, cp,  -sp,
        0.0, sp,   cp
    );

    rd = pitchRot * rd;

    float cy = cos(yaw);
    float sy = sin(yaw);

    mat3 yawRot = mat3(
         cy, 0.0, -sy,
        0.0, 1.0,  0.0,
         sy, 0.0,  cy
    );

    rd = yawRot * rd;

    float t;
    vec3 hit;

    if (side < 0.5)
    {
        if (rd.z <= 0.0)
            discard;

        t = (1.0 - ro.z) / rd.z;
        hit = ro + rd * t;

        if (hit.x < -1.0 || hit.x > 1.0 ||
            hit.y < -1.0 || hit.y > 1.0)
            discard;

        vec2 uv2 = vec2(
            (hit.x + 1.0) * 0.5,
            (hit.y + 1.0) * 0.5
        );

        gl_FragColor = texture2D(bitmap, uv2);
    }
    else if (side < 1.5)
    {
        if (rd.x >= 0.0)
            discard;

        t = (-1.0 - ro.x) / rd.x;
        hit = ro + rd * t;

        if (hit.z < -1.0 || hit.z > 1.0 ||
            hit.y < -1.0 || hit.y > 1.0)
            discard;

        vec2 uv2 = vec2(
            (hit.z + 1.0) * 0.5,
            (hit.y + 1.0) * 0.5
        );

        gl_FragColor = texture2D(bitmap, uv2);
    }
    else if (side < 2.5)
    {
        if (rd.z >= 0.0)
            discard;

        t = (-1.0 - ro.z) / rd.z;
        hit = ro + rd * t;

        if (hit.x < -1.0 || hit.x > 1.0 ||
            hit.y < -1.0 || hit.y > 1.0)
            discard;

        vec2 uv2 = vec2(
            1.0 - (hit.x + 1.0) * 0.5,
            (hit.y + 1.0) * 0.5
        );

        gl_FragColor = texture2D(bitmap, uv2);
    }
    else if (side < 3.5)
    {
        if (rd.x <= 0.0)
            discard;

        t = (1.0 - ro.x) / rd.x;
        hit = ro + rd * t;

        if (hit.z < -1.0 || hit.z > 1.0 ||
            hit.y < -1.0 || hit.y > 1.0)
            discard;

        vec2 uv2 = vec2(
            1.0 - (hit.z + 1.0) * 0.5,
            (hit.y + 1.0) * 0.5
        );

        gl_FragColor = texture2D(bitmap, uv2);
    }
    else if (side < 4.5)
    {
        if (rd.y >= 0.0)
            discard;

        t = (-1.0 - ro.y) / rd.y;
        hit = ro + rd * t;

        if (hit.x < -1.0 || hit.x > 1.0 ||
            hit.z < -1.0 || hit.z > 1.0)
            discard;

        vec2 uv2 = vec2(
            (hit.x + 1.0) * 0.5,
            1.0 - (hit.z + 1.0) * 0.5
        );

        gl_FragColor = texture2D(bitmap, uv2);
    }
    else
    {
        if (rd.y <= 0.0)
            discard;

        t = (1.0 - ro.y) / rd.y;
        hit = ro + rd * t;

        if (hit.x < -1.0 || hit.x > 1.0 ||
            hit.z < -1.0 || hit.z > 1.0)
            discard;

        vec2 uv2 = vec2(
            (hit.x + 1.0) * 0.5,
            (hit.z + 1.0) * 0.5
        );
        

        gl_FragColor = texture2D(bitmap, uv2);
    }
}