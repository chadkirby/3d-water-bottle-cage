$fs = 1;
$fa = 6;

bikeTubeD = 32;
waterBottleD = 72;
waterBottleOffset = 15;

module bikeTube(inflate=0) {
    translate([-bikeTubeD/2,0,0]) cylinder(d=bikeTubeD + 2*inflate, h=200, center=false);
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
module moveToLowerBolt() {
    translate([0,0, 20]) children();
}
module bolts() {
    moveToLowerBolt() {
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
waterBottleRadius = 20;
module waterBottle() {
    moveToWaterBottle() {
        hull() {
                rotate_extrude() {
                    translate([waterBottleD/2 - waterBottleRadius/2,waterBottleRadius/2,0]) circle(d=waterBottleRadius);
                }
                translate([0,0,122 - waterBottleRadius/2]) {
                        rotate_extrude() {
                            translate([waterBottleD/2 - waterBottleRadius/2,waterBottleRadius/2,0]) circle(d=waterBottleRadius);
                        }
                    }
            }
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
wingHeight = boltZoffset + 20;
module moveToWingZ() {
    translate([0,0,15]) children();
}
module wingBase(height) {
    translate([-2,0,0]) moveToWaterBottle() cylinder(d=waterBottleD + 9, h=height, center=false);
}
module oct(h, d, center) {
    rotate([0,0,180/8]) {
        cylinder(d=d/cos(180/8), $fn=8, h=h, center=center);
    }
}
module bottomSupport(inflateShell=0, inflateCutout=1) {
    difference() {
        translate([3.5,0,0]) hull() {
            moveToLowerBolt() translate([5,0,7]) rotate([0, 90, 0]) oct(d=wid + inflateShell, h=12, center = true);

            translate([-15,0,-5]) moveToWaterBottle() cylinder(d = wid + inflateShell, h=5, center=false);

            translate([16,0,5]) rotate([90,0]) cylinder(d = 20, h=wid + inflateShell, center=true);
        }
        translate([0,0,5]) bolts();
        translate([-1,0,0]) waterBottle();
        for (ii=[-1:2:1]) {
            translate([10 - (2 + inflateCutout)/2,ii * wid/2,7 - inflateCutout]) moveToLowerBolt() cube(size=[2 + inflateCutout, 4, 16], center=true);
        }

        *wings();
    }
}
module minBase() {
    difference() {
        translate([0,0,5]) {
            moveToLowerBolt() {
                rotate([0, 90, 0]) {
                    hull() {
                        // lower
                        translate([-2,0,0]) oct(d=wid, h=12, center = true);
                        translate([4,0,0]) oct(d=wid, h=12, center = true);
                    }
                    hull() {
                        translate([-boltZoffset, 0]) {
                            oct(d=wid, h=12, center = true);
                            *translate([-25, 0, 0]) oct(d=wid, h=15, center = true);
                        }
                    }
                    *hull() {
                        // upper
                        translate([-boltZoffset, 0]) {
                            translate([-25, 0, 0]) oct(d=wid, h=15, center = true);
                            translate([-50, 0, 20]) oct(d=wid, h=6, center = true);
                        }
                    }
                    hull() {
                        translate([-boltZoffset,0]) rotate([90,0]) cylinder(d=5, h=wid, center=true);
                        translate([-boltZoffset - 42,0, 15]) rotate([90,0]) cylinder(d=5, h=wid, center=true);
                    }
                    difference() {
                        translate([-boltZoffset - 47,0, 10]) rotate([90,0]) cylinder(d=20, h=wid, center=true);
                        translate([-boltZoffset - 50,0, 4.5]) rotate([0,20,0]) cube(size=[30, wid+1, 20], center=true);
                    }
                }
                intersection() {
                    translate([0,0,-10]) difference() {
                        bikeTube(2);
                        bikeTube();
                    }
                    translate([0,0,(boltZoffset)/2]) cube(size=[50, wid, boltZoffset], center=true);
                }
            }
        }
        translate([0,0,5]) {
            bolts();
        }
        bikeTube();
        translate([-1,0]) {
            hull() wings();
            waterBottle();
        }
        translate([-bikeTubeD/2,0,-25]) moveToLowerBolt() cylinder(d=40, h=20, center=false);
    }

}
module wings(inflate=0) {
    height = wingHeight + inflate;
    difference() {
        moveToWingZ() intersection() {
            hull() {
                translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
                wingBase(height);
            }
            translate([0,0,-1]) rotate([0,15]) cube(size=[waterBottleD * 2, waterBottleD * 2, height * 2], center=true);
            translate([0,0,80]) rotate([0,60]) cube(size=[waterBottleD * 2, waterBottleD * 2, height * 4], center=true);
        }
        translate([0,0,5]) {
            bolts();
            waterBottle();
        }
       translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=200, center=false);

        hull() {
           translate([-90,0,25]) scale([1,2,1]) cylinder(d=waterBottleD * 2, h=1, center=false);
           translate([2,0,77]) moveToWaterBottle()
                rotate([0,15]) cylinder(d=waterBottleD - 2, h=1, center=false);
        }
        translate([0,0,78]) cube(size=[30, 20, 10], center=true);
        waterBottle();
        translate([0.5,0,0]) bottomSupport(1, 0.5);
    }
}
*base();
*waterBottle();
moveToWingZ() translate([60,-10,boltZoffset + 12.5]) rotate([180,15,0])
     // translate([-0.5,0])
    wings();
rotate([90,0,40])
{
    minBase();
    bottomSupport();
}
