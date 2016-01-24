$fs = 1;
$fa = 6;
module _ry() {
    rotate([90,0]) children();
}
module _rx() {
    rotate([0,90,0]) children();
}
module wedge(d, h, center, arc) {
    hull() {
        cylinder(d=0.1, h=h, center=center);
        rotate([0,0,arc/2]) translate([0, d*2]) cylinder(d=0.1, h=h, center=center);
        rotate([0,0,-arc/2]) translate([0, d*2]) cylinder(d=0.1, h=h, center=center);
        translate([0, d*2]) cylinder(d=0.1, h=h, center=center);
    }
}
module _arcOfCyl(d, h, center=true, arc=90) {
    if (arc > 180) {
        difference() {
            cylinder(d=d, h=h, center=center);
            wedge(d=d, h=h + 1, center=center, arc=360 - arc);
        }
    } else {
        intersection() {
            cylinder(d=d, h=h, center=center);
            wedge(d=d, h=h + 1, center=center, arc=arc);
        }
    }
}

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
    translate([0,0,5]) moveToLowerBolt() {
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
        bolts();
        waterBottle();
        for (ii=[-1:2:1]) {
            translate([11 - (2 + inflateCutout)/2,ii * wid/2,7 - inflateCutout])
                moveToLowerBolt()
                    rotate([ii*15,0]) hull() {
                        translate([0, ii*2]) cube(size=[6 + inflateCutout, 1, 16 + inflateCutout], center=true);
                        translate([0, -ii*(1 + inflateCutout/2)]) cylinder(d=0.1, h=20 + inflateCutout, center=true);
                    }
        }
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
                    translate([-boltZoffset, 0]) {
                        oct(d=wid, h=14, center = true);
                    }
                }
                // arm to secure the bottle from above
                translate([0,0, boltZoffset + 2]) rotate([0, 15, 0]) {
                    hull() {
                        _ry() cylinder(d=10, h=wid, center=true);
                        translate([0,0, 40]) _ry() cylinder(d=5, h=wid, center=true);
                    }
                    // ball thing that fits in the bottle dimple thing
                    translate([0,0,40 + 22/2 - 2.5]) {
                        rotate([0,105]) difference() {
                            _ry() _arcOfCyl(d=22, h=wid, center=true, arc=150);
                            translate([-1,0,0]) _ry() cylinder(d=22-8, h=wid+1, center=true);
                        }
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
        bolts();
        bikeTube();
        hull() wings();
        waterBottle();
        translate([-bikeTubeD/2,0,-25]) moveToLowerBolt() cylinder(d=40, h=20, center=false);
    }

}
wingTopAngle = 10;
module wings(inflate=0) {
    height = wingHeight + inflate;
    difference() {
        moveToWingZ() intersection() {
            hull() {
                translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
                wingBase(height);
            }
            // angle the top
            translate([0,0,-1]) rotate([0,wingTopAngle]) cube(size=[waterBottleD * 3, waterBottleD * 2, height * 2], center=true);
            // angle the bottom
            translate([0,0,80]) rotate([0,45 + wingTopAngle]) cube(size=[waterBottleD * 2, waterBottleD * 2, height * 4], center=true);
        }
        bolts();
        waterBottle();
        translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=200, center=false);

        // cutout the wings
        hull() {
           translate([0,0,15]) moveToLowerBolt() _ry() cylinder(d=1, h=waterBottleD + 25, center=true);
           rotate([0, wingTopAngle]) translate([-5,0,boltZoffset * 0.9]) moveToWaterBottle() moveToLowerBolt() _ry() cylinder(d=8, h=waterBottleD + 25, center=true);
           translate([0,0,boltZoffset - 5]) moveToLowerBolt() _ry() cylinder(d=1, h=waterBottleD + 25, center=true);
        }
        // ease the transition at the bottom of the cutout when printing
        // upside-down
        translate([waterBottleOffset - 5,0,21]) moveToLowerBolt() rotate([0, -45]) hull() {
            cylinder(d=1, h=20, center=true);
            translate([11,0,-4]) _ry() cylinder(d=1, h=40, center=true);
        }
        waterBottle();
        translate([1,0,0]) bottomSupport(1, 0.5);
    }
}

if (false) {
    // display in place
    wings();
    minBase();
    bottomSupport();
} else {
    // lay out for printing
    moveToWingZ() translate([60,-10,boltZoffset + 12.5]) rotate([180,wingTopAngle,0])
        wings();
    rotate([90,0,40]) {
        minBase();
        bottomSupport();
    }
}
