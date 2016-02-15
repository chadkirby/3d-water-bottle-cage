$fs = 1;
$fa = 6;
module _ry() {
    rotate([90,0]) children();
}
module _rx() {
    rotate([0,90]) children();
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
waterBottleOffset = 10;

module bikeTube(inflate=0) {
    translate([-bikeTubeD/2,0,0]) cylinder(d=bikeTubeD + 2*inflate, h=200, center=false);
}
module insert() {
    _rx() cylinder(d=11.5, h=4.5, center=true);
}
module thruHole() {
    _rx() cylinder(d=6, h=50, center=true);
}
module head() {
    _rx() translate([0,0,waterBottleOffset - 5]) cylinder(d=10.5, h=50, center=false);
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
wid = 13.5;
wingHeight = boltZoffset + 20;
module moveToWingZ() {
    translate([0,0,15]) children();
}
module wingBase(height) {
    translate([-2,0,0]) moveToWaterBottle() cylinder(d=waterBottleD + 8, h=height, center=false);
}
module oct(h, d, center) {
    rotate([0,0,180/8]) {
        cylinder(d=d/cos(180/8), $fn=8, h=h, center=center);
    }
}
module bottomSupport(inflateShell=0, inflateCutout=1) {
    difference() {
        translate([3,0,0]) union() {
            hull() {
                translate([-15,0,-5]) moveToWaterBottle() rotate([0,0,180/8]) cylinder(d = (wid + inflateShell)/cos(180/8), $fn=8, h=5, center=false);

                translate([waterBottleOffset + 7.5,0,10]) _ry() rotate([0,0,135])
                 _arcOfCyl(arc=90, d = 30, h=wid + inflateShell, center=true);
            }
            moveToLowerBolt() _rx() cube(size=[20, wid, 15], center=true);
        }
        waterBottle();
    }
}
module base() {
    difference() {
        union() {
            bottomSupport();
            translate([0,0,5]) {
                moveToLowerBolt() {
                    _rx() {
                        // lower
                        translate([1.5,0,0]) cube(size=[wid+3, wid, 10], center=true);
                        translate([-boltZoffset, 0]) {
                            cube(size=[wid, wid, 14], center=true);
                        }
                    }
                    // arm to secure the bottle from above
                    translate([0,0, boltZoffset + 2]) {
                        hull() {
                            translate([0,0, 0]) _ry() cylinder(d=5, h=wid, center=true);
                            translate([0,0, 10]) _ry() cylinder(d=5, h=wid, center=true);
                            rotate([0, 15, 0]) translate([0,0, 40]) _ry() cylinder(d=5, h=wid, center=true);
                        }
                        // ball thing that fits in the bottle dimple thing
                        rotate([0, 15, 0]) translate([0,0,40 + 22/2 - 3.5]) {
                            rotate([0,105]) difference() {
                                _ry() _arcOfCyl(d=20, h=wid, center=true, arc=150);
                                translate([-2,0,0]) _ry() cylinder(d=22-8, h=wid+1, center=true);
                            }
                        }
                    }
                    // long skinny body between the screws
                    intersection() {
                        translate([0,0,-10]) difference() {
                            bikeTube(2);
                            bikeTube();
                        }
                        translate([0,0,(boltZoffset)/2]) cube(size=[50, wid, boltZoffset], center=true);
                    }
                }
            }
        }
        bolts();
        bikeTube();
        hull() wings(noBlock = true);
        moveToWingZ() wingBlock(0.5);
        // radius the transition into the lower support
        translate([-1,0,-10]) moveToLowerBolt() _ry() cylinder(d=13, h=wid+1, center=true);

    }

}
module wingBlock(inflate = 0) {
    // align the lower wing thing with the lower base
    height = 2 + inflate;
    translate([4,0,-3]) moveToLowerBolt() _rx() translate([6,0,0])
    hull() {
        translate([0,0,height/2]) cube(size=[13 + inflate, wid, 0.1], center=true);
        translate([0,0,-height/2]) cube(size=[13 + inflate, 0.1, 0.1], center=true);
    }
}
wingTopAngle = 10;
module wings(inflate = 0, noBlock=false) {
    height = wingHeight;
    color("LightBlue", 0.75) difference() {
        moveToWingZ() intersection() {
            union() {
                hull() {
                    translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
                    wingBase(height);
                }
                if (!noBlock) {
                    wingBlock(inflate);
                }
            }
            // angle the top
            translate([0,0,-1]) rotate([0,wingTopAngle]) cube(size=[waterBottleD * 3, waterBottleD * 2, height * 2], center=true);
            // angle the bottom
            translate([0,0,87]) rotate([0,45 + wingTopAngle]) cube(size=[waterBottleD * 2, waterBottleD * 2, height * 4], center=true);
            // square off the bottom
            translate([0,0,wingHeight/2 + 4]) cube(size=[waterBottleD * 2, waterBottleD * 2, wingHeight], center=true);
        }
        bolts();
        waterBottle();
        translate([waterBottleD/2, 0, 0]) moveToWaterBottle() cylinder(d=25, h=200, center=false);

        // cutout the wings
        hull() {
            translate([4,0,12.5]) moveToLowerBolt() _ry() cylinder(d=1, h=waterBottleD + 25, center=true);
            translate([0,0,12.5]) moveToLowerBolt() _ry() cylinder(d=1, h=waterBottleD + 25, center=true);
           rotate([0, wingTopAngle]) translate([-5,0,boltZoffset * 0.92]) moveToWaterBottle() moveToLowerBolt() _ry() cylinder(d=8, h=waterBottleD + 25, center=true);
           translate([0,0,boltZoffset - 5]) moveToLowerBolt() _ry() cylinder(d=1, h=waterBottleD + 25, center=true);
        }
        waterBottle();
    }
}

if (false) {
    // display in place
    //translate([0.5,0,0.5])
    wings();
    base();
} else {
    // lay out for printing
    moveToWingZ() translate([60,-10,boltZoffset + 12.5]) rotate([180,wingTopAngle,0])
        wings();
    rotate([90,0,40]) {
        base();
    }
}
