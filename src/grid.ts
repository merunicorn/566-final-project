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
        this.waterCheck();
    }

    initGrid() {
        for (var i = 0; i < this.width; i++) {
            this.grid[i] = [];
            for (var j = 0; j < this.height; j++) {
                this.grid[i][j] = new Particle(0);
            }
        }
    }

    waterCheck() {
        for (var i = 0; i < this.width; i++) {
            for (var j = 0; j < this.width; j++) {
            }
        }
    }

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
                t4Array.push(0); // y transformation
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
}

export default Grid;