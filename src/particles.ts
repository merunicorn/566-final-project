import {vec2} from 'gl-matrix';
import { truncate } from 'fs';

class Particle {
    posi: number;
    veli: number;
    accel: number;
    posf: number;
    velf: number;

    constructor(p: number) {
        // p is position of particle on y axis
        // set up initial p,v,a
        this.posi = p;
        this.veli = 0;

        this.posf = p; 
        this.velf = 0;
        this.accel = -9.8; // gravity in m/s^2; currently not normalized for our dimensions
    }

    getNewPos(deltat: number) {
        // pass in change in time since last getNewPos call
        // equation of motion

        // drag = true: acceleration taken into account
        // drag = false: constant velocity (mimics the range of rain we
        //               see looking constant since start point is so high up)
        var drag = false; 
        if (drag) {
            this.velf = -10.0;
            this.posf = this.posi + this.velf * deltat;
        }
        else {
            this.posf = this.posi + this.velf * deltat;
            this.velf = this.veli + this.accel * deltat;
        }

        // respawn at top if hits some 'ground' value
        if (this.posf < -10) { // 'ground' value / min height
            this.posf = 10; // 'sky' value / max height
            if (!drag) {
                this.velf = 0; // reset velocity since particle has totally reset
            }
        }
        
        // update parameters; new initial pos/vel
        this.posi = this.posf;
        this.veli = this.velf;

        // return new posf
        return this.posf;
    }
}

export default Particle;