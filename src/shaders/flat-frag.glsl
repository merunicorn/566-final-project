#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

uniform sampler2D u_SplashTex1;
uniform sampler2D u_SplashTex2;
uniform sampler2D u_TestTex2;

in vec2 fs_Pos;
in vec2 fs_UV;

out vec4 out_Col;

vec3 light;
vec3 nor;
float worl;

vec3 anim_trans;
vec3 anim_angle;

float map_value;
bool water_hit;

vec3 colorFxn(vec3 col) {
  return vec3(col / 255.0);
}

vec3 rayCast(vec4 s) {
    // multiply by far clip plane
    float far_clip = 1000.0;
    float near_clip = 0.1;
    s *= far_clip;

    // multiply by inverse projection matrix
    mat4 proj;
    float fov = 45.0;
    float fov_rad = (fov * 3.14159) / 180.0;
    float S_f = tan(fov_rad / 2.0);
    float a = 1.0 / ((u_Dimensions.x / u_Dimensions.y) * S_f);
    float b = 1.0 / S_f;
    float P = far_clip / (far_clip - near_clip);
    float Q = (-1.f * far_clip * near_clip) / (far_clip - near_clip);
    proj[0][0] = a;
    proj[1][1] = b;
    proj[2][2] = P;
    proj[3][2] = Q;
    proj[2][3] = 1.0;
    proj[3][3] = 0.0;
    s = inverse(proj) * s;

    // multiply by inverse of view matrix
    mat4 view;
    mat4 orient;
    mat4 transl;
    vec3 forw_axis = u_Ref - u_Eye;
    vec3 right_axis = cross(u_Up, forw_axis);
    vec3 up_axis = cross(right_axis, forw_axis);

    // special case where forward is world up
    if (forw_axis == u_Up) {
      right_axis = vec3(1.0, 0.0, 0.0);
      up_axis = vec3(0.0, 0.0, -1.0);
    }

    // set up orientation and translation matrices
    for (int i = 0; i < 3; i++) {
      orient[0][i] = right_axis[i];
      orient[1][i] = up_axis[i];
      orient[2][i] = forw_axis[i];
      transl[3][i] = u_Eye[i] * -1.0;
    }
    view = orient * transl;
    s = inverse(view) * s;

    // set up ray
    vec3 origin = u_Eye;
    vec3 dir = normalize(vec3(s) - u_Eye);

    // set light vector for shading
    light = vec3((inverse(view) * vec4(0.0, 0.0, 0.0, 1.0)) - vec4(fs_Pos, 1.0, 1.0));

    return dir;
}

float sdf_sphere(vec3 p, float rad) {
  float sphere = length(p) - rad;
  return sphere;
}

float sdf_box(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return length(max(d,0.0));
}

float sdf_torus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

float sdf_cylin(vec3 p, vec2 h) {
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float dot2(vec2 v) {
  return dot(v, v); 
}

float sdf_capcone(vec3 p, float h, float r1, float r2) {
  vec2 q = vec2(length(p.xz), p.y);
  vec2 k1 = vec2(r2, h);
  vec2 k2 = vec2(r2-r1, 2.0 * h);
  vec2 ca = vec2(q.x - min(q.x,(q.y < 0.0) ? r1:r2), abs(q.y) - h);
  vec2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot2(k2), 0.0, 1.0);
  float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
  return s * sqrt(min(dot2(ca), dot2(cb)));
}

float union_op(float d1, float d2) {
  return min(d1, d2);
}

float sm_union_op(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h); 
}

float sub_op(float d1, float d2) {
  return max(-1.0 * d1, d2);
}

float sect_op(float d1, float d2) {
  return max(d1, d2);
}

mat4 rot_matrix(vec3 r) {
  // convert angle to radians
  r = (r * 3.14159) / 180.0;

  mat4 m;
  m[0][0] = 1.0;
  m[1][1] = 1.0;
  m[2][2] = 1.0;
  m[3][3] = 1.0;
  mat4 rot_x = m;
  rot_x[1][1] = cos(r.x);
  rot_x[1][2] = sin(r.x);
  rot_x[2][1] = -1.0 * sin(r.x);
  rot_x[2][2] = cos(r.x);
  mat4 rot_y = m;
  rot_y[0][0] = cos(r.y);
  rot_y[2][2] = cos(r.y);
  rot_y[2][0] = sin(r.y);
  rot_y[0][2] = -1.0 * sin(r.y);
  mat4 rot_z = m;
  rot_z[0][0] = cos(r.z);
  rot_z[1][1] = cos(r.z);
  rot_z[1][0] = -1.0 * sin(r.z);
  rot_z[0][1] = sin(r.z);

  return rot_x * rot_y * rot_z;
}

vec3 trans_pt(vec3 p, vec3 t) {
  return p + t;
}

vec3 rot_op(vec3 r, vec3 p) {
  mat4 tmat = rot_matrix(-1.0 * r);
  vec3 p_rot = vec3(tmat * vec4(p, 1.0));
  return p_rot;
}

// SDF FUNCTION
float pedestalSDF(vec3 p) {
  // SPHERE 
  vec3 t_sph = vec3(0.0, 2.1, 5.0);
  vec3 p_sph = trans_pt(p, t_sph);

  // BOX 
  vec3 t_box = vec3(0.0, 6.0, 5.0);
  vec3 p_box = trans_pt(p, t_box);

  // TORUS test 
  // vec3 t_tor = vec3(0.0, 0.0, 5.0);
  // vec3 p_tor = trans_pt(p, t_tor);

  // SDFs
  float sph = sdf_sphere(p_sph, 3.5); // radius
  float box = sdf_box(p_box, vec3(4.0)); // l,w,h 
  // float tor = sdf_torus(p_tor, vec2(2.5, 0.5)); // torus radius, tube radius/thickness

  // COMBINE SHAPES 
  float dist = sect_op(sph, box);
  // float dist2 = union_op(dist, tor);
  // dist = dist2;

  // RETURN DIST 
  // float dist = sph;
  return dist;
}

// ESTIMATE NORMAL FUNCTION
vec3 estNormalPed(vec3 p) {
  // find normal of pedestal points
  float eps = 0.001;
  vec3 nor_c = vec3(pedestalSDF(vec3(p.x + eps, p.y, p.z)) - pedestalSDF(vec3(p.x - eps, p.y, p.z)),
                  pedestalSDF(vec3(p.x, p.y + eps, p.z)) - pedestalSDF(vec3(p.x, p.y - eps, p.z)),
                  pedestalSDF(vec3(p.x, p.y, p.z + eps)) - pedestalSDF(vec3(p.x, p.y, p.z - eps)));
  return normalize(nor_c);
}

vec2 rayMarch(vec3 eye, vec3 dir) { 
  // rayMarch returns (t, object id)
  float t = 0.01;
  int max_steps = 1000;
  vec3 p = eye + t * dir;
  for (int i = 0; i < max_steps; i++) {
    p = eye + t * dir;

    float dist = pedestalSDF(p);
    nor = estNormalPed(p);

    if (dist < 0.00001) {
      // at pedestal surface
      map_value = dist;
      nor = estNormalPed(p);
      return vec2(t, 1.0);  
      // move along ray
      t += dist;
    }
    else {
      // increment by smallest distance
      t += dist;
      map_value = dist;
    }
  
    if (t >= 1000.0) {
      // end
      return vec2(t, 0.0);
    }
  }
  t = 1000.0;
  return vec2(t, 0.0);
}

float softShadow(vec3 dir, vec3 origin, float min_t, float k) {
  float res = 1.0;
  float t = min_t;
  for(int i = 0; i < 1000; ++i) {
    //float m = map_value;
    float m = pedestalSDF(origin + t * dir); // NEED TO CALL SPECIFIC SDF FXN HERE
    if(m < 0.0001) {
      return 0.0;
    }
    res = min(res, k * m / t);
    t += m;
  }
  return res;
}

void main() {
  // RAYCASTING
  // convert to NDC screen coors
  vec4 s = vec4(-1.0 * (((gl_FragCoord.x / u_Dimensions.x) * 2.0) - 1.0),
                -1.0 * (1.0 - ((gl_FragCoord.y / u_Dimensions.y) * 2.0)), 1.0, 1.0);
  vec3 dir = rayCast(s);
  // out_Col = vec4(vec3(0.5 * (dir + vec3(1.0, 1.0, 1.0))), 1.0);

  // RAYMARCHING
    vec2 march = rayMarch(u_Eye, dir);
    if (march[0] < 1000.0) {
      vec4 diffuseColor;
      if (march[1] == 1.0) {
        // hit pedestal
        // diffuseColor = vec4(colorFxn(vec3(185.0, 230.0, 243.0)), 1.0);
        diffuseColor = vec4(colorFxn(vec3(2.0, 27.0, 38.0)), 1.0);
      }        

      // LIGHTING
      /*
      if (march[1] == 1.0) { // if matches specific SDF id
        vec4 lights[4];
        vec3 lightColor[4];

        // Light positions with intensity as w-component
        lights[0] = vec4(6.0, 3.0, 5.0, 2.0); // key light
        lights[1] = vec4(-6.0, 3.0, 5.0, 1.5); // fill light
        lights[2] = vec4(0.0, -3.0, 5.0, 2.0);
        lights[3] = vec4(vec3(light), 1.0);
        
        lightColor[0] = colorFxn(vec3(132.0, 115.0, 198.0));
        lightColor[1] = colorFxn(vec3(255.0, 241.0, 207.0));
        lightColor[2] = colorFxn(vec3(155.0, 233.0, 255.0));
        lightColor[3] = vec3(1.0);

        vec3 sum = vec3(0.0);
        for (int j = 0; j < 4; j++) {
          // Calculate diffuse term for shading
          float diffuseTerm = dot(normalize(nor), normalize(vec3(lights[j])));
          // Avoid negative lighting values
          diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
          float ambientTerm = 0.2;
          float lightIntensity = diffuseTerm + ambientTerm;

          // Implement specular light
          vec4 H;
          for (int i = 0; i < 4; i++) {
            H[i] = (lights[j][i] + u_Eye[i]) / 2.0;
          }
          float specularIntensity = max(pow(dot(normalize(H), normalize(vec4(nor,1.0))), 1.5), 0.0);

          // Compute final shaded color
          vec3 mater = vec3(1.0) * min(specularIntensity, 1.0) * lights[j].w * lightColor[j];
          diffuseColor *= softShadow(dir, vec3(lights[j]), 1.5, 4.0);
          sum += mater * diffuseColor.rgb * (lights[j].w + specularIntensity);
        }
        out_Col = vec4((sum / 3.0), 1.0);
      }
      else {
        out_Col = diffuseColor;
      }
      */
      out_Col = diffuseColor;
    }
    else {
      // bg color
      // out_Col = vec4(colorFxn(vec3(2.0, 27.0, 38.0)), 1.0);
      out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.0, 1.0);
    }

  // COLOR
  // out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.0, 1.0);

  //vec2 uv = fs_UV;
  //out_Col = texture(u_TestTex, uv);
}
