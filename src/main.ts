import {vec3, mat4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import ScreenQuad from './geometry/ScreenQuad';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Texture from './rendering/gl/Texture';

import Particle from './particles';
import Grid from './grid';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
};

let square: Square;
let screenQuad: ScreenQuad;
let time: number = 0.0;

let g: Grid;
let fallmat: mat4;
let fallmat2: mat4;
let fallmat3: mat4;

// TEXTURES
let splashTex1: Texture;
let splashTex2: Texture;
let testTex2: Texture;
let cobbleTex: Texture;

function loadScene() {
  square = new Square();
  square.create();
  screenQuad = new ScreenQuad();
  screenQuad.create();

  let w = 12;
  g = new Grid(w, w);
  let gVBO = g.setVBO();

  let pVBO = g.setPosVBO();
  let p: Float32Array = new Float32Array(pVBO.posArray);

  let transf1: Float32Array = new Float32Array(gVBO.transf1Array);
  let transf2: Float32Array = new Float32Array(gVBO.transf2Array);
  let transf3: Float32Array = new Float32Array(gVBO.transf3Array);
  let transf4: Float32Array = new Float32Array(gVBO.transf4Array);

  square.setNumInstances(w*w); // grid of "particles"
  square.setInstanceVBOs(p, transf1, transf2, transf3, transf4);

  let r = 24.0; // changes speed
  let fVBO = g.setFallVBO(r);
  let f1 = fVBO.f1Array;
  let f2 = fVBO.f2Array;
  let f3 = fVBO.f3Array;
  let f4 = fVBO.f4Array;
  let f5 = fVBO.f5Array;
  let f6 = fVBO.f6Array;
  let f7 = fVBO.f7Array;
  let f8 = fVBO.f8Array;
  let f9 = fVBO.f9Array;
  let f10 = fVBO.f10Array;
  let f11 = fVBO.f11Array;
  let f12 = fVBO.f12Array;
  fallmat = mat4.fromValues(f1[0], f1[1], f1[2], f1[3],
                            f2[0], f2[1], f2[2], f2[3],
                            f3[0], f3[1], f3[2], f3[3],
                            f4[0], f4[1], f4[2], f4[3]);
  fallmat2 = mat4.fromValues(f5[0], f5[1], f5[2], f5[3],
                            f6[0], f6[1], f6[2], f6[3],
                            f7[0], f7[1], f7[2], f7[3],
                            f8[0], f8[1], f8[2], f8[3]);
  fallmat3 = mat4.fromValues(f9[0], f9[1], f9[2], f9[3],
                            f10[0], f10[1], f10[2], f10[3],
                            f11[0], f11[1], f11[2], f11[3],
                            f12[0], f12[1], f12[2], f12[3]);                          

  splashTex1 = new Texture('../textures/test/splash1.png', 0);
  splashTex2 = new Texture('../textures/test/splash2.png', 0);
  testTex2 = new Texture('../textures/test/rain2.png', 1);
  cobbleTex = new Texture('../textures/test/rain2.png', 2);
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  //const camera = new Camera(vec3.fromValues(50, 50, 50), vec3.fromValues(0, 0, 0));
  const camera = new Camera(vec3.fromValues(0, 0, -20), vec3.fromValues(0, 0, 5.0));
  

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);
  gl.enable(gl.BLEND);
  gl.blendFunc(gl.ONE, gl.ONE); // Additive blending

  const instancedShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/instanced-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/instanced-frag.glsl')),
  ]);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  instancedShader.bindTexToUnit(instancedShader.unifSampler1, splashTex1, 0);
  instancedShader.bindTexToUnit(instancedShader.unifSampler3, splashTex2, 2);
  instancedShader.bindTexToUnit(instancedShader.unifSampler2, testTex2, 1);
  flat.bindTexToUnit(flat.unifSampler1, splashTex1, 0);
  flat.bindTexToUnit(flat.unifSampler3, splashTex2, 2);
  flat.bindTexToUnit(flat.unifSampler2, testTex2, 1);
  flat.bindTexToUnit(flat.unifSampler4, cobbleTex, 3);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    instancedShader.setTime(time);
    flat.setTime(time++);
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    renderer.render(camera, flat, [screenQuad], fallmat, fallmat2, fallmat3);
    renderer.render(camera, instancedShader, [
      square,
    ], fallmat, fallmat2, fallmat3);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
    flat.setDimensions(window.innerWidth, window.innerHeight);
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();
  flat.setDimensions(window.innerWidth, window.innerHeight);

  // Start the render loop
  tick();
}

main();
