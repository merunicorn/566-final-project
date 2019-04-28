#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

in vec4 vs_Pos;
out vec2 fs_Pos;

out vec2 fs_UV;

void main() {
  fs_Pos = vs_Pos.xy;
  gl_Position = vs_Pos;
  fs_UV = vec2(fs_Pos.x + 0.5, fs_Pos.y + 0.5);
}
