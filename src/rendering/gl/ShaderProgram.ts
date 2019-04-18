import {vec3, vec4, mat4, mat3} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram {
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;

  attrTransform1: number; // Mesh transformation data
  attrTransform2: number; // Mesh transformation data
  attrTransform3: number; // Mesh transformation data
  attrTransform4: number; // Mesh transformation data

  unifModel: WebGLUniformLocation;
  unifModelInvTr: WebGLUniformLocation;
  unifViewProj: WebGLUniformLocation;
  unifCameraAxes: WebGLUniformLocation;
  unifTime: WebGLUniformLocation;
  unifRef: WebGLUniformLocation;
  unifEye: WebGLUniformLocation;
  unifUp: WebGLUniformLocation;
  unifDimensions: WebGLUniformLocation;

  constructor(shaders: Array<Shader>) {
    this.prog = gl.createProgram();

    for (let shader of shaders) {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos = gl.getAttribLocation(this.prog, "vs_Pos");
    this.attrNor = gl.getAttribLocation(this.prog, "vs_Nor");
    this.attrCol = gl.getAttribLocation(this.prog, "vs_Col");
    
    this.attrTransform1 = gl.getAttribLocation(this.prog, "vs_Transf1");
    this.attrTransform2 = gl.getAttribLocation(this.prog, "vs_Transf2");
    this.attrTransform3 = gl.getAttribLocation(this.prog, "vs_Transf3");
    this.attrTransform4 = gl.getAttribLocation(this.prog, "vs_Transf4");

    this.unifModel      = gl.getUniformLocation(this.prog, "u_Model");
    this.unifModelInvTr = gl.getUniformLocation(this.prog, "u_ModelInvTr");
    this.unifViewProj   = gl.getUniformLocation(this.prog, "u_ViewProj");
    this.unifCameraAxes      = gl.getUniformLocation(this.prog, "u_CameraAxes");
    this.unifTime      = gl.getUniformLocation(this.prog, "u_Time");
    this.unifEye   = gl.getUniformLocation(this.prog, "u_Eye");
    this.unifRef   = gl.getUniformLocation(this.prog, "u_Ref");
    this.unifUp   = gl.getUniformLocation(this.prog, "u_Up");
  }

  use() {
    if (activeProgram !== this.prog) {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }

  setEyeRefUp(eye: vec3, ref: vec3, up: vec3) {
    this.use();
    if(this.unifEye !== -1) {
      gl.uniform3f(this.unifEye, eye[0], eye[1], eye[2]);
    }
    if(this.unifRef !== -1) {
      gl.uniform3f(this.unifRef, ref[0], ref[1], ref[2]);
    }
    if(this.unifUp !== -1) {
      gl.uniform3f(this.unifUp, up[0], up[1], up[2]);
    }
  }

  setDimensions(width: number, height: number) {
    this.use();
    if(this.unifDimensions !== -1) {
      gl.uniform2f(this.unifDimensions, width, height);
    }
  }

  setModelMatrix(model: mat4) {
    this.use();
    if (this.unifModel !== -1) {
      gl.uniformMatrix4fv(this.unifModel, false, model);
    }

    if (this.unifModelInvTr !== -1) {
      let modelinvtr: mat4 = mat4.create();
      mat4.transpose(modelinvtr, model);
      mat4.invert(modelinvtr, modelinvtr);
      gl.uniformMatrix4fv(this.unifModelInvTr, false, modelinvtr);
    }
  }

  setViewProjMatrix(vp: mat4) {
    this.use();
    if (this.unifViewProj !== -1) {
      gl.uniformMatrix4fv(this.unifViewProj, false, vp);
    }
  }

  setCameraAxes(axes: mat3) {
    this.use();
    if (this.unifCameraAxes !== -1) {
      gl.uniformMatrix3fv(this.unifCameraAxes, false, axes);
    }
  }

  setTime(t: number) {
    this.use();
    if (this.unifTime !== -1) {
      gl.uniform1f(this.unifTime, t);
    }
  }

  draw(d: Drawable) {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrCol != -1 && d.bindCol()) {
      gl.enableVertexAttribArray(this.attrCol);
      gl.vertexAttribPointer(this.attrCol, 4, gl.FLOAT, false, 0, 0);
      gl.vertexAttribDivisor(this.attrCol, 1); // Advance 1 index in col VBO for each drawn instance
    }

    if (this.attrTransform1 != -1 && d.bindTransform1()) {
      gl.enableVertexAttribArray(this.attrTransform1);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform1, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform1, 1);
    }
    if (this.attrTransform2 != -1 && d.bindTransform2()) {
      gl.enableVertexAttribArray(this.attrTransform2);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform2, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform2, 1);
    }
    if (this.attrTransform3 != -1 && d.bindTransform3()) {
      gl.enableVertexAttribArray(this.attrTransform3);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform3, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform3, 1);
    }
    if (this.attrTransform4 != -1 && d.bindTransform4()) {
      gl.enableVertexAttribArray(this.attrTransform4);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform4, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform4, 1);
    }

    d.bindIdx();
    gl.drawElementsInstanced(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0, d.numInstances);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);
    if (this.attrCol != -1) gl.disableVertexAttribArray(this.attrCol);
    if (this.attrTransform1 != -1) gl.disableVertexAttribArray(this.attrTransform1);
    if (this.attrTransform2 != -1) gl.disableVertexAttribArray(this.attrTransform2);
    if (this.attrTransform3 != -1) gl.disableVertexAttribArray(this.attrTransform3);
    if (this.attrTransform4 != -1) gl.disableVertexAttribArray(this.attrTransform4);
  }
};

export default ShaderProgram;
