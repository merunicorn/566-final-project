#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

vec3 colorFxn(vec3 col) {
  return vec3(col / 255.0);
}

void main() {
  out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.0, 1.0);
}
