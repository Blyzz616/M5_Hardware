// Big Dual Button enclosure for M5Stack Unit Dual Button  -- v7 (+ seam groove, + optional tactile cap textures)
// base = v2 (unchanged), cap = v4 style (short skirt + retention flange) at the v2 hinge height,
// lid = v1 (no key groove) with the guide sleeves cut down to a 0.5 mm lip.
// Units: mm. Frame: enclosure centre at XY origin, Z=0 = bottom face of base.
// Long axis = Y. Grove/cable end = -Y. Cap slot A = -Y side, slot B = +Y side.
// Caps are rockers: they pivot on snap-in hinge posts that rise from the base
// (2&4 o'clock / 8&10 o'clock when viewed from the top with the Grove end at 3 o'clock)
// and a foot presses the M5 button. Caps snap in/out from the top; lid stays on.

/* [Part to render] */
part = "assembly"; // [assembly, section, lid, base, cap, cap_inlay]
// Rotate lid/cap into print orientation (top face on bed)
print_orient = true;
// Assembly only: show caps pressed
show_pressed = false;

/* [Cap artwork] */
// Which slot this cap is for (only matters for artwork orientation)
cap_slot = "A"; // [A, B]
cap_label = "";
cap_label_size = 9;
cap_label_font = "Liberation Sans:style=Bold";
// Optional SVG file (path relative to this .scad). Leave empty for none.
cap_svg = "";
// SVG is scaled so its width = this
cap_svg_size = 28;
// Engrave depth (also inlay thickness for multi-colour)
art_depth = 0.6;
// Extra rotation of the artwork (deg)
art_rotation = 0;

/* [Cap texture] */
// Raised tactile texture on the cap top
texture = "none"; // [none, lines, waves, crosshatch]
texture_h = 0.5;       // height of the ridges
texture_pitch = 2.5;   // centre-to-centre spacing of ridges
texture_w = 1.0;       // ridge width
wave_amp = 1.2;        // waves: amplitude
wave_len = 8;          // waves: wavelength
tex_steps = 5;         // bevel steps over the ridge height
tex_side = 0.06;       // per-step inset of each ridge side (top width = texture_w - 2*tex_side*(tex_steps-1))

/* [Seam groove] */
seam_h = 0.4;          // groove height on each part (0.8 total where lid meets base)
seam_d = 0.6;          // groove depth into the wall

/* [Files] */
unit_stl = "m5_dual_button_unit.stl"; // only used by assembly/section views

/* [Hardware: M4 bolt + heat-set insert] */
bolt_len      = 15.6; // incl. head
bolt_head_d   = 6.7;
bolt_head_h   = 3.8;
bolt_clear_d  = 4.4;
insert_hole_d = 5.6; // CHECK against your insert's recommended hole
insert_len    = 8.1; // CHECK against your insert length

/* [Fit / clearances] */
cap_d        = 40;
cap_hole_clear = 0.25; // v1 lid radial clearance
hinge_rod_d  = 3.0;    // pivot rod on the cap
hinge_play   = 0.2;    // radial clearance rod-in-socket
hinge_mouth  = 2.4;    // snap mouth width (< rod dia = snap interference)
foot_gap     = 0.0;    // foot to M5 button cap at rest
cable_slot_w = 7;
cable_slot_h = 6;
lid_slot_w   = 6;    // v7 lid cable slot (rectangular)
lid_slot_h   = 1.5;

/* [Hidden] */
$fn = 96;
eps = 0.01;

// ---- M5 unit placement (from STL analysis) ----
unit_off   = [0, -6, 6.8];    // STL origin (centred) -> enclosure
unit_top_z = 5.1 + 6.8;       // grey shell top = 11.9
btn_top_z  = 9.2 + 3.0 + 6.8; // M5 cap top at rest = 19.0
btn_y      = [-7, 7];
unit_w = 24; unit_l = 48; unit_y0 = -30; unit_y1 = 18;

// ---- enclosure ----
W = 54; L = 100; R_corner = 5; wall = 2.4;
base_h   = 6;
lid_top  = 30;
plate_t  = 3;
cap_y    = [-23, 23];
cap_r    = cap_d/2;
hole_r   = cap_r + cap_hole_clear;

// ---- inner wall around the unit ----
iw_t = 1.6; iw_clear = 0.25; iw_top = unit_top_z; grove_gap = 10;

// ---- cap ----
cap_top = lid_top + 3;
disk_t  = 3;
skirt_t = 1.5;
relief_top = 29.2; // post-top reliefs stop 0.8 mm below the lid top (invisible from above)
sleeve_lip = 0.5;                        // what is left of the v1 sleeves below the plate
flange_r = cap_r + 1.0;
flange_flat = 0.4;
flange_gap = 0.5;                        // vertical gap flange -> lip at rest
// flange cone crosses the hole radius at (plate underside - lip - gap)
skirt_bot = lid_top - plate_t - sleeve_lip - flange_gap - (flange_r - hole_r) - flange_flat;
foot_off = cap_y[1] - btn_y[1]; // 16
foot_r   = 3.5;

// ---- hinge (cap-local: foot toward +Y, hinge toward -Y) ----
hinge_ang = 35;          // from the -Y axis (30 = exactly 2/4 o'clock)
hinge_rad = 17;
hx = hinge_rad*sin(hinge_ang);   // 9.75
hy = -hinge_rad*cos(hinge_ang);  // -13.93
hz = 27.2;                       // pivot axis height
rod_r = hinge_rod_d/2;
sock_r = rod_r + hinge_play;
jaw_r = sock_r + 1.3;
post_w = 4; post_l = 6;
web_t = 1.6;
tie_z = [18, 21];

boss_pos = [[21,44],[-21,44],[21,-44],[-21,-44]];
boss_r = 5;
pocket = [unit_w+0.5, unit_l+0.5, 2];

module rrect(x, y, r, h) {
    linear_extrude(h) offset(r) square([x-2*r, y-2*r], center=true);
}
module xcyl(r, len) { rotate([0,90,0]) cylinder(r=r, h=len, center=true); }

// ================= CAP (local frame) =================
module cap_body() {
    cap_core();
    if (texture != "none") {
        // ridges built in thin steps so their sides slope and their ends are bevelled at the rim
        dh = texture_h/tex_steps;
        for (k=[0:tex_steps-1])
            translate([0,0,cap_top+k*dh-(k==0 ? 0.05 : 0)])
                linear_extrude(dh+(k==0 ? 0.05 : 0)+eps)
                    intersection() {
                        circle(r=cap_r-0.6-k*dh);
                        offset(delta=-k*tex_side) texture2d();
                    }
    }
}

module cap_core() {
    rod_len = 2*(hx+post_w/2+1.2);   // as v4
    difference() {
        union() {
            difference() {
                union() {
                    translate([0,0,skirt_bot]) cylinder(r=cap_r, h=cap_top-skirt_bot);
                    translate([0,0,skirt_bot]) cylinder(r=flange_r, h=flange_flat);
                    translate([0,0,skirt_bot+flange_flat]) cylinder(r1=flange_r, r2=cap_r, h=flange_r-cap_r);
                }
                translate([0,0,skirt_bot-eps]) cylinder(r=cap_r-skirt_t, h=cap_top-disk_t-skirt_bot+eps);
                // gaps in skirt + flange at the hinge posts
                for (s=[-1,1]) translate([s*hx-(post_w+1.4)/2, hy-(post_l+1.4)/2, skirt_bot-1])
                    cube([post_w+1.4, post_l+1.4, cap_top-disk_t-skirt_bot+1]);
            }
            translate([0, foot_off, btn_top_z+foot_gap]) {
                cylinder(r1=foot_r-0.8, r2=foot_r, h=0.8);
                translate([0,0,0.8]) cylinder(r=foot_r, h=cap_top-disk_t-(btn_top_z+foot_gap)-0.8+eps);
            }
            translate([0, hy, 0]) {
                translate([-rod_len/2, -web_t/2, hz]) cube([rod_len, web_t, cap_top-disk_t-hz+eps]);
                translate([0,0,hz]) xcyl(rod_r, rod_len);
            }
        }
        translate([0,0,cap_top-0.6]) difference() {
            cylinder(r=cap_r+1, h=1);
            cylinder(r1=cap_r, r2=cap_r-0.6-eps, h=0.6+eps);
        }
        translate([0,0,cap_top-art_depth]) linear_extrude(art_depth+1) art2d();
    }
}

module texture2d() {
    n = ceil(cap_r/texture_pitch)+1;
    if (texture == "lines")
        for (i=[-n:n]) translate([i*texture_pitch-texture_w/2, -cap_r-1]) square([texture_w, 2*cap_r+2]);
    if (texture == "crosshatch")
        for (a=[45,-45]) rotate(a) for (i=[-n:n]) translate([i*texture_pitch*1.6-texture_w/2, -cap_r-1]) square([texture_w, 2*cap_r+2]);
    if (texture == "waves") {
        steps = 120; L2 = cap_r+2;
        for (i=[-n:n]) {
            x0 = i*texture_pitch*1.3;
            pts = [for (k=[0:steps]) let(y=-L2+2*L2*k/steps) [x0+wave_amp*sin(360*y/wave_len)-texture_w/2, y]];
            pts2 = [for (k=[steps:-1:0]) let(y=-L2+2*L2*k/steps) [x0+wave_amp*sin(360*y/wave_len)+texture_w/2, y]];
            polygon(concat(pts, pts2));
        }
    }
}

module art2d() {
    rot = (cap_slot == "A" ? 90 : -90) + art_rotation; // text "up" = +X in enclosure
    rotate(rot) {
        if (cap_label != "")
            text(cap_label, size=cap_label_size, font=cap_label_font, halign="center", valign="center");
        if (cap_svg != "")
            resize([cap_svg_size, 0], auto=true) import(cap_svg, center=true);
    }
}
module cap_inlay() { translate([0,0,cap_top-art_depth]) linear_extrude(art_depth) art2d(); }

// ================= HINGE POSTS (cap-local, on the base) =================
module hinge_posts() {
    for (s=[-1,1]) translate([s*hx, hy, 0]) difference() {
        union() {
            translate([-post_w/2, -post_l/2, base_h-eps]) cube([post_w, post_l, hz-base_h+eps]);
            translate([0,0,hz]) xcyl(jaw_r, post_w);
            // foot fillet
            translate([0,0,base_h-eps]) linear_extrude(3, scale=[post_w/(post_w+4), post_l/(post_l+4)])
                square([post_w+4, post_l+4], center=true);
        }
        translate([0,0,hz]) xcyl(sock_r, post_w+1);
        translate([-post_w, -hinge_mouth/2, hz]) cube([2*post_w, hinge_mouth, 10]);
        // relief slit so the jaws flex
        translate([-post_w, -0.4, hz-sock_r-4.5]) cube([2*post_w, 0.8, 5]);
    }
    // tie beam between the pair (sits above the Grove cable)
    translate([-hx, hy-1.5, tie_z[0]]) cube([2*hx, 3, tie_z[1]-tie_z[0]]);
}

// ================= LID =================
module lid() {
    difference() {
        union() {
            difference() {
                translate([0,0,base_h]) rrect(W, L, R_corner, lid_top-base_h);
                translate([0,0,base_h-eps]) rrect(W-2*wall, L-2*wall, R_corner-wall, lid_top-plate_t-base_h+eps);
            }
            // v1 sleeves, cut down to a 0.5 mm lip
            for (i=[0:1]) translate([0,cap_y[i],lid_top-plate_t-sleeve_lip]) cylinder(r=hole_r+2, h=plate_t+sleeve_lip);
            for (p=boss_pos) translate([p[0],p[1],base_h]) cylinder(r=boss_r, h=lid_top-base_h-eps);
        }
        for (i=[0:1]) translate([0,cap_y[i],lid_top-plate_t-sleeve_lip-1]) cylinder(r=hole_r, h=plate_t+sleeve_lip+2);
        // small reliefs where the v2 hinge-post tops reach into the lid plate
        for (i=[0:1]) translate([0,cap_y[i],0]) rotate(i==0 ? 0 : 180)
            for (s=[-1,1]) translate([s*hx-(post_w+1)/2, hy-(post_l+1)/2, lid_top-plate_t-sleeve_lip-1])
                cube([post_w+1, post_l+1, relief_top-(lid_top-plate_t-sleeve_lip-1)]);
        for (p=boss_pos) translate([p[0],p[1],base_h-eps]) {
            cylinder(d=insert_hole_d, h=insert_len+0.5);
            cylinder(d=bolt_clear_d, h=bolt_len-bolt_head_h-(base_h-4.0)+1.5);
        }
        // outer seam groove (lid half)
        translate([0,0,base_h-eps]) seam_ring(seam_h+eps);
        // rectangular cable slot at the bottom edge of the -Y wall
        translate([-lid_slot_w/2, -L/2-1, base_h-eps]) cube([lid_slot_w, wall+2, lid_slot_h+eps]);
    }
}

module seam_ring(h) {
    linear_extrude(h) difference() {
        offset(R_corner+2) square([W-2*R_corner, L-2*R_corner], center=true);
        offset(R_corner-seam_d) square([W-2*R_corner, L-2*R_corner], center=true);
    }
}

// ================= BASE =================
module inner_wall() {
    ix = unit_w/2 + iw_clear; iy0 = unit_y0 - iw_clear; iy1 = unit_y1 + iw_clear;
    h = iw_top - base_h;
    translate([0,0,base_h-eps]) linear_extrude(h+eps) difference() {
        translate([-ix-iw_t, iy0-iw_t]) square([2*(ix+iw_t), iy1-iy0+2*iw_t]);
        translate([-ix, iy0]) square([2*ix, iy1-iy0]);
        translate([-grove_gap/2, iy0-iw_t-1]) square([grove_gap, iw_t+2]);
    }
}

module base() {
    difference() {
        union() {
            rrect(W, L, R_corner, base_h);
            difference() {
                translate([0,0,base_h-eps]) rrect(W-2*wall-0.5, L-2*wall-0.5, R_corner-wall-0.25, 1.5);
                translate([0,0,base_h-1]) rrect(W-2*wall-0.5-2.4, L-2*wall-0.5-2.4, R_corner-wall-1.45, 4);
                for (p=boss_pos) translate([p[0],p[1],base_h-1]) cylinder(r=boss_r+0.5, h=4);
                translate([-cable_slot_w/2-1, -L/2, base_h-1]) cube([cable_slot_w+2, 6, 4]);
            }
            inner_wall();
            translate([0,cap_y[0],0]) hinge_posts();
            translate([0,cap_y[1],0]) rotate(180) hinge_posts();
        }
        translate([unit_off[0], unit_off[1], base_h-pocket[2]]) rrect(pocket[0], pocket[1], 2, pocket[2]+1);
        // outer seam groove (base half)
        translate([0,0,base_h-seam_h]) seam_ring(seam_h+eps);
        for (p=boss_pos) translate([p[0],p[1],-eps]) {
            cylinder(d=bolt_head_d+0.5, h=4.0);
            cylinder(d=bolt_clear_d, h=base_h+2);
        }
    }
}

module unit() { color("grey") translate(unit_off) import(unit_stl); }

// rocker angle for pressed state: foot moves down 0.6 + gap
press_ang = atan((0.6+foot_gap)/(foot_off-hy));
module cap_placed(i, pressed=false) {
    translate([0,cap_y[i],0]) rotate(i==0 ? 0 : 180)
        translate([0,hy,hz]) rotate([pressed ? -press_ang : 0,0,0]) translate([0,-hy,-hz]) cap_body();
}

if (part == "lid") {
    if (print_orient) translate([0,0,lid_top]) rotate([180,0,0]) lid(); else lid();
} else if (part == "base") {
    base();
} else if (part == "cap") {
    if (print_orient) translate([0,0,cap_top]) rotate([180,0,0]) cap_body(); else cap_body();
} else if (part == "cap_inlay") {
    if (print_orient) translate([0,0,cap_top]) rotate([180,0,0]) cap_inlay(); else cap_inlay();
} else if (part == "section") {
    difference() {
        union() {
            color("tan") base(); color("lightblue", 0.9) lid(); unit();
            color("royalblue") { cap_placed(0, show_pressed); cap_placed(1, show_pressed); }
        }
        translate([0,-100,-10]) cube([100,200,100]);
    }
} else {
    color("tan") base(); color("lightblue", 0.5) lid(); unit();
    color("royalblue") { cap_placed(0, show_pressed); cap_placed(1, show_pressed); }
}
