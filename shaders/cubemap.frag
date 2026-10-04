/*
 * Makes a 2D sprite behave like one face of a 3D cube.
 *
 * Uniforms:
 *   yaw   = horizontal camera rotation
 *   pitch = vertical camera rotation
 *   side  = which cube face this sprite represents
 *
 * Side values:
 *   0 = Front / Middle
 *   1 = Left
 *   2 = Back
 *   3 = Right
 *   4 = Top
 *   5 = Bottom
 *
 * Example:
 *   shader.data.yaw.value = [yaw];
 *   shader.data.pitch.value = [pitch];
 *   shader.data.side.value = [0];
 */

#pragma header 

uniform float yaw; 
uniform float fov; 
uniform float pitch; 
uniform float side; // mid 0, left 1, back 2, right 3, top 4, bottom 5

const float PI = 3.14159265;

void main() 
{
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 p = uv * 2.0 - 1.0;

	float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
	p.x *= aspect;

	vec3 ro = vec3(0.0, 0.0, -0.995);
	vec3 rd = normalize(vec3(p, fov));

	float cp = cos(pitch);
	float sp = sin(pitch);

	mat3 pitchRot = mat3(
        1.0, 0.0, 0.0, 
        0.0, cp, -sp, 
        0.0, sp, cp);

	rd = pitchRot * rd;

	if (side < 3.5) {
		float angle = yaw + side * (PI / 2.0);

		float c = cos(angle);
		float s = sin(angle);
		
		mat3 rot = mat3(c, 0.0, -s, 
						0.0, 1.0, 0.0, 
						s, 0.0, c);
		rd = rot * rd;

	} else if (side < 4.5) {
		float cy = cos(yaw);
		float sy = sin(yaw);

		mat3 yawRot = mat3(cy, 0.0, -sy, 
							0.0, 1.0, 0.0, 
							sy, 0.0, cy);

		rd = yawRot * rd;

		float c = cos(PI / 2.0);
		float s = sin(PI / 2.0);

		mat3 topRot = mat3(
            1.0, 0.0, 0.0, 
            0.0, c, -s, 
            0.0, s, c);
		rd = topRot * rd;
	} else {
		float cy = cos(yaw);
		float sy = sin(yaw);

		mat3 yawRot = mat3(cy, 0.0, -sy, 
							0.0, 1.0, 0.0, 
							sy, 0.0, cy);
		rd = yawRot * rd;

		float c = cos(-PI / 2.0);
		float s = sin(-PI / 2.0);

		mat3 bottomRot = mat3(1.0, 0.0, 0.0, 
							0.0, c, -s, 
							0.0, s, c);
		rd = bottomRot * rd;

	}
	if (rd.z <= 0.0)
		discard;

	float t = -ro.z / rd.z;

	if (t <= 0.0)
		discard;

	vec3 hit = ro + rd * t;
	vec2 uv2 = hit.xy;

	uv2.x /= aspect;
	uv2 = uv2 * 0.5 + 0.5;

	if (uv2.x < 0.0 || uv2.x > 1.0 || 
        uv2.y < 0.0 || uv2.y > 1.0)
		discard;

	gl_FragColor = texture2D(bitmap, uv2);
}
