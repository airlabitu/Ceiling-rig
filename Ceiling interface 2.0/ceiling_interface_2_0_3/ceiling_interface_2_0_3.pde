// ToDo
// make lamps with many channels more maintainable
// Make a shortcut selection area
// make a intensity / alpha slider for RGB spots
// make second single click on lamps close it on the left side

//color gui_background = color(255,105,204);
//color gui_foreground = color(238,246,89);

PImage rig;

Flood [] flood_lights;
Flood floods_combined;

RGB_spot[] rgb_spots;
RGB_spot rgb_spots_combined;

//long timer;
//int interval = 500;

int open_gui_floods = -1;

int open_gui_rgb_spots = -1;

void setup(){
  size(1200, 950);
  flood_lights = new Flood[4];
  
  flood_lights[0] = new Flood(477, 80, 20, 70);
  flood_lights[0].address = 1;
  flood_lights[0].id = "FL_1";
  
  flood_lights[1] = new Flood(723, 75, 20, 70);
  flood_lights[1].address = 3;
  flood_lights[1].id = "FL_2";
  
  flood_lights[2] = new Flood(475, 265, 20, 70);
  flood_lights[2].address = 5;
  flood_lights[2].id = "FL_3";
  
  flood_lights[3] = new Flood(721, 264, 20, 70);
  flood_lights[3].address = 7;
  flood_lights[3].id = "FL_4";
  
  
  
  floods_combined = new Flood(-100, -100, width-300, 70);
  floods_combined.disable_close_gui = true;
  floods_combined.gui_enabled = false;
  floods_combined.id = "Combined";
  floods_combined.DMX_enabled = false;
  
  
  rgb_spots = new RGB_spot[4];
  
  rgb_spots[0] = new RGB_spot(411, 197, 20, 220);
  rgb_spots[0].address = 1;
  rgb_spots[0].id = "RGB_1";
  
  rgb_spots[1] = new RGB_spot(599, 140, 20, 220);
  rgb_spots[1].address = 1;
  rgb_spots[1].id = "RGB_2";
  
  rgb_spots[2] = new RGB_spot(411, 384, 20, 220);
  rgb_spots[2].address = 1;
  rgb_spots[2].id = "RGB_3";
  
  rgb_spots[3] = new RGB_spot(598, 409, 20, 220);
  rgb_spots[3].address = 1;
  rgb_spots[3].id = "RGB_4";
  
  rgb_spots_combined = new RGB_spot(-100, -100, width-300, 220);
  rgb_spots_combined.disable_close_gui = true;
  rgb_spots_combined.gui_enabled = false;
  rgb_spots_combined.id = "Combined";
  rgb_spots_combined.DMX_enabled = false;
  
  
  
  rig = loadImage("rig.png");
  imageMode(CENTER);
  
  textAlign(CENTER);
  
}

void draw(){
  background(0);
  image(rig, width/2, height/2); 
  for (int i = 0; i < flood_lights.length; i++)  flood_lights[i].show_gui(); // display the GUI
  floods_combined.show_gui();
  
  for (int i = 0; i < rgb_spots.length; i++)  rgb_spots[i].show_gui(); // display the GUI
  rgb_spots_combined.show_gui();
  
  /*
  // timer for sending DMX updates to lights
  if (millis() - timer > interval){
    for (int i = 0; i < flood_lights.length; i ++){
      flood_lights[i].update_light();
    }
  }
  */
}

void mouseReleased(){
  
  // if LEFT mouse button is releases
    // CHECK open/close buttons
    // loop through all
      // if mouse over this lamp's toggle button
      
  
  
  // if LEFT mouse button and combined gui open
    // run combined sliders
    // if changes made
      // set new value(s) on all combined lamnps
  
  // else loop through all lamps
    
    // # CHECK OPEN/CLOSE combined
    // if RIGHT mouse button
      // create combined lamps counter (init -1)
      // is mouse over current's on/off toggle button
        // toggle the combined counter
        // if current state is combined increment the combined counter
    
    // # CHECK OPEN/CLOSE of individual gui and interaction on individual lamp gui's
    // else if LEFT mouse button 
      // is current's gui open
        // process as gui/slider interaction
      // else if mouse over current's toggle button
        // save future gui open state of this lamp
        // close all gui's (use foor loop)
        // set gui state for current to saved state
    


    
    
    
      
  // LEFT mouse button
    // CHECK OPEN GUI INTERACTION
    // loop through all
      // if gui is open
        // check and process slider interactions
        
    // CHECK OPEN/CLOSE individual
    // loop through all
      // is mouse over current's toggle
        // save future gui open state of this lamp
        // set all lamps to gui closed
        // set new state of 'this' lamp gui
    
    // CHECK OPEN GUI   
       
      // if currently closed
        // open it
        // if (current_open_gui != null)
        // set to current_open_gui
      // else if currently open, close it
    // else is mouse over open lamp gui
  
  // RIGHT mouse button
    // CHECK OPEN/CLOSE combined
    // create combined counter (init -1)
    // loop through all
      // is mouse over current's toggle
        // toggle the combined counter
      // if current state is combined increment the combined counter
    // if counter is -1 disable combined gui
    // else open combined counter
  
  int count_combine = 0; // for counting number of combined flood lights
  
  // FLOOD LIGHTS
  for (int i = 0; i < flood_lights.length; i++) {
    int result = flood_lights[i].update_gui();
    if (result != 5) println("result", result, "ID", flood_lights[i].id);
    
    if (result == 0 && flood_lights[i].combine_check){ // combine variable was toggled and new status is 'true'  
      flood_lights[i].setWarm(floods_combined.getWarm()); // set this flood lamp to same values as floods_combined
      flood_lights[i].setCold(floods_combined.getCold()); // set this flood lamp to same values as floods_combined
    }
    
    if (result == 1){ // a lamp gui was opened
      if (open_gui_floods != -1) flood_lights[open_gui_floods].gui_enabled = false; // if a gui was already open, close it
      open_gui_floods = i; // update to the new gui number
    } 
    if (result == 2) open_gui_floods = -1; // if a gui was closed, update to no gui open
  
    if(flood_lights[i].combine_check) count_combine++; // count the combined 
  }
  
  if (count_combine == 0) floods_combined.gui_enabled = false;
  else floods_combined.gui_enabled = true;
  
  updateFloodsCombined();
  
  
  
  count_combine = 0; // reset for counting number of combined rgb spot lights
  
  // RGB SPOTS
    for (int i = 0; i < rgb_spots.length; i++) {
    int result = rgb_spots[i].update_gui();
    if (result != 5) println("result", result, "ID", rgb_spots[i].id);
    
    if (result == 0 && rgb_spots[i].combine_check){ // combine variable was toggled and new status is 'true'  
      rgb_spots[i].setRed(rgb_spots_combined.getRed()); // set this RGB lamp to same values as rgb_spots_combined
      rgb_spots[i].setGreen(rgb_spots_combined.getGreen()); // set this RGB lamp to same values as rgb_spots_combined
      rgb_spots[i].setBlue(rgb_spots_combined.getBlue()); // set this RGB lamp to same values as rgb_spots_combined
    }
    
    if (result == 1){ // a gui was opened
      if (open_gui_rgb_spots != -1) rgb_spots[open_gui_rgb_spots].gui_enabled = false; // if another gui was already open, close it
      open_gui_rgb_spots = i; // update to the new gui number
    } 
    if (result == 2) open_gui_rgb_spots = -1; // if a gui was closed, update to no gui open
  
    if(rgb_spots[i].combine_check) count_combine++; // count the combined 
  }
  
  if (count_combine == 0) rgb_spots_combined.gui_enabled = false;
  else rgb_spots_combined.gui_enabled = true;
  
  updateRGBSpotsCombined();
  
  
  println(mouseX+", ", mouseY);
}

void mouseDragged(){
  if (open_gui_floods != -1) {
    if (flood_lights[open_gui_floods].update_gui() == 2) open_gui_floods = -1; // check dragging for open gui, and update 'open_gui' if the gui was closed with drag
    
  }
  updateFloodsCombined();
  
  
  if (open_gui_rgb_spots != -1) {
    if (rgb_spots[open_gui_rgb_spots].update_gui() == 2) open_gui_rgb_spots = -1; // check dragging for open gui, and update 'open_gui' if the gui was closed with drag
    
  }
  updateRGBSpotsCombined();

}

void updateFloodsCombined(){
  int result = floods_combined.update_gui();
  if (result == 3) { // warms or cold was updated;
    for (int i = 0; i < flood_lights.length; i++){
      if (flood_lights[i].combine_check) {
        if (flood_lights[i].setWarm(floods_combined.slider_warm.val)) println("warm", flood_lights[i].slider_warm.val);
        if (flood_lights[i].setCold(floods_combined.slider_cold.val)) println("cold", flood_lights[i].slider_cold.val);
      }
    }
  } 
}

void updateRGBSpotsCombined(){
  int result = rgb_spots_combined.update_gui();
  if (result == 3) { // red, green or blue was updated;
    for (int i = 0; i < rgb_spots.length; i++){
      if (rgb_spots[i].combine_check) {
        if (rgb_spots[i].setRed(rgb_spots_combined.slider_red.val)) println("red", rgb_spots[i].slider_red.val);
        if (rgb_spots[i].setGreen(rgb_spots_combined.slider_green.val)) println("green", rgb_spots[i].slider_green.val);
        if (rgb_spots[i].setBlue(rgb_spots_combined.slider_blue.val)) println("blue", rgb_spots[i].slider_blue.val);
      }
    }
  } 
}
