#version 300 es
precision highp float;

in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

vec3 colorFxn(vec3 col) {
  return vec3(col / 255.0);
}

void main()
{
    //float dist = 1.0 - (length(fs_Pos.xyz) * 2.0);
    //out_Col = vec4(dist) * fs_Col;
    
    vec3 c = vec3(170.0, 233.0, 237.0);
    out_Col = vec4(colorFxn(c), 1.0);
}
