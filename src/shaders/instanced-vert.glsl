#version 300 es

uniform mat4 u_ViewProj;
uniform float u_Time;

uniform mat4 u_Fall1;
uniform mat4 u_Fall2;
uniform mat4 u_Fall3;

uniform mat3 u_CameraAxes; // Used for rendering particles as billboards (quads that are always looking at the camera)

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
out vec2 fs_UVtex;

out float fs_Splash;

void main()
{
    float drag = 0.0;
    fs_Col = vec4(1.0,1.0,0.0,1.0);
    fs_Pos = vs_Pos;
    fs_Splash = 0.0;

    fs_UVtex = vec2(fs_Pos.x + 0.5, fs_Pos.y + 0.5);

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

    newT4[2] = newT4[2] + 5.0; // edit z value

    mat4 transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
    vec3 offset = vec3(newT4);
    vec3 billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];

    // TEST FOR RAINDROP POSITION; DEPTH MAP
    if (newT4[0] >= 2.0 && newT4[0] <= 3.0
        && newT4[2] <= 4.0 && newT4[2] >= 0.0
        && i >= 24) {
        // B3 BOX
        if (i < 26) {
            fs_Splash = 1.0;

            i = 24; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall3[0][i-0] + 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
        }
        else if (i < 28) {
            fs_Splash = 2.0;

            i = 24; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall3[0][i-0] + 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
        }
    }
    else if (newT4[0] >= 4.0 && newT4[0] <= 5.0
        && newT4[2] <= 8.0 && newT4[2] >= 7.0
        && i >= 18) {
        // B2 BOX
        if (i < 20) {
            i = 18; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall1[3][i-12] - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
        
            fs_Splash = 1.0;
        }
        else if (i < 22) {
            i = 18; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall1[3][i-12] - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
            
            fs_Splash = 2.0;
        }
    }
    else if (newT4[0] >= 2.0 && newT4[0] <= 4.0
        && newT4[2] <= 10.0 && newT4[2] >= 8.0
        && i >= 18) {
        // B6 BOX
        if (i < 20) {
            i = 18; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[0][i-0] + 1.0 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            fs_Splash = 1.0;
        }
        else if (i < 22) {
            i = 18; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[0][i-0] + 1.0 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            fs_Splash = 2.0;
        }
    }
    else if (newT4[0] >= -1.0 && newT4[0] <= 1.0
        && newT4[2] <= 10.0 && newT4[2] >= 8.0
        && i >= 24) {
        // T_BOX
        if (i < 26) {
            i = 24; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[1][i-4] + 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            fs_Splash = 1.0;
        }
        else if (i < 28) {
            i = 24; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[1][i-4] + 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            fs_Splash = 2.0;

        }
    }
    else if (newT4[0] >= -3.0 && newT4[0] <= -1.0
        && newT4[2] <= 10.0 && newT4[2] >= 8.0
        && i >= 28) {
        // B5 BOX
        if (i < 30) {
            i = 28; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[2][i-8] - 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 1.0;
        }
        else if (i < 32) {
            i = 28; // freeze @ collision depth
            // render @ collision depth
            newT4[1] = u_Fall2[2][i-8] - 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 2.0;
        }
    }
    else if (newT4[0] >= -5.0 && newT4[0] <= -3.0
        && newT4[2] <= 8.0 && newT4[2] >= 6.0
        && i >= 14) {
        // B4 BOX
        if (i < 16) {
            i = 14; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall1[2][i-8] - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 1.0;
        }
        else if (i < 18) {
            i = 14; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall1[2][i-8] - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 2.0;
        }
    }
    else if (newT4[0] >= -6.0 && newT4[0] < -5.0
        && newT4[2] <= 5.0 && newT4[2] >= 3.0
        && i >= 24) {
        // B7 BOX
        if (i < 26) {
            i = 24; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall2[1][i-4] + 1.0 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 1.0;
        }
        else if (i < 28) {
            i = 24; // freeze @ collision depth

            // render @ collision depth
            newT4[1] = u_Fall2[1][i-4] + 1.0 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 2.0;
        }
    }
    // ACCOUNT FOR NOT RENDERING RAIN BEHIND GEOMETRY AFTER SOME HEIGHT
    else if (newT4[0] >= 4.0 && newT4[0] <= 5.0
        && newT4[2] <= 10.0 && newT4[2] >= 8.0
        && i > 18) {
    }
    else if (newT4[0] >= 2.0 && newT4[0] <= 3.0
        && newT4[2] <= 8.0 && newT4[2] >= 4.0
        && i > 24) {
    }
    else if (newT4[0] >= -5.0 && newT4[0] <= -3.0
        && newT4[2] <= 10.0 && newT4[2] >= 8.0
        && i > 18) {
    }
    else {
        // RENDER RAINDROP; ACCOUNT FOR FLOOR COLLISION
        if (i < 44) {
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard
        }
        else if (i < 47) {
            i = 44; // freeze @ collision depth
            if (newT4[2] <= 0.0) {
                i = 45;
            }

            // render @ collision depth
            newT4[1] = u_Fall3[2][i-8] - 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 1.0;
        }
        else {
            i = 44; // freeze @ collision depth
            if (newT4[2] <= 0.0) {
                i = 45;
            }

            // render @ collision depth
            newT4[1] = u_Fall3[2][i-8] - 0.5 - drag;
            transf = mat4((vs_Transf1),(vs_Transf2),(vs_Transf3),(newT4));
            offset = vec3(newT4);
            billboardPos = offset + vs_Pos.x * u_CameraAxes[0] + vs_Pos.y * u_CameraAxes[1];
            gl_Position = u_ViewProj * vec4(billboardPos, 1.0); // billboard

            // pass in splash flag to frag
            fs_Splash = 2.0;
        }
    }
}
