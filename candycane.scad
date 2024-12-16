use <deps/bend.scad>

curved_facets = 50; // Author's note: I found that 50 is enough to give 
  // a good sense of what I'm looking at, but >500 is needed to render as
  // what I considered "neat".
$fn = 200;

/**
 * Creates a spiral centered on the Z axis, going up from 0. The angle for
 * the stripes is controled with the `color_height` and the `outer_radius`
 * parameters. The spiral currently goes up by one `color_height` every
 * 180 degrees.
 *
 * The way this works is by taking an upright rectangle and doing tiny hull
 * segments while going on an upward spiral.
 *
 * Params:
 *  - phase: Where (in degrees) to start the spiral from.
 *  - length: How tall to make the spiral.
 *  - outer_radius: The radius for the overal spiral segment.
 *  - inner_radius: The radius of the inner hole. Used to make a hollow spiral. Set to 0 for a filled spiral.
 *  - color_height: How tall to make a color stripe.
 */
module spiral(phase = 0, length = 200, outer_radius = 15, inner_radius = 7.5, color_height = 18) {
  step_inc = 0.01;
    
  thickness = outer_radius - inner_radius;
  // We add an extra half turn because we're going to trim it to acheive
  // flat ends. The first half turn doesn't have the other color under it.
  number_of_half_turns = length / color_height + 1;

  intersection() {
    // Lower it by a full color since we're going to cut a half-turn.
    translate([0, 0, -color_height])
      for(step=[0:step_inc:number_of_half_turns]) { 
        step_prime = step + step_inc;

        hull() {
          rotate([0, 0, phase + 180 * step])
            translate([inner_radius, 0, color_height * step])
            cube([thickness, 0.01, color_height]);
             
          rotate([0, 0, phase + 180 * step_prime])
            translate([inner_radius, 0, color_height * step_prime])
            cube([thickness, 0.01, color_height]);
        }
      }
        
      translate([0, 0, length / 2])
        cube([outer_radius * 2, outer_radius * 2, length], center = true);
  }
}

/**
 * Creates the curved part of the candy cane with a round end cap. Centers
 * it in the Z axis starting at 0 and curving toward the negative of the Y
 * axis.
 *
 * Params:
 *  - phase: Where (in degrees) to start the spiral from.
 *  - curve_radius: How wide to make the curve.
 *  - outer_radius: The radius for the overal spiral segment.
 *  - inner_radius: The radius of the inner hole. Used to make a hollow spiral. Set to 0 for a filled spiral.
 *  - color_height: How tall to make a color stripe.
 */
module curved_part(phase = 0, curve_radius = 60, outer_radius = 15,  inner_radius = 7.5, color_height = 18) {
  facets = curved_facets;
  rad_angle = 4.2;
  length = rad_angle * curve_radius;
  width = outer_radius * 2;

  translate([-outer_radius, outer_radius, 0])
    rotate([90, 0, 0])
    cylindric_bend([width, length, width], curve_radius, facets)
    translate([outer_radius, -width, outer_radius])
    rotate([-90, 0, 0])
    spiral(phase, length, outer_radius, inner_radius);
    
  pi = 3.14159265359;
  angle_covered = 360 + 90 - rad_angle * (180 / pi) + 2 /* No clue why the + 2, but else there is a gap */;
    
  adjusted_radius = curve_radius - outer_radius;

  y = (adjusted_radius * sin(angle_covered)) - curve_radius;
  z = adjusted_radius*(cos(angle_covered)) + outer_radius;

  translate([0, y, z])
    rotate([180 + angle_covered, 0, 0])
    rotate([0, 0, 180 + 2])
    end_cap(phase, outer_radius, inner_radius);
}

/**
 * Creates a half-sphere end-cap spiral for the candy cane. Creates it
 * centered on the Z axis, below 0.
 *
 * Params:
 *  - phase: Where (in degrees) to start the spiral from.
 *  - outer_radius: The radius for the overal spiral segment.
 *  - inner_radius: The radius of the inner hole. Used to make a hollow spiral. Set to 0 for a filled spiral.
 *  - color_height: How tall to make a color stripe.
 */
module end_cap(phase = 0, outer_radius = 15, inner_radius = 7.5, color_height = 18) {
  difference() {
    // The way this work is pretty simple, we just make a downard spiral
    // and intersect it with a spere. This way the curve should just
    // match.
    intersection() {
      sphere(outer_radius);
    
      mirror([1, 0, 0])
      mirror([0, 0, 1])
      spiral(phase, outer_radius, outer_radius, 0, color_height);
    }
  
    // Remove a 45 degrees cone so that we don't have to print internal
    // supports when printing upside down.
    translate([0, 0, -inner_radius / 2])
    cylinder(inner_radius, 0, inner_radius, center = true);
  }
}

/**
 * Creates half of a candy cane, with the straight part centered on the Z
 * axis, the curve going toward the negative Y axis and a spherical end-cap
 * going below the XY plane (under the straight part).
 *
 * Params:
 *  - phase: Where (in degrees) to start the spiral from.
 *  - outer_radius: The radius for the overal spiral segment.
 *  - inner_radius: The radius of the inner hole. Used to make a hollow spiral. Set to 0 for a filled spiral.
 *  - color_height: How tall to make a color stripe.
 *  - straight_part_length: How tall to make the straight part.
 *  - curve_radius: How wide to make the curve.
 */
module candy_cane_half(phase = 0, outer_radius = 15, inner_radius = 7.5, color_height = 18, straight_part_length = 210, curve_radius = 60) {
  
  spiral(phase, straight_part_length, outer_radius, inner_radius, color_height);
  
  end_cap(phase, outer_radius, inner_radius, color_height);
  
  translate([0, 0, straight_part_length])
    curved_part(phase, curve_radius, outer_radius, inner_radius, color_height);
}

candy_cane_half(0);

color("red")
  candy_cane_half(180);
