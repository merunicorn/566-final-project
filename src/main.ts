import {vec3, mat4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import ScreenQuad from './geometry/ScreenQuad';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

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

function loadScene() {
  square = new Square();
  square.create();
  screenQuad = new ScreenQuad();
  screenQuad.create();

  
  g = new Grid(10, 10);
  let gVBO = g.setVBO();

  let colors: Float32Array = new Float32Array(gVBO.colorsArray);
  let transf1: Float32Array = new Float32Array(gVBO.transf1Array);
  let transf2: Float32Array = new Float32Array(gVBO.transf2Array);
  let transf3: Float32Array = new Float32Array(gVBO.transf3Array);
  let transf4: Float32Array = new Float32Array(gVBO.transf4Array);

  square.setNumInstances(100); // grid of "particles"
  square.setInstanceVBOs(colors, transf1, transf2, transf3, transf4);

  console.log(transf4);

  let r = 10.0; // changes speed ??
  let fVBO = g.setFallVBO(r);
  let f1 = fVBO.fall1Array;
  let f2 = fVBO.fall2Array;
  let f3 = fVBO.fall3Array;
  let f4 = fVBO.fall4Array;
  fallmat = mat4.fromValues(f1[0], f1[1], f1[2], f1[3],
                            f2[0], f2[1], f2[2], f2[3],
                            f3[0], f3[1], f3[2], f3[3],
                            f4[0], f4[1], f4[2], f4[3]);
  console.log(fallmat);
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

  const camera = new Camera(vec3.fromValues(50, 50, 50), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);
  // gl.enable(gl.BLEND);
  // gl.blendFunc(gl.ONE, gl.ONE); // Additive blending

  const instancedShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/instanced-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/instanced-frag.glsl')),
  ]);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    instancedShader.setTime(time);
    flat.setTime(time++);
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    renderer.render(camera, flat, [screenQuad], fallmat);
    renderer.render(camera, instancedShader, [
      square,
    ], fallmat);
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
