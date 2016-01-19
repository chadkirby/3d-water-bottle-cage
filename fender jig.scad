$fs = 1;
$fa = 6;
wid = 52;
difference() {
    translate([0,0,0.5]) cube(size=[12, wid, 1], center=true);
    cylinder(d=3, h=10, center=true);
}
difference() {
    for (yy=[-1:2:1]) {
        translate([0, yy * (wid/2 + 1) , 15/2]) cube(size=[12, 2, 15], center=true);
    }
    translate([0,0, 12]) rotate([90,0,0]) cylinder(d=10.5, h=100, center=true);
}
