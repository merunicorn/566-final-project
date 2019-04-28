#version 300 es
precision highp float;

in vec4 fs_Col;
in vec4 fs_Pos;
in vec2 fs_UVtex;

out vec4 out_Col;

uniform vec2 u_Dimensions;
uniform sampler2D u_TestTex;
uniform sampler2D u_TestTex2;

vec3 colorFxn(vec3 col) {
  return vec3(col / 255.0);
}

void main()
{
    //float dist = 1.0 - (length(fs_Pos.xyz) * 2.0);
    //out_Col = vec4(dist) * fs_Col;
    
    vec3 c = vec3(170.0, 233.0, 237.0);
    out_Col = vec4(colorFxn(c), 1.0);

    vec2 uv = fs_UVtex;
    out_Col = texture(u_TestTex2, uv);

    if (out_Col == vec4(1.0, 1.0, 1.0, 1.0)) {
      out_Col = vec4(1.0, 1.0, 1.0, 0.0);
    }

    /*
    vec3 coreColor = vec3(150.0, 255.0, 247.0) / 255.0 * mix(0.0, 1.0, resampledTexture.g);
    vec3 outerColor = vec3(0.0, 255.0, 210.0) / 255.0 * mix(0.0, 1.0, resampledTexture.r);
    vec3 noColor = vec3(0.0, 0.0, 50.0) / 255.0 * mix(0.0, 1.0, resampledTexture.b);

    out_Col = vec4(coreColor + outerColor + noColor, 1.0);
    out_Col.rgb = mix(out_Col.rgb, noColor, step(uv.x, 0.1));
    out_Col.rgb = mix(out_Col.rgb, noColor, step(0.9, uv.x));*/
}
