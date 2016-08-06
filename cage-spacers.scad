use <high-rise-cage-with-pump.scad>

rotate([0, 90]) {
    difference() {
        insert(dd = -1, dh = 5);
        thruHole();
    }

    translate([0, 15])
    difference() {
        hull() {
            translate([0,0,1]) insert(dd = -1, dh = 5);
            translate([0,0,-1]) insert(dd = -1, dh = 5);
        }
        hull() {
            translate([0,0,1]) thruHole();
            translate([0,0,-1]) thruHole();
        }
    }
}
