#version 300 es
precision highp float;

in vec4 fs_Col;
in vec4 fs_Pos;
in vec2 fs_UVtex;

out vec4 out_Col;

uniform vec2 u_Dimensions;
uniform sampler2D u_SplashTex1;
uniform sampler2D u_SplashTex2;
uniform sampler2D u_TestTex2;

in float fs_Splash;

vec3 colorFxn(vec3 col) {
  return vec3(col / 255.0);
}

void main()
{    
    vec3 c = vec3(170.0, 233.0, 237.0);
    out_Col = vec4(colorFxn(c), 1.0);

    vec2 uv = fs_UVtex;
    
    vec4 texCol = texture(u_TestTex2, uv);
    if (fs_Splash == 1.0) {
        texCol = texture(u_SplashTex1, uv);
    }
    if (fs_Splash == 2.0) {
        texCol = texture(u_SplashTex2, uv);
    }
    if (texCol[3] < 0.1) {
      discard; // gets rid of transparent fragments
    }
    out_Col = texCol;
}
