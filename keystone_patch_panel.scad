use <rj45receiver.scad>; // https://github.com/marcuswu/RJ45KeystoneReceiver
/* 
this is a covered patch panel that holds keystone jacks, typically for RJ45 
Jim Dodgen (c) 2024 MIT LIcence 
*/
//  pick one or both
rotate([90,0,0]) 
    make_base();
translate([0,5,0]) 
    make_lid();
//
// only even number of jacks get the mount hole which is centered, 
nbr_jacks = 6;
filler=4;  // make this larger if your keystone jacks are wider
//
// seldom changed variables
end_padding = 10;
wall=4;
mount_depth = 60;
z_offset = 7;   // lifts rj45
height=rj45_height()+z_offset;
raw_item_width = rj45_width()+filler;
x_items_width = (raw_item_width*nbr_jacks)- filler;
x_total_width = x_items_width +(end_padding*2);
// mount base to wall
wall_mount_screw_d = 5;
// lid to base screw
M3_screw_hole = 3.2; 
M3_clearence_hole = 3.6;
M3_head_clearence_hole = 6.2;
M3_fn = 12; // self tapping 

lid_clearance = 1.5;
lid_width = x_total_width+lid_clearance;
lid_height = height+wall;
lid_depth = mount_depth+wall;
cable_slot_d = 7;
// lid mounting tabs
tab_width = 6;
tab_lth = 15;
tab_thickness = 4;
tab_cutout_clearance = 2; // 2;

// mostly code below
module make_base()
{
    difference()
    {
        union()
        {
            cube([x_total_width,wall,height]);
            cube([x_total_width,mount_depth,wall]);
            translate([end_padding,0,0]) 
                cube([x_items_width,rj45_depth(),height]);
        }
       do_blocks();
       translate([end_padding*.7,(mount_depth/2)+rj45_depth(),0]) 
            mount_hole();
       translate([x_total_width-(end_padding*.7),(mount_depth/2)+rj45_depth(),0])
            mount_hole();
       if ((nbr_jacks % 2) == 0)  // need a space between jacks for screw hole
       {
           translate([x_total_width/2,rj45_depth()/2,height-rj45_height()]) 
            cylinder(d=M3_screw_hole, h=rj45_height(), $fn=M3_fn);
           
       }
    }
    do_keystone_receivers();
    rear_tabs();
}

module make_lid()
{ 
    difference()
    {
        union()
        {
            cube([lid_width,wall,lid_height]);
            cube([lid_width,lid_depth,wall]); 
            // end caps
            translate([-wall,0,0])
                cube([wall,lid_depth,lid_height]);
            translate([lid_width,0,0])
                cube([wall,lid_depth,lid_height]);
        }
        if ((nbr_jacks % 2) == 0)
        {
           translate([lid_width/2,lid_depth -(rj45_depth()/2),0])
          { 
            cylinder(d=M3_clearence_hole, h=rj45_height(), $fn=30);
            cylinder(d=M3_head_clearence_hole, h=wall/2, $fn=30);
          }
        }
        do_lid_slots();
        tab_cutouts();
    }   
}

module do_lid_slots()
{
    translate([end_padding+(lid_clearance/2)+(rj45_width()/2),0,0])
    for (i = [0:1:nbr_jacks-1])
    {
      translate([raw_item_width*i,0,lid_height-wall*1.7])
       { 
           rotate([-90,0,0]) 
                cylinder(d=cable_slot_d, h=wall, $fn=30);
           translate([0,cable_slot_d/2,cable_slot_d])
                cube([cable_slot_d,cable_slot_d,cable_slot_d*2], center=true); 
       }
    }
}

module do_blocks()
{
    translate([end_padding,0,0])
    for (i = [0:1:nbr_jacks-1])
    {
      translate([raw_item_width*i,0,0])
           VolumeBlock();
    }
}

module do_keystone_receivers()
{
    translate([end_padding,0,0])
    for (i = [0:1:nbr_jacks-1])
    {
      translate([raw_item_width*i,0,0])
       { 
           keystone_receiver();
           cube([rj45_width(),rj45_depth()+1.35,z_offset]);
       }
    }
    
}

module keystone_receiver()
{
    translate([rj45_width(),rj45_depth(),height])
        rotate([90,180,0])
            rj45Receiver(); 
}

module VolumeBlock()
{
    translate([rj45_width(),rj45_depth(),height])
        rotate([90,180,0])
            rj45VolumeBlock(); 
}

module mount_hole()
{
    cylinder(d=wall_mount_screw_d, h=wall,$fn=30);
    cylinder(d2=wall*2, d1=0, h=wall,$fn=30);
}

module rear_tabs()
{ 
    translate([x_total_width-tab_width-(tab_cutout_clearance/2), 
                mount_depth-tab_lth+wall, wall])
        tab();
    translate([tab_cutout_clearance/2, mount_depth-tab_lth+wall, wall])
        tab();
}

module tab()
{
    difference()
    {
        cube([tab_width, tab_lth, tab_thickness]);
        rotate([25,0,0]) 
            cube([tab_width, tab_lth, tab_thickness]);
    }
}

module tab_cutouts()
{
    translate([lid_clearance/2,0,0])
    {
        cutout_width = tab_width+tab_cutout_clearance;
        cutout_thickness = tab_thickness+tab_cutout_clearance;
        translate([x_total_width-cutout_width,0,
        lid_height-wall-cutout_thickness+(tab_cutout_clearance/2)])
            cube([tab_width+tab_cutout_clearance, wall,
                tab_thickness+tab_cutout_clearance]);
        translate([0,0,
            lid_height-wall-cutout_thickness+(tab_cutout_clearance/2)])
            cube([tab_width+tab_cutout_clearance, wall,
                tab_thickness+tab_cutout_clearance]);
    }
}

