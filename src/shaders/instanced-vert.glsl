#version 300 es

uniform mat4 u_ViewProj;
uniform float u_Time;

uniform mat4 u_Fall;

uniform mat3 u_CameraAxes; // Used for rendering particles as billboards (quads that are always looking at the camera)
// gl_Position = center + vs_Pos.x * camRight + vs_Pos.y * camUp;

in vec4 vs_Pos; // Non-instanced; each particle is the same quad drawn in a different place
in vec4 vs_Nor; // Non-instanced, and presently unused
in vec4 vs_Col; // An instanced rendering attribute; each particle instance has a different color
in vec3 vs_Translate; // Another instance rendering attribute used to position each quad instance in the scene
in vec2 vs_UV; // Non-instanced, and presently unused in main(). Feel free to use it for your meshes.

in vec4 vs_Transf1;
in vec4 vs_Transf2;
in vec4 vs_Transf3;
in vec4 vs_Transf4;

out vec4 fs_Col;
out vec4 fs_Pos;

void main()
{
    fs_Col = vs_Col;
    fs_Pos = vs_Pos;

    vec4 newT4 = vs_Transf4;

    float rate = 5.0 * 16.0; // increase for slower, decrease for faster
    for (int i = 0; i < 14; i++) {
        if (int(u_Time - (rate * floor(u_Time/rate))) == i) {
            if (i < 4) {
                newT4[1] = u_Fall[0][i];
            }
            else if (i < 8) {
                newT4[1] = u_Fall[1][i-4];
            }
            else if (i < 12) {
                newT4[1] = u_Fall[2][i-8];
            }
            else {
                newT4[1] = u_Fall[3][i-12];
            }
        }
    }

    
    
    // mat4 transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(vs_Transf4));
    mat4 transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
    // gl_Position = u_ViewProj * transf * vs_Pos;

    vec3 offset = vec3(vs_Transf4);
    vec3 billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];

    //offset.z = (sin((u_Time + offset.x) * 3.14159 * 0.1) + cos((u_Time + offset.y) * 3.14159 * 0.1)) * 1.5;
    
    // gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
    gl_Position = u_ViewProj * transf * vs_Pos; // no billboard
}
