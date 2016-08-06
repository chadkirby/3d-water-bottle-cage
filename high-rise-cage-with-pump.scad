$fs = 1;
$fa = 6;
pumpD = 23.25;

module _ry() {
    rotate([90,0]) children();
}
module _rx() {
    rotate([0,90]) children();
}
module downTube() {
    len = 19 * 25.4;
    rotate([0, -3])
    translate([-45,0, -6 * 25.4])
    hull() {
        for (ii=[-1:2:1]) {
            translate([0,ii * 26]) {
                cylinder(r=4, h=len, center=false);
                translate([24, ii * 2])
                    cylinder(r=2, h=len, center=false);
            }
        }
        for (ii=[-1:2:1]) {
            translate([25, ii * 10])
                cylinder(r=10, h=1, center=false);

            translate([50, ii * 10, len - 1])
                cylinder(r=10, h=1, center=false);

        }
    }
}
module pump() {
    moveToWingZ()
    shapeWings()
    moveToWaterBottle(0.5)
    rotate([0, 0, 60])
    moveToWaterBottle(-0.57)
    translate([-pumpD/2, 0, 50])
    difference() {
        hull() {
            cylinder(d=pumpD + 5, h=100, center=true);
            rotate([0, 0, 19])
            translate([20, 0])
            cylinder(d=8.5, h=100, center=true);
        }
        difference() {
            cylinder(d=pumpD + 10, h=23, center=true);
            cylinder(d=pumpD + 5, h=24, center=true);
        }
        cylinder(d=pumpD, h=100, center=true);
        rotate([0, 0, 15])
        hull() {
            cylinder(d=1, h=100, center=true);
            for (aa=[-45, 45]) {
                rotate([0, 0, aa])
                translate([-50, 0])
                cylinder(d=1, h=100, center=true);
            }

        }
        rotate([0, 0, 105]) hull() {
            _rx() translate([0, -5]) cylinder(r=1, h=100, center=true);
            for (sign=[-1, 0.9]) {
                rotate([sign * 60, sign * -15])
                _rx() translate([0, 50]) cylinder(r=1, h=100, center=true);
            }
        }
    }
}
*downTube();
*pump();
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
module insert(dd = 0, dh = 0) {
    _rx() cylinder(d=11.5 + dd, h=4.5 + dh, center=true);
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
    translate([0,0, 10]) children();
}
module lowerBolt() {
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
}
module bolts() {
    translate([0,0,5]) moveToLowerBolt() {
        lowerBolt();
        translate([0,0,boltZoffset]) bolt();
    }
}
module moveToWaterBottle(dir = 1) {
    translate([dir * waterBottleD/2 + dir * waterBottleOffset,0,0])
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
    translate([0,0,5]) children();
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
                    _rx() hull() {
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
                            rotate([0, 15, 0]) translate([0,0, 50]) _ry() cylinder(d=5, h=wid, center=true);
                        }
                        // ball thing that fits in the bottle dimple thing
                        rotate([0, 15, 0]) translate([0,0,50 + 22/2 - 3.5]) {
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
        hull() wings(noBlock = true, noPump = true);
        *translate([0,0,5]) moveToLowerBolt() wingBlock(0.5);
        // radius the transition into the lower support
        translate([-1,0,-10]) moveToLowerBolt() scale([1.5, 1, 0.5]) _ry() cylinder(d=13, h=wid+1, center=true);

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
module shapeWings() {
    intersection() {
        union() children();
        // angle the top
        translate([0,0,-1]) rotate([0,wingTopAngle]) cube(size=[waterBottleD * 3, waterBottleD * 2, wingHeight * 2], center=true);
        // angle the bottom
        translate([0,0,87]) rotate([0,45 + wingTopAngle]) cube(size=[waterBottleD * 2, waterBottleD * 2, wingHeight * 4], center=true);
        // square off the bottom
        translate([0,0,wingHeight/2 + 3.5]) cube(size=[waterBottleD * 2, waterBottleD * 2, wingHeight], center=true);
    }
}

wingTopAngle = 10;
module wings(inflate = 0, noBlock=true, noPump = false) {
    height = wingHeight;
    color("LightBlue", 0.75) difference() {
        moveToWingZ() shapeWings() {
            hull() {
                translate([12, 0, (height)/2]) cube(size=[10, wid, (height)], center=true);
                wingBase(height);
            }
            if (!noBlock) {
                wingBlock(inflate);
            }
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
    if (!noPump) {
        pump();
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
