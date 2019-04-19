#version 300 es

uniform mat4 u_ViewProj;
uniform float u_Time;

uniform mat4 u_Fall1;
uniform mat4 u_Fall2;
uniform mat4 u_Fall3;

uniform mat3 u_CameraAxes; // Used for rendering particles as billboards (quads that are always looking at the camera)
// gl_Position = center + vs_Pos.x * camRight + vs_Pos.y * camUp;

in vec4 vs_Pos; // Non-instanced; each particle is the same quad drawn in a different place
in vec4 vs_Nor; // Non-instanced, and presently unused

in float vs_Col; // PARTICLE HEIGHT, NOT COLOR

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
    //fs_Col = vs_Col;
    fs_Col = vec4(1.0,1.0,0.0,1.0);
    fs_Pos = vs_Pos;

    vec4 newT4 = vs_Transf4;

    float tsec = u_Time - 48.0 * floor(u_Time/48.0); // u_Time mod 48
    int i = int(tsec);

    i += int(vs_Col); // starting position offset

    if (i > 48) { // clamp at top + reset i
        i = i - 48;
    }

    if (i < 4) {
        newT4[1] = u_Fall1[0][i];
    }
    else if (i < 8) {
        newT4[1] = u_Fall1[1][i-4];
    }
    else if (i < 12) {
        newT4[1] = u_Fall1[2][i-8];
    }
    else if (i < 16) {
        newT4[1] = u_Fall1[3][i-12];
    }
    else if (i < 20) {
        newT4[1] = u_Fall2[0][i-0];
    }
    else if (i < 24) {
        newT4[1] = u_Fall2[1][i-4];
    }
    else if (i < 28) {
        newT4[1] = u_Fall2[2][i-8];
    }
    else if (i < 32) {
        newT4[1] = u_Fall2[3][i-12];
    }
    else if (i < 36) {
        newT4[1] = u_Fall3[0][i];
    }
    else if (i < 40) {
        newT4[1] = u_Fall3[1][i-4];
    }
    else if (i < 44) {
        newT4[1] = u_Fall3[2][i-8];
    }
    else {
        newT4[1] = u_Fall3[3][i-12];
    }

    // mat4 transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(vs_Transf4));
    mat4 transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
    // gl_Position = u_ViewProj * transf * vs_Pos;

    vec3 offset = vec3(newT4);
    vec3 billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];

    //offset.z = (sin((u_Time + offset.x) * 3.14159 * 0.1) + cos((u_Time + offset.y) * 3.14159 * 0.1)) * 1.5;
    
    gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
    // gl_Position = u_ViewProj * transf * vs_Pos; // no billboard
}
