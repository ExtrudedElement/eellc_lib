/**********************************************************/
/*******************Extruded Element Library***************/
/**********************************************************/
//v1.0
//Version date: 09/27/2018
/*
 *
 *Copyright (C) Extruded Element LLC. Extruded Element Library
 *is made available under a Creative Commons
 *Attribution-NonCommercial 4.0 Public License(international):
 *https://creativecommons.org/licenses/by-nc/4.0/
 *
 *Digital/Physical Creations of Extruded Elements
 *are Protected by U.S. Patent Pending Protections
 *U.S. Patent Pub. No.:US 2018/0272647 A1
 *U.S. Pub. Date: Sep. 27 2018
 *Appl. No.: 15/927,137
 *Publication found at uspto.gov
 *(via Patent Application Search)
 *
 *Learn more at extrudedelement.com
 */



//Extruded Element Parameters

/****Basic Options****/
//
typ_e = 1; //Element Types: typ_e, Input- [0,1, or 2]
////0 - square element footprint; square LO array (rectangular grid)
////1 - triangle element footprint; hexagonal LO array (honeycomb)
////2 - hexagonal element footprint; triangular LO array (isogrid)
s_e = 50; // element size (triangle or square side-length; hexagon flat-to-flat width/minor diameter)
/*******/
typ_h =0; //Hook Types: typ_h, Input- [0 or 1]; Description-[square, rounded]
////0 - square hook (all 90 degree turns in hook profile)
////1 - rounded hook (Yin-Yang style tangencies, uniform hook width = tip diameter)
s_h = 1; // hook size (width/diameter of arcing/squared hook profile-tip)
/*******/
n_elem = 9; // "x" (column) array size
m_elem = 6; // "y" (row)    array size
/*******/
e_fill = 0; //Element Fill Type: e_fill, [-1,0, or 1]
//e_fill = -1; Filled Element minus Light Weighting Features (Edge to Edge Tiling Elements with Weight Reduction)
//e_fill = 0: Ligament Only (LO) Element (Ligaments connecting hooks Only)
//e_fill = 1: Filled Element (Edge to Edge Tiling of Elements)

/****Production Options****....................................................*/
/****Clearance/Fitment Options****/
k_e = 0.9; // element kerf - decrease value to loosen fit (non-LO elements only)
k_h = 0.9; // hook kerf - decrease value to loosen fit

/****Production Dimensions****/
sample_height = 4; //Extrusion height of sample elements for fitment/sheet production
height = 100; //Extrusion height of Elements (must surpass object height for boolean intersection [Union of Object & Extruded Element Array])

/****Production Spacing****/
printer_spacing = s_e + 3 * s_h; //distance between printed elements on print bed

/****Imported STL Object options****/
fileName = "airfoil.stl"; // file name
s_obj = 1; //scaling the original stl object file
t_x = 0; // translate x
t_y = 0; // translate y
t_z = 0; // translate z
r_x = 0; //rotate about the +x axis
r_y = 0; //rotate about the +y axis
r_z = 0; //rotate about the +z axis
/**/

/****Ligament-Only (LO) Options................................................*/
    //(Requires e_fill=0;)
s_el = 0.5; //element ligament size (thickness); LO elements only
/*******Ligament-Only (LO) Supports*******/
c_h2e = 1; //Hook to element chamfer: c_h2e, [0 (no), 1 (yes)]
t_h2e = 3; //hookbase-to-element taper size; LO elements only
/*******/
c_cscl = 1; //element center support chamfer ligaments: c_cscl, [0 (no), 1 (yes)]
s_csc =  s_e  - 8*s_h; //element center support chamfer size; LO elements only
s_csl = 0.5; //[<= s_scs] element center support chamfer ligament (thickness); LO elements only



//!//!End of Parameters!//!//

//()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()//
//EXECUTED CODE

////////////////////////VISUALIZATION---------------------------
tessellate(); //VISUALIZE 2D ELEMENT ARRAY
//intersection(){
//   linear_extrude(height = height) tessellate(); //VISUALIZE 3D EXTRUDED ELEMENT ARRAY
//   translate ([t_x,t_y,t_z]) rotate ([r_x,r_y,r_z]) scale ([s_obj, s_obj, s_obj]) import(fileName); //VISUALIZE OBJECT
//}
///////////////////PRODUCTION TESTING---------------------------
//sample_hooks(); //CREATE SOME SAMPLE HOOKS FOR PRINTING
//sample_elements(); //CREATE SOME SAMPLE ELEMENTS FOR PRINTING


///////////////////PRODUCTION-----------------------------------
//production_iteration();

//!//!END EXECUTED CODE!//!//
//()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()//


/*****************************************************************/

/*//////Functional Variables//////*/
eID = 0; //loop iteration number - element index Identification
//!//!End of Variables!//!//
/*****************************************************************/

/*//////Constants//////*/
//UNIT GEOMETRIC FEATURES (TRIANGLE & SQUARE) - Unit Equilateral Triangle Dimensions;
h_tri = 1.5 / sqrt(3);
r_min_tri = 0.5 / sqrt(3);
r_maj_tri = 1 / sqrt(3);
l_tri = 1;
l_sq = 1;


//ROUNDED HOOK GEOMETRIC CONSTANTS - Unit Diameter Hook Tip
r_h = 0.5; //hook nominal radius
s_tip_R = r_h - (1 - k_h ) ; //adjusted tip Radius
s_hook_OR = (r_h + (1 - k_h )  ) + 2 * s_tip_R; //adjusted Hook Outside Radius
s_hook_IR = (r_h + (1 - k_h ) ); // adjusted Hook Inside Radius
s_hookneg_IR = s_tip_R + 2 * s_hook_IR; // adjusted Hook Recess Inside Radius

///Overlap parameter (needed because exact alignment causes "seams" in hook-element interface)
s_ol = (1 - k_h );

//!//!End of Constants!//!//
/*****************************************************************/

//------Production Modules------//
module production_iteration() //intersecting an object with extruded element array
{
    i = eID % n_elem;
    j = (eID - i ) / n_elem;
    intersection(){
        translate ([t_x,t_y,t_z]) rotate ([r_x,r_y,r_z]) scale ([s_obj, s_obj, s_obj]) import(fileName);
        //Producing a specific i-th row & j-th column element position
        if ( typ_e == 0) //square
        {  
            linear_extrude(height = height) translate([i * s_e, j * s_e , 0 ]) compile_element();
        }
        if ( typ_e == 1) //triangle
        {    
            linear_extrude(height = height) translate(s_e * [ i * l_tri / 2,  (pow(-1,i) * pow(-1,j) - 1) * (-r_min_tri/2) + j * ( h_tri ),  0 ]) {
                rotate([0,0,((2 + i + j ) * 180)]) compile_element();
            }
        }
        if ( typ_e == 2 && e_fill == 0) //hexagon LO
        {    
            linear_extrude(height = height) translate( s_e * [i, (pow(-1,i) - 1) * r_min_tri + j * (r_min_tri + h_tri ),  0 ]) {
                rotate([0,0,((2 + i + j ) * 180)]) compile_element();
            }
        }
        if ( typ_e == 2 && ( e_fill == 1 || e_fill == -1 )) //hexagon non-LO
        {    
            linear_extrude(height = height) translate( s_e * [i + (pow(-1,j) - 1) * 0.25, j * h_tri,  0 ]) {
                rotate([0,0,((2 + i + j ) * 180)]) compile_element();
            }
        }
    }
echo(i,j);
}

//------Production Testing Modules------//
module sample_elements()
{
    linear_extrude(height = sample_height ) compile_element();
    linear_extrude(height = sample_height ) translate([printer_spacing,0,0]) compile_element();
}

module sample_hooks()
{
    linear_extrude(height = sample_height ) {
        difference(){
            make_hook();
            if (typ_h == 1) hook_neg();
        }
    }
    translate([s_h * 4.25,0,0]) linear_extrude(height = sample_height ) {
        difference(){
            make_hook();
            if (typ_h == 1) hook_neg();
        }
    }
}
//------Element Assembly Modules------//
module tessellate() {
    //Patterning of the Selected Element Shape
    if ( typ_e == 0) //square
    {  
        for (i = [0 : n_elem - 1 ] ) {
            for (j = [0 : m_elem - 1 ] ) {
                translate([i * s_e, j * s_e , 0 ]) compile_element();
            }
        }
    }
    if ( typ_e == 1) //triangle
    {    
        for (i = [0 : n_elem - 1 ] ) {
            for (j = [0 : m_elem - 1 ] ) {
                translate(s_e * [ i * l_tri / 2,  (pow(-1,i) * pow(-1,j) - 1) * (-r_min_tri/2) + j * ( h_tri ),  0 ]) {
                    rotate([0,0,((2 + i + j ) * 180)]) compile_element();
                }
            }
        }
    }
    if ( typ_e == 2 && e_fill == 0) //hexagon LO
    {    
        for (i = [0 : n_elem - 1 ] ) {
            for (j = [0 : m_elem - 1 ] ) {
                translate( s_e * [i, (pow(-1,i) - 1) * r_min_tri + j * (r_min_tri + h_tri ),  0 ]) {
                    rotate([0,0,((2 + i + j ) * 180)]) compile_element();
                }
            }
        }
    }
    if ( typ_e == 2 && ( e_fill == 1 || e_fill == -1 )) //hexagon non-LO
    {    
        for (i = [0 : n_elem - 1 ] ) {
            for (j = [0 : m_elem - 1 ] ) {
                translate( s_e * [i + (pow(-1,j) - 1) * 0.25, j * h_tri,  0 ]) {
                    rotate([0,0,((2 + i + j ) * 180)]) compile_element();
                }
            }
        }
    }
}

//------Element Bulding Modules------//
module compile_element() {
    if (e_fill == -1) light_weighting_element();
    if (e_fill == 0) combine_hook_ligaments();
    if (e_fill == 1) combine_hook_element();
}



module light_weighting_element() { 
    //boolean-difference the light weighting features from the filled element body
    difference() {
        combine_hook_element();
        light_weighting();
    }
}

module light_weighting() {
    //Weight Reduction geometry - centered on element center
        r_min_lw = s_e / 2.7 ; 
        r_maj_lw = s_e / 6.5 ;
     //circular: r_min removed from center, r_maj removed from corners        
    circle(r = r_min_lw, $fn=25);
        if ( typ_e == 0) {//square element
            translate([s_e/2,s_e/2]) circle(r = r_maj_lw, $fn=25);
            translate([-s_e/2,s_e/2]) circle(r = r_maj_lw, $fn=25);
            translate([s_e/2,-s_e/2]) circle(r = r_maj_lw, $fn=25);
            translate([-s_e/2,-s_e/2]) circle(r = r_maj_lw, $fn=25);
        }
        if ( typ_e == 1) {//triangular element
            for(theta = [90 : 120 : 330]) rotate([0,0,theta]) translate([s_e * r_maj_tri,0]) circle(r = r_maj_lw, $fn=25);
        }
        if ( typ_e == 2) {//hexagonal element
            for(theta = [30 : 60 : 330]) rotate([0,0,theta]) translate([s_e * r_maj_tri,0]) circle(r = r_maj_lw, $fn=25);
        }
     //end-circular light weighting
    
    /*// triangular: 
    //r_maj_lw = side length of corner triangles
    
    tri_maj_points = [
    [ -r_maj_lw/2 , -r_min_tri * r_maj_lw ] , //0
    [ r_maj_lw/2 , -r_min_tri * r_maj_lw ] , //1
    [ 0 , r_maj_tri * r_maj_lw ] , //2
    [ 0, -2*r_min_tri * r_maj_lw ] ]; //3  (an interesting effect b/w 0 & 1)
    tri_maj_path = [[0,3,1,2]];
    
    //l_r_maj_lw = radial placement of r_maj length triangles
    l_r_maj_lw = s_e * 0.35;
    for (theta = [0 : 120 : 240]) {
    rotate ([0,0,theta]) translate ([ 0, l_r_maj_lw, 0 ]) polygon(tri_maj_points, tri_maj_path);
    }
    //r_min = side length of center triangle/square/hex (depending on typ_e)
    tri_min_points = [
    [ -r_min_lw/2 , -r_min_tri * r_min_lw ] , //0
    [ r_min_lw/2 , -r_min_tri * r_min_lw ] , //1
    [ 0 , r_maj_tri * r_min_lw ] ]; //2
    tri_min_path = [[0,1,2]];
    polygon(tri_min_points, tri_min_path);
    */ //end-triangular light weighting
}

module combine_hook_ligaments() {
    if (typ_h == 0) { // square hook
        place_hook();
        make_ligaments();
    }
    if (typ_h == 1) { // rounded hook
        difference() {
            place_hook();
            place_hook_neg();
        }
        make_ligaments();
    }
}

module combine_hook_element() {
    if (typ_h == 0) place_hook(); // square hook
    if (typ_h == 1) { // rounded hook
    difference() {
        place_hook();
        place_hook_neg();
    }
    }
    
        
    difference() {
        make_element();
        remove_material();
    }
}

module make_ligaments() {
    //draw element ligaments
    if(typ_e == 0){ //square (LO)
        square([s_el, s_e - 2* 1.5 * s_h - 2*(1 - k_h) * s_h],true); 
        square([s_e - 2* 1.5 * s_h- 2*(1 - k_h) * s_h, s_el],true);
        if (c_cscl == 1) {//center support chamfer ligaments
            for( theta = [45 : 90 : 315]) rotate ([0,0,theta]) translate([s_csc / (2 * sqrt(2)),0,0]) square([s_csl, s_csc * sqrt(2) / 2],true); 
        }
    } 
    if(typ_e == 1){ //triangle (LO)
        for(theta = [60 : 120 : 300]) rotate([0,0,theta]) translate([-s_el/2,0,0]) square([s_el, s_e * r_min_tri - 1.5 * s_h - 2*(1 - k_h) * s_h],false);
           if (c_cscl == 1) {//center support chamfer ligaments
               for( theta = [90 : 120 : 340]) rotate ([0,0,theta]) translate([s_csc / (4 * sqrt(3)),0,0]) square([s_csl, s_csc/2],true);
           } 
    }
    if(typ_e == 2){ //hexagon (LO)
        for(theta = [0 : 60 : 300]) rotate([0,0,theta]) translate([-s_el/2,0,0]) square([s_el, 2 * s_e * r_min_tri - 1.5 * s_h - 2*(1 - k_h) * s_h ],false);
           if (c_cscl == 1) {//center support chamfer ligaments
               for( theta = [0 : 60 : 300]) rotate ([0,0,theta]) translate([3*s_csc / (4 * sqrt(3)),0,0]) square([s_csl, s_csc/2],true);
           }
    }
} 

module make_element() {
    if ( typ_e == 0) //square
    {
        square(s_e - 2*(1-k_e) * s_h, true);
    }
    if ( typ_e == 1) //triangle
    { 
        //Kerf normalization for triangular element scaling
        k_n = (s_e * r_min_tri - (1 - k_e ) * s_h) / r_min_tri;
        //Kerfed & scaled equilateral triangle centered on 0,0
        scale([k_n, k_n, k_n ]) {
            polygon(points=[[l_tri/2,-r_min_tri],[-l_tri/2,-r_min_tri],[0,r_maj_tri]]);
        }
    }
    if ( typ_e == 2) //hexagon
    {
        //Kerf normalization for hexagonal element scaling
        k_n = (s_e * r_min_tri - (1 - k_e ) * s_h * r_maj_tri) / r_min_tri;
        //Kerfed & scaled equilateral triangle centered on 0,0
        scale([k_n, k_n, k_n ]) {
            polygon(points=[[l_tri/2,r_min_tri],[l_tri/2,-r_min_tri],[0,-r_maj_tri],[-l_tri/2,-r_min_tri],[-l_tri/2,r_min_tri],[0,r_maj_tri]]);
        }
    }
}

module remove_material() {
    if ( typ_e == 0) //square
    {
        for( theta = [0 : 90 : 270]) {
            rotate( [0, 0, theta ] ) removal_shape();
        }
    }
    if ( typ_e == 1) //triangle
    {
        for( theta = [60 : 120 : 300]) {
            rotate( [0, 0, theta ] ) removal_shape();
        }
    }
    if ( typ_e == 2) //hexagon
    {
        for( theta = [30 : 60 : 330]) {
            rotate( [0, 0, theta ] ) removal_shape();
        }
    }

}

module removal_shape() { //material removal to insert hooks
    if (typ_h == 0 && typ_e == 1) { //triangular filled removal (Square Hooks)
        translate( [ 0, r_min_tri * s_e , 0] ) {
                scale( [s_h, s_h, s_h ] ) {
                    translate( [-2 + (1 - k_h), -1.5 - (1-k_h), 0 ] ) {
                    square( [4 , 1 + k_h]);
                    }
                }
            }
    }
    if (typ_h == 1 && typ_e == 1) { //triangular filled removal (Rounded Hooks)
        translate( [ 0, r_min_tri * s_e , 0] ) {
                scale( [s_h, s_h, s_h ] ) {
                    translate( [-r_h - s_hookneg_IR, - s_hookneg_IR, 0 ] ) {
                            square( [2 * s_hookneg_IR + 2 * s_tip_R - s_ol, s_hookneg_IR ] );
                    }
                }
            }
    }
    if (typ_h == 0 && (typ_e == 2 || typ_e == 0)) { //hexagonal/square filled removal (Square Hooks)
        translate( [ 0, s_e / 2 , 0] ) {
                scale( [s_h, s_h, s_h ] ) {
                    translate( [-2 + (1 - k_h), -1.5 - (1-k_h), 0 ] ) {
                    square( [4 , 1 + k_h]);
                    }
                }
            }
        }

    if (typ_h == 1 && (typ_e == 2 || typ_e == 0)) { //hexagonal/square filled removal (Rounded Hooks)
                translate( [ 0, s_e / 2 , 0] ) {
                scale( [s_h, s_h, s_h ] ) {
                    translate( [-r_h - s_hookneg_IR, - s_hookneg_IR, 0 ] ) {
                            square( [2 * s_hookneg_IR + 2 * s_tip_R - s_ol, s_hookneg_IR ] );
                    }
                }
            }
        }
    }
    
//------Hook Bulding Modules------//
module place_hook() {
    if ( typ_e == 0) //square
    {
            for( theta = [0 : 90 : 270]) rotate( [0, 0, theta ] ) translate ( [0, l_sq / 2 * s_e, 0 ] ) make_hook(k_h);
    }    
    if ( typ_e == 1) //triangle
    {
            for( theta = [60 : 120 : 300]) rotate( [0, 0, theta ] ) translate ( [0, r_min_tri * s_e, 0 ] ) make_hook(k_h);
    }
    if ( typ_e == 2 && e_fill == 0) //hexagon LO
    {
            for( theta = [0 : 60 : 300]) rotate( [0, 0, theta ] ) translate ( [0,2 * r_min_tri * s_e, 0 ] ) make_hook(k_h);
    }
    if ( typ_e == 2 && ( e_fill == 1 || e_fill == -1 )) //hexagon non-LO
    {
            for( theta = [30 : 60 : 330]) rotate( [0, 0, theta ] ) translate ( [0, s_e / 2 , 0 ] ) make_hook(k_h);
    }
}

module make_hook() {

    if (typ_h == 0) {//square hooks
    translate ([-2 * s_h,- 2.5 * s_h, 0]) {
        scale([s_h, s_h, s_h]) {
            hookPoints = [
            [  (1 - k_h ) ,  0 ] ,  //0
            [  2 + s_el / (2 * s_h ) ,  0 ] ,  //1
            [   2 + s_el / (2 * s_h )  ,  1 - ( 1 - k_h ) ] ,  //2
            [  k_h ,  1 - ( 1 - k_h) ] ,  //3
            [  (1 - k_h )  ,  1 - ( 1 - k_h ) ] ,  //4
            [  (1 - k_h )  ,  2.5 ] ,  //5
            [  k_h ,  2.5 ] ,  //6  
            [  ( 1  - k_h ) ,  4 - ( 1 - k_h ) ] ,  //7
            [  3 - ( 1 - k_h ) ,  4 - ( 1 - k_h ) ] ,  //8
            [  3 - ( 1 - k_h ) ,  3 + ( 1 - k_h ) ] ,  //9
            [  2 + ( 1 - k_h ) ,  3 + ( 1 - k_h ) ] ,  //10
            [  2 + ( 1 - k_h ) ,  2 + ( 1 - k_h ) ] ,  //11 
            [  3 - ( 1 - k_h ) ,  2 + ( 1 - k_h ) ] ,  //12 
            [  ( 1 - k_h ) ,  3 + ( 1 - k_h ) ] ,  //13
            [  k_h ,  3 + ( 1 - k_h ) ] ,  //14
            [  ( 1 - k_h ) ,  2.5 ] ,  //15
            [  2, -2 * t_h2e ] , //16
            [  4 -  ( 1 - k_h ) , 0 ] , //17 (replaces //1 chamfer parameter: c_h2e = 1)
            [  4 -  ( 1 - k_h ) ,  1 - ( 1 - k_h )  ] , //18 (replaces //2 chamfer parameter: c_h2e = 1)
            [  2 - s_el/ ( 2 * s_h ) , -t_h2e  ] ,//19 hook-2-element ligament chamfer left-side
            [  2 + s_el/ ( 2 * s_h ) , -t_h2e  ] ];//20 hook-2-element ligament chamfer right-side 
            if ( c_h2e == 0 ) {//no hook to element ligament chamfer
                hookPath = [[0,1,2,4], [3,4,5,6], [15,6,14,13], [13,7,8,9], [9,10,11,12] ];
                polygon(hookPoints, hookPath);
            }
            if ( c_h2e == 1 ) {//hook to element ligament chamfer
                hookPath = [[0,19,20,17,18,4], [3,4,5,6], [15,6,14,13], [13,7,8,9], [9,10,11,12] ];
                polygon(hookPoints, hookPath);
            }
        }
     }
     }
     if (typ_h == 1) {//round hooks
     /*
     NOTE:   The cut-out will go to a depth of s_h * [3 + (1 - hook kerf)]
            The length to the center of the element must be larger than this value.
     */
     scale( [s_h, s_h, s_h ] ) {
        
        //Tip
        translate( [-r_h, 0, 0 ] ) slice(r = s_tip_R, deg = 180 );
        
    
        
        //Hook Boss
        difference() {
            translate( [r_h, 0, 0]) rotate( [0, 0, 180]) slice(r = s_hook_OR, deg = 225 );
            translate( [-r_h, 0, 0 ] ) slice(r = s_hookneg_IR, deg = 180 );
        }
        if (e_fill == 0) { //LO Boss
            translate( [-r_h, 0, 0]) slice(r = 2*r_h + s_hook_OR, deg = 90 + asin((s_el - s_h) /2 / (s_hookneg_IR * s_h)) );
        }
        
        //Replacement Material (outside of hook)
        translate( [-r_h - s_hookneg_IR - s_ol, - s_hookneg_IR - s_ol, 0 ] ) {
           square( [s_hookneg_IR + s_ol, s_hookneg_IR - (1 - k_e) + s_ol] );
        }
        translate( [-r_h - s_ol, - s_hookneg_IR - s_ol, 0 ] ) {
            square( [s_hookneg_IR + 2 * s_tip_R + s_ol, s_hookneg_IR + s_ol ] );
        }
        
     }
     }
     
        
}

module place_hook_neg() {
    if ( typ_e == 0) { //square
        r_translate = l_sq / 2 * s_e;
        for( theta = [0 : 90 : 270]) {
            rotate( [0, 0, theta ] ) translate( [ 0, r_translate,0] ) hook_neg();
        }
    }
    if ( typ_e == 1) {//triangle        
        r_translate = r_min_tri * s_e;
        for( theta = [60 : 120 : 300]) {
            rotate( [0, 0, theta ] ) translate( [ 0, r_translate,0] ) hook_neg();
        }
   }
    if ( typ_e == 2 && (e_fill == -1 || e_fill == 1)) {//hexagon non-LO        
        r_translate = s_e /2;
        for( theta = [30 : 60 : 330]) {
            rotate( [0, 0, theta ] ) translate( [ 0, r_translate,0] ) hook_neg();
        }
    }
    if ( typ_e == 2 && e_fill == 0) {//hexagon LO
        r_translate = 2 * r_min_tri * s_e;
        for( theta = [0 : 60 : 300]) {
            rotate( [0, 0, theta ] ) translate( [ 0, r_translate,0] ) hook_neg();
        }
    }
}

module hook_neg() {
                scale( [s_h, s_h, s_h ] ) {
                    difference() {
                        //Hook Negative
                        translate( [-r_h,0,0]) slice(r = s_hookneg_IR, deg = 180);
                        //Hook Tip
                        translate( [-r_h, 0, 0 ] ) slice(r = s_tip_R, deg = 180 );
                    }
                    //Tip Negative
                    translate( [r_h, 0, 0]) rotate( [0, 0, 180]) slice(r = s_hook_IR, deg = 225 );
                    if ( e_fill == 0) {//LO negative material
                        difference() {// cleaning OD of hook
                            translate ( [ -r_h, 0, 0] ) slice(r = 3.5*r_h + s_hook_OR, deg = 90 ); 
                            translate( [-r_h, 0, 0]) slice(r = 2*r_h + s_hook_OR, deg = 90 );
                        }
                        rotate( [ 0, 0, -90 - (asin((s_el - s_h) /2 / (s_hookneg_IR * s_h)))] ) { //come-around section (driven by difference in s_el & s_h)
                            difference() {
                                translate ( [ -r_h, -r_h, 0] ) slice(r = 3*r_h + s_hook_OR, deg = 90 ); 
                                translate( [-r_h, -r_h, 0]) slice(r = 3*r_h, deg = 90);
                            }
                        }
                        translate( [-3*s_el/s_h/2,-5*r_h,0] ) square([s_el/s_h,4*r_h],false);
                        
                    }
                }
}

///BORROWED SUBROUTINES
module slice(r = 10, deg = 30) {
    //From OpenSCAD Forum User: Whosawhatsis
    degn = (deg % 360 > 0) ? deg % 360 : deg % 360 + 360;
   
    difference() {
    circle(r, $fn = 30); //, $fn = 100 removed to test
    if (degn > 180) intersection_for(a = [0, 180 - degn]) rotate(a) translate( [-r, 0, 0]) square(r * 2);
    else union() for(a = [0, 180 - degn]) rotate(a) translate( [-r, 0, 0]) square(r * 2);
    }
}
//()()()()()()()()()()
//Batch File Text
/*

FOR /L %%A IN (0,1,399) DO (
	"C:\Program Files\OpenSCAD\openscad" -o SUP-%%A.stl eellc_lib.scad -D eID=%%A
)

*/

////Notes for next version:
/*
-center support chamfers are currently lazily done with rectangles
  -upgrade to:
    -s_csc describing longest side of trapezoid
    -s_csl describing the height of that chamfer trapezoid
*/
