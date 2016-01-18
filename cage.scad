$fs = 1;
$fa = 6;

bikeTubeD = 32;
waterBottleD = 72;
waterBottleOffset = 15;

module bikeTube(args) {
    translate([-bikeTubeD/2,0,0]) cylinder(d=bikeTubeD, h=200, center=false);
}
module insert() {
    rotate([0,90]) cylinder(d=10, h=4.5, center=true);
}
module thruHole() {
    rotate([0,90]) cylinder(d=6, h=50, center=true);
}
module head() {
    rotate([0,90]) translate([0,0,10]) cylinder(d=10, h=50, center=false);
}
module bolt() {
    insert();
    thruHole();
    head();
}
boltZoffset = 66.3;
module bolts() {
    translate([0,0, 20]) {
        hull() {
            translate([0,0,1]) insert();
            translate([0,0,-1]) insert();
        }
        hull() {
            translate([0,0,1]) thruHole();
            translate([0,0,-1]) thruHole();
        }
        hull() {
            translate([0,0,1]) head();
            translate([0,0,-1]) head();
        }
        translate([0,0,boltZoffset]) bolt();
    }
}
module moveToWaterBottle() {
    translate([waterBottleD/2 + waterBottleOffset,0,0])
        children();
}
module waterBottle() {
    moveToWaterBottle() {
        translate([0,0,10]) minkowski() {
            cylinder(d=53, h=124, center=false);
            sphere(d=20);
        }
        translate([0, 0, 140]) {
            difference() {
                cylinder(d=waterBottleD, h=25, center=false);
                translate([0,0,7]) rotate_extrude() {
                    translate([waterBottleD/2,5,0]) scale([1,2,1]) circle(d=12.5);
                }
            }
        }
        translate([0,0,165]) cylinder(d=waterBottleD, h=100, center=false);
    }
}
module cutoutAssembly() {
    translate([0,0,5]) {
        waterBottle();
        bolts();
    }
    bikeTube();
}
wid = 20;
module base() {
    difference() {
        hull() {
            translate([-5, 0, 15 + 80/2]) cube(size=[2, wid, 80], center=true);
            translate([10, 0, 100/2]) cube(size=[2, wid, 100], center=true);
            translate([25, 0, 175/2]) cube(size=[2, wid, 175], center=true);
            translate([45, 0]) cylinder(d=wid, h=20, center=false);

        }
        cutoutAssembly();
        wings(1);
    }
}
module wings(inflate=0) {
    height = boltZoffset + 20 + inflate;
    difference() {
        translate([0,0,15]) hull() {
            translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
            translate([-2,0,0]) moveToWaterBottle() cylinder(d=waterBottleD + 10, h=height, center=false);
        }
        translate([0,0,5]) {
            bolts();
            waterBottle();
        }
        hull() {
            moveToWaterBottle() cylinder(d=waterBottleD * 1.5, h=1, center=false);
            translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=80, center=false);
           }
           translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=200, center=false);
    }
}
*base();
wings();
