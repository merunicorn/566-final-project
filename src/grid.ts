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
        // this.waterCheck();
    }

    initGrid() {
        for (var i = 0; i < this.width; i++) {
            this.grid[i] = [];
            for (var j = 0; j < this.height; j++) {
                /*var random0 = Math.random();
                random0 *= -10.0;
                random0 = Math.floor(random0);

                this.grid[i][j] = new Particle(random0); // starting position is random within range*/
                this.grid[i][j] = new Particle(10);
            }
        }
    }

    /*waterCheck() {
        for (var i = 0; i < this.width; i++) {
            for (var j = 0; j < this.width; j++) {
            }
        }
    }*/

    setVBO(): any {
        let t1Array: number[] = [];
        let t2Array: number[] = [];
        let t3Array: number[] = [];
        let t4Array: number[] = [];
        let colArray: number[] = [];

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

                //t4Array.push(i);
                t4Array.push((i - this.width / 2)); // x transformation
                t4Array.push(10); // y transformation
                //t4Array.push(j);
                t4Array.push((j - this.height / 2)); // z transformation
                t4Array.push(1);

                colArray.push(0);
                colArray.push(0);
                colArray.push(0.5);
                colArray.push(1);
            }
        }

        let t1: Float32Array = new Float32Array(t1Array);
        let t2: Float32Array = new Float32Array(t2Array);
        let t3: Float32Array = new Float32Array(t3Array);
        let t4: Float32Array = new Float32Array(t4Array);
        let col: Float32Array = new Float32Array(colArray);

        let outVBO: any = {};
        outVBO.transf1Array = t1;
        outVBO.transf2Array = t2;
        outVBO.transf3Array = t3;
        outVBO.transf4Array = t4;
        outVBO.colorsArray = col;

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

        console.log("f1:" + f1Array);
        console.log("f2:" + f2Array);
        console.log("f3:" + f3Array);
        console.log("f4:" + f4Array);
        console.log("f5:" + f5Array);
        console.log("f6:" + f6Array);
        console.log("f7:" + f7Array);
        console.log("f8:" + f8Array);
        console.log("f9:" + f9Array);
        console.log("f10:" + f10Array);
        console.log("f11:" + f11Array);
        console.log("f12:" + f12Array);

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
}

export default Grid;