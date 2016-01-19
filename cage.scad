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
        *import("bottle-base.stl", convexity=3);
        translate([0,0,10]) minkowski() {
            cylinder(d=53, h=112, center=false);
            sphere(d=20);
        }
        translate([0, 0, 128]) {
            difference() {
                cylinder(d=waterBottleD, h=25, center=false);
                *translate([0,0,7]) rotate_extrude() {
                    translate([waterBottleD/2,5,0]) scale([1,2,1]) circle(d=12.5);
                }
                translate([0,0,7]) rotate_extrude() {
                    translate([waterBottleD/2,5,0]) scale([1,1.75,1]) circle(d=12.5);
                }
            }
        }
        translate([0,0,153]) cylinder(d=waterBottleD, h=100, center=false);
    }
}
module cutoutAssembly() {
    translate([0,0,5]) {
        waterBottle();
        bolts();
    }
    bikeTube();
}
wid = 12;
module base() {
    difference() {
        hull() {
            translate([-5, 0, 15 + 80/2]) cube(size=[2, wid, 80], center=true);
            translate([10, 0, 100/2]) cube(size=[2, wid, 100], center=true);
            translate([28, 0, 170/2]) cube(size=[2, wid, 170], center=true);
            translate([45, 0]) rotate([0,0,180/8]) cylinder(d=wid/cos(180/8), $fn=8, h=20, center=false);

        }
        cutoutAssembly();
        moveToWingZ() {
            hull() {
                wingBase(wingHeight + 10);
                moveToWaterBottle() translate([0,0,wingHeight + 32]) cylinder(d=waterBottleD, h=1, center=true);

            }
        }
    }
}
wingHeight = boltZoffset + 20;
module moveToWingZ(args) {
    translate([0,0,15]) children();
}
module wingBase(height) {
    translate([-2,0,0]) moveToWaterBottle() cylinder(d=waterBottleD + 9, h=height, center=false);
}
module wings(inflate=0) {
    height = wingHeight + inflate;
    difference() {
        moveToWingZ() intersection() {
            hull() {
                translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
                wingBase(height);
            }
            hull() {
                translate([-55,0,0]) scale([0.4,1.5,1]) cylinder(d=waterBottleD * 4, h=1, center=false);

                cylinder(d=30, h=25, center=false);

                 translate([0,0,70]) moveToWaterBottle() cylinder(d=waterBottleD + 10, h=20, center=false);
               }
        }
        translate([0,0,5]) {
            bolts();
            waterBottle();
        }
       translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=200, center=false);

        hull() {
           translate([-90,0,15]) scale([1,2,1]) cylinder(d=waterBottleD * 2, h=1, center=false);
            translate([0,0,85]) moveToWaterBottle() cylinder(d=70, h=1, center=false);
          }
    }
}
*base();
wings();
