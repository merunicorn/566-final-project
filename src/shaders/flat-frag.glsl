#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

uniform sampler2D u_SplashTex1;
uniform sampler2D u_SplashTex2;

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

float random1(float t) {
    return 2.0 * fract(sin(t * 489.12342) * 348921.32457) - 1.0;
}

vec2 random2(vec2 p, vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

// ADAM'S CODE
vec3 remapColor(vec3 c, float offset, float seed) {
    float ro = random1(seed) * offset;
    float go = random1(seed + 31242.134) * offset;
    float bo = random1(seed + 73576.347) * offset;
    
    return clamp(vec3(c.r + ro, c.g + go, c.b + bo), 0.0, 1.0);
}

//Smoothstep (Adam's code)
vec2 mySmoothStep(vec2 a, vec2 b, float t) {
    t = smoothstep(0.0, 1.0, t);
    return mix(a, b, t);
}

//2d Noise (Adam's code)
vec2 interpNoise2D(vec2 uv) {
    vec2 uvFract = fract(uv);
    vec2 ll = random2(floor(uv), vec2(10.0)); //need to input seeds
    vec2 lr = random2(floor(uv) + vec2(1,0), vec2(10.0));
    vec2 ul = random2(floor(uv) + vec2(0,1), vec2(10.0));
    vec2 ur = random2(floor(uv) + vec2(1,1), vec2(10.0));

    vec2 lerpXL = mySmoothStep(ll, lr, uvFract.x);
    vec2 lerpXU = mySmoothStep(ul, ur, uvFract.x);

    return mySmoothStep(lerpXL, lerpXU, uvFract.y);
}

//FBM (Adam's base code)
vec2 fbm(vec2 uv) {
    float amp = 20.0;
    float freq = 1.0;
    vec2 sum = vec2(0.0);
    float maxSum = 0.0;
    int octaves = 10; //can modify
    for(int i = 0; i < octaves; i++) {
        sum += interpNoise2D(uv * freq) * amp;
        maxSum += amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    return sum / maxSum;
}

// SHADERTOY 
vec2 hash( vec2 p ) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

// SHADERTOY 
float noise( in vec2 p ) {
      float K1 = 0.366025404; // (sqrt(3)-1)/2;
      float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x+p.y)*K1);	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));	
}
 
// SHADERTOY
float fbm_float(vec2 n) {
	float total = 0.0, amplitude = 0.1;
  mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = m * n;
		amplitude *= 0.4;
	}
	return total;
}

// ADAM'S CODE 
float WorleyNoise(vec2 uv) {
    // Tile the space
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);

    float minDist = 1.0; // Minimum distance initialized to max.

    // Search all neighboring cells and this cell for their point
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));

            // Random point inside current neighboring cell
            vec2 point = random2(uvInt + neighbor, vec2(10.0));

            // Compute the distance b/t the point and the fragment
            // Store the min dist thus far
            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

vec3 smoothstepPow(vec3 c, float p) {
    return pow(smoothstep(0.0, 1.0, c), vec3(p));
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
  vec3 t_b2 = vec3(0.0, -1.8, 5.0);
  vec3 p_b2 = trans_pt(p, t_b2);

  // SDFs
  float sph = sdf_sphere(p_sph, 3.5); // radius
  float box = sdf_box(p_box, vec3(4.0)); // l,w,h 
  float b2 = sdf_box(p_b2, vec3(4.0)); // l,w,h 

  // COMBINE SHAPES 
  float dist = sect_op(sph, box);
  float dist2 = sect_op(dist, b2);

  // RETURN DIST 
  dist = dist2;
  return dist;
}

float soilSDF(vec3 p) {
  // SPHERE 
  vec3 t_sph = vec3(0.0, 2.1, 5.0);
  vec3 p_sph = trans_pt(p, t_sph);

  // BOX 
  vec3 t_box = vec3(0.0, 6.0, 5.0);
  vec3 p_box = trans_pt(p, t_box);

  // SDFs
  float sph = sdf_sphere(p_sph, 3.5); // radius
  float box = sdf_box(p_box, vec3(4.0)); // l,w,h 

  // COMBINE SHAPES 
  float dist = sect_op(sph, box);

  // set up worley noise var
  worl = WorleyNoise(5.0 * p.xz);

  // RETURN DIST 
  return dist;
}

float citySDF(vec3 p) {
  // PARAMETERS
  float size = 0.4;
  float size2 = 0.6;
  float size3 = 0.2;
  float size4 = 0.07;

  // BOX 
  vec3 t_box = vec3(0.0, 1.0, 3.0);
  vec3 p_box = trans_pt(p, t_box);
  vec3 t_b1a = vec3(0.0, 0.9, 3.0);
  vec3 p_b1a = trans_pt(p, t_b1a);
  vec3 t_b1b = vec3(0.0, 0.3, 3.0);
  vec3 p_b1b = trans_pt(p, t_b1b);

  vec3 t_b2 = vec3(-2.0, 0.0, 5.0);
  vec3 p_b2 = trans_pt(p, t_b2);

  vec3 t_b3 = vec3(-1.0, 2.0, 7.0);
  vec3 p_b3 = trans_pt(p, t_b3);

  vec3 t_b4 = vec3(1.5, 0.5, 5.0);
  vec3 p_b4 = trans_pt(p, t_b4);
  vec3 t_b4a = vec3(1.5, 0.3, 5.0);
  vec3 p_b4a = trans_pt(p, t_b4a);

  vec3 t_b5 = vec3(1.0, 2.0, 3.0);
  vec3 p_b5 = trans_pt(p, t_b5);
  vec3 t_b6 = vec3(-1.0, 1.0, 3.0);
  vec3 p_b6 = trans_pt(p, t_b6);

  vec3 t_b7 = vec3(2.5, 0.0, 6.5);
  vec3 p_b7 = trans_pt(p, t_b7);
  vec3 t_b8 = vec3(-2.5, 0.0, 6.0);
  vec3 p_b8 = trans_pt(p, t_b8);

  // SDFs
  float box = sdf_box(p_box, vec3(size,3.0,size)); // w,h,l 
  float b1a = sdf_box(p_b1a, vec3(size3,3.0,size3)); // w,h,l 
  float b1b = sdf_box(p_b1b, vec3(size4,3.0,size4)); // w,h,l 

  float b2 = sdf_box(p_b2, vec3(size,3.0,size)); // w,h,l 
  float b3 = sdf_box(p_b3, vec3(size,2.0,size)); // w,h,l 
  float b4 = sdf_box(p_b4, vec3(size2,4.0,size2)); // w,h,l 
  float b4a = sdf_box(p_b4a, vec3(size,4.0,size)); // w,h,l 

  float b5 = sdf_box(p_b5, vec3(size2,3.0,size2)); // w,h,l 
  float b6 = sdf_box(p_b6, vec3(size2,4.0,size2)); // w,h,l 
  float b7 = sdf_box(p_b7, vec3(size,2.0,size)); // w,h,l 
  float b8 = sdf_box(p_b8, vec3(size,2.0,size)); // w,h,l

  // COMBINE SHAPES 
  float dist = union_op(b2, box);
  dist = union_op(b3, dist);
  dist = union_op(b4, dist);
  dist = union_op(b5, dist);
  dist = union_op(b6, dist);
  dist = union_op(b7, dist);
  dist = union_op(b8, dist);

  dist = union_op(b1a, dist);
  dist = union_op(b1b, dist);
  dist = union_op(b4a, dist);

  // RETURN DIST 
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

vec3 estNormalSoil(vec3 p) {
  // find normal of soil points
  float eps = 0.001;
  vec3 nor_c = vec3(soilSDF(vec3(p.x + eps, p.y, p.z)) - soilSDF(vec3(p.x - eps, p.y, p.z)),
                  soilSDF(vec3(p.x, p.y + eps, p.z)) - soilSDF(vec3(p.x, p.y - eps, p.z)),
                  soilSDF(vec3(p.x, p.y, p.z + eps)) - soilSDF(vec3(p.x, p.y, p.z - eps)));
  return normalize(nor_c);
}

vec3 estNormalCity(vec3 p) {
  // find normal of city points
  float eps = 0.001;
  vec3 nor_c = vec3(citySDF(vec3(p.x + eps, p.y, p.z)) - citySDF(vec3(p.x - eps, p.y, p.z)),
                  citySDF(vec3(p.x, p.y + eps, p.z)) - citySDF(vec3(p.x, p.y - eps, p.z)),
                  citySDF(vec3(p.x, p.y, p.z + eps)) - citySDF(vec3(p.x, p.y, p.z - eps)));
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
    float dist2 = soilSDF(p);
    float dist3 = citySDF(p);
    nor = estNormalPed(p);

    if (dist < 0.00001) {
      // at pedestal surface
      map_value = dist;
      nor = estNormalPed(p);
      return vec2(t, 1.0);  
    }
    else if (dist2 < 0.00001) {
      // at soil surface
      map_value = dist2;
      nor = estNormalSoil(p);
      return vec2(t, 2.0);  
    }
    else if (dist3 < 0.00001) {
      // at city surface
      map_value = dist3;
      nor = estNormalCity(p);
      return vec2(t, 3.0);  
    }
    else {
      // increment by smallest distance
      float dist_min = min(dist, dist2);
      dist_min = min(dist_min, dist3);
      t += dist_min;
      map_value = dist_min;
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

bool rayBoxIntersection(vec3 origin, vec3 dir, vec3 min, vec3 max) {
  // check intersection of ray with cube for bounding box purposes
  float near = -1.0 * (1.0 / 0.0);
  float far = (1.0 / 0.0);
  float t0;
  float t1;
  for (int i = 0; i < 3; i++) {
    if (dir[i] == 0.0) {
      if (origin[i] < min[i] || origin[i] > max[i]) {
        return false;
      }
    }
    t0 = (min[i] - origin[i]) / dir[i];
    t1 = (max[i] - origin[i]) / dir[i];
    if (t0 > t1) {
      float temp = t0;
      t0 = t1;
      t1 = temp;
    }
    if (t0 > near) {
      near = t0;
    }
    if (t1 < far) {
      far = t1;
    }
  }
  if (near > far) {
    return false;
  }
  else {
    return true;
  }
}

// REFERENCED FROM BOOK OF SHADERS
vec2 brickTile(vec2 _st, float _zoom, float offset){
    _st *= _zoom;

    if (offset == 1.0) {
      // Here is where the offset is happening
      _st.x += step(1., mod(_st.y,2.0)) * 0.5;
    }
    return fract(_st);
}

// REFERENCED FROM BOOK OF SHADERS
float box(vec2 _st, vec2 _size) {
    _size = vec2(0.5)-_size*0.4;
    vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st);
    uv *= smoothstep(_size,_size+vec2(1e-4),vec2(1.0)-_st);
    return uv.x*uv.y;
}

// CODE FROM SHADERTOY 
vec4 cloudFxn() {
    float cloudscale = 1.1;
    float speed = 0.0005;
    float clouddark = 0.5;
    float cloudlight = 0.5;
    float cloudcover = 0.05;
    float cloudalpha = 5.0;
    float skytint = 1.5;
    vec3 skycolour1 = colorFxn(vec3(81.0, 70.0, 99.0));
    vec3 skycolour2 = colorFxn(vec3(77.0, 83.0, 130.0));
    float time = u_Time * speed;

    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    vec2 p = gl_FragCoord.xy / u_Dimensions.xy;
	  vec2 uv = p*vec2(u_Dimensions.x/u_Dimensions.y,1.0);    
    float q = fbm_float(uv * cloudscale * 0.5);
    
    //ridged noise shape
	  float r = 0.0;
	  uv *= cloudscale;
    uv -= q;
    float weight = 0.8;
    for (int i=0; i<8; i++){
		  r += abs(weight*noise( uv ));
      uv = m*uv;
		  weight *= 0.7;
    }
    
    //noise shape
    float f = 0.0;
    uv = p * vec2(u_Dimensions.x/u_Dimensions.y,1.0);
    uv *= cloudscale;
    uv -= q;
    weight = 0.7;
    for (int i = 0; i < 8; i++){
      f += weight * noise(uv);
      uv = m*uv;
      weight *= 0.6;
    }
      
    f *= r + f;

    //noise colour
    float c = 0.0;
    time = u_Time * speed;
    uv = p*vec2(u_Dimensions.x/u_Dimensions.y,1.0);
	  uv *= cloudscale*2.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c += weight*noise( uv );
        uv = m*uv + time;
		weight *= 0.6;
    }
    
    //noise ridge colour
    float c1 = 0.0;
    time = u_Time * speed;
    uv = p*vec2(u_Dimensions.x/u_Dimensions.y,1.0);
	  uv *= cloudscale*3.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c1 += abs(weight*noise( uv ));
        uv = m*uv + time;
		weight *= 0.6;
    }
	
    c += c1;
    
    vec3 skycolour = mix(skycolour2, skycolour1, p.y);
    vec3 cloudcolour = vec3(0.7, 0.7, 0.5) * clamp((clouddark + cloudlight*c), 0.0, 1.0);
   
    f = cloudcover + cloudalpha*f*r;
    
    vec3 result = mix(skycolour, clamp(skytint * skycolour + cloudcolour, 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    return vec4(result, 1.0);
}

void main() {
  // RAYCASTING
  // convert to NDC screen coors
  vec4 s = vec4(-1.0 * (((gl_FragCoord.x / u_Dimensions.x) * 2.0) - 1.0),
                -1.0 * (1.0 - ((gl_FragCoord.y / u_Dimensions.y) * 2.0)), 1.0, 1.0);
  vec3 dir = rayCast(s);

  // bounding boxes 
  vec3 center = vec3(0.0,0.0,5.0);
  vec3 box_min = center - vec3(-2.5, 0.2, 0.0) - vec3(7.0);
  vec3 box_max = center - vec3(-4.5, -5.0, 0.0) + vec3(0.0);
  bool bound_test = rayBoxIntersection(u_Eye, dir, box_min, box_max);

  if (bound_test) {
    // in root bounding box
    // RAYMARCHING
    vec2 march = rayMarch(u_Eye, dir);
    if (march[0] < 1000.0) {
      vec4 diffuseColor;
      if (march[1] == 1.0) {
        // hit pedestal
        vec2 st = gl_FragCoord.xy / u_Dimensions.xy;
        vec3 color = vec3(0.0);
        st /= vec2(2.15,0.85) / 1.5;
        st = brickTile(st,50.0, 1.0);
        color = vec3(box(st,vec2(0.85)));
        if (color[0] < 0.5) {
          diffuseColor = vec4(vec3(0.3),1.0);
        }
        else {
          diffuseColor = vec4(colorFxn(vec3(233.0, 190.0, 175.0)), 1.0);
        }
        
      }
      else if (march[1] == 2.0) {
        // hit sphere
        vec2 st = vec2(worl);
        st = fbm(st + fbm(st + fbm(st + fbm(st))));
        st *= st;
        st += st;
        st += st;
        st += st;
        st += st;
        float test_noise = clamp(WorleyNoise(st), 0.0, 1.0);
        if (test_noise < 0.5) {
          diffuseColor = vec4(colorFxn(vec3(180.0, 152.0, 198.0)), 1.0);
        }
        else if (test_noise < 0.7) {
          diffuseColor = vec4(colorFxn(vec3(140.0, 152.0, 198.0)), 1.0);
        }
        else {
          diffuseColor = vec4(colorFxn(vec3(160.0, 152.0, 198.0)), 1.0);
        }
      } 
      else if (march[1] == 3.0) {
        // hit city
        vec2 st = gl_FragCoord.xy / u_Dimensions.xy;
        vec3 color = vec3(0.0);
        st = brickTile(st, 80.0, 0.0);
        color = vec3(box(st,vec2(0.5)));
        if (color[0] < 0.5) {
          diffuseColor = vec4(vec3(0.0),1.0);
        }
        else {
          diffuseColor = vec4(colorFxn(vec3(240.0, 152.0, 198.0)), 1.0);
        }
      }       

      // LIGHTING
      
      if (march[1] == 1.0 || march[1] == 2.0) { // if matches specific SDF id
        vec4 lights[3];
        vec3 lightColor[3];

        // Light positions with intensity as w-component
        lights[0] = vec4(6.0, 3.0, 5.0, 2.0); // key light
        lights[1] = vec4(-6.0, 3.0, 5.0, 1.5); // fill light
        lights[2] = vec4(0.0, 15.0, 5.0, 1.0);
        
        lightColor[0] = colorFxn(vec3(120.0, 87.0, 219.0));
        lightColor[1] = colorFxn(vec3(255.0, 147.0, 207.0));
        lightColor[2] = colorFxn(vec3(150.0, 173.0, 255.0));

        vec3 sum = vec3(0.0);
        for (int j = 0; j < 3; j++) {
          // Calculate diffuse term for shading
          float diffuseTerm = dot(normalize(nor), normalize(vec3(lights[j])));
          // Avoid negative lighting values
          diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
          float ambientTerm = 0.2;
          float lightIntensity = diffuseTerm + ambientTerm;

          // Implement specular light
          vec4 H;
          for (int i = 0; i < 3; i++) {
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
    }
    else {
      // bg color
      out_Col = cloudFxn();
    }
  }
  else {
    // bg color
    out_Col = cloudFxn();
  }
}
