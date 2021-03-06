import { vec2 } from 'gl-matrix';
import Particle from './particles';

class Grid {
    width: number;
    height: number;
    grid: Particle[][];

    constructor(w: number, h: number) {
        this.width = w;
        this.height = h;
        this.grid = [];
        this.initGrid();
    }

    initGrid() {
        for (var i = 0; i < this.width; i++) {
            this.grid[i] = [];
            for (var j = 0; j < this.height; j++) {
                this.grid[i][j] = new Particle(15);
            }
        }
    }

    setVBO(): any {
        let t1Array: number[] = [];
        let t2Array: number[] = [];
        let t3Array: number[] = [];
        let t4Array: number[] = [];

        let rad = 90 * Math.PI / 180;

        for (var i = 0; i < this.width; i++) {
            for (var j = 0; j < this.height; j++) {
                t1Array.push(1);
                t1Array.push(0);
                t1Array.push(0);
                t1Array.push(0);

                t2Array.push(0);
                t2Array.push(Math.cos(rad));
                t2Array.push(Math.sin(rad));
                t2Array.push(0);

                t3Array.push(0);
                t3Array.push(Math.sin(rad) * -1);
                t3Array.push(Math.cos(rad));
                t3Array.push(0);

                t4Array.push((i - this.width / 2)); // x transformation
                t4Array.push(10); // y transformation
                t4Array.push((j - this.height / 2)); // z transformation
                t4Array.push(1);
            }
        }

        let t1: Float32Array = new Float32Array(t1Array);
        let t2: Float32Array = new Float32Array(t2Array);
        let t3: Float32Array = new Float32Array(t3Array);
        let t4: Float32Array = new Float32Array(t4Array);

        let outVBO: any = {};
        outVBO.transf1Array = t1;
        outVBO.transf2Array = t2;
        outVBO.transf3Array = t3;
        outVBO.transf4Array = t4;

        return outVBO;
    }

    setFallVBO(r: number): any {
        let f1Array: number[] = [];
        let f2Array: number[] = [];
        let f3Array: number[] = [];
        let f4Array: number[] = [];

        let f5Array: number[] = [];
        let f6Array: number[] = [];
        let f7Array: number[] = [];
        let f8Array: number[] = [];

        let f9Array: number[] = [];
        let f10Array: number[] = [];
        let f11Array: number[] = [];
        let f12Array: number[] = [];

        for (var k = 0; k < 4; k++) {
            f1Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f2Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f3Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f4Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }

        for (var k = 0; k < 4; k++) {
            f5Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f6Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f7Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f8Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }

        for (var k = 0; k < 4; k++) {
            f9Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f10Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f11Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }
        for (var k = 0; k < 4; k++) {
            f12Array.push(this.grid[0][0].getNewPos(1.0 / r));
        }

        let f1: Float32Array = new Float32Array(f1Array);
        let f2: Float32Array = new Float32Array(f2Array);
        let f3: Float32Array = new Float32Array(f3Array);
        let f4: Float32Array = new Float32Array(f4Array);
        let f5: Float32Array = new Float32Array(f5Array);
        let f6: Float32Array = new Float32Array(f6Array);
        let f7: Float32Array = new Float32Array(f7Array);
        let f8: Float32Array = new Float32Array(f8Array);
        let f9: Float32Array = new Float32Array(f9Array);
        let f10: Float32Array = new Float32Array(f10Array);
        let f11: Float32Array = new Float32Array(f11Array);
        let f12: Float32Array = new Float32Array(f12Array);

        let outVBO: any = {};
        outVBO.f1Array = f1;
        outVBO.f2Array = f2;
        outVBO.f3Array = f3;
        outVBO.f4Array = f4;
        outVBO.f5Array = f5;
        outVBO.f6Array = f6;
        outVBO.f7Array = f7;
        outVBO.f8Array = f8;
        outVBO.f9Array = f9;
        outVBO.f10Array = f10;
        outVBO.f11Array = f11;
        outVBO.f12Array = f12;
        return outVBO;
    }

    setPosVBO(): any {
        let p1Array: number[] = [];

        for (var i = 0; i < this.width; i++) {
            for (var j = 0; j < this.height; j++) {
                var random0 = Math.random();
                random0 *= 48.0;
                random0 = Math.floor(random0);
                // random pos between 1-48
                // corresponds to fall matrix index
                p1Array.push(random0); 
            }
        }

        let p1: Float32Array = new Float32Array(p1Array);

        let outVBO: any = {};
        outVBO.posArray = p1;

        return outVBO;
    }
}

export default Grid;