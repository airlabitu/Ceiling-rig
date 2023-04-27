/* ToDo
  Correct so master channels are implemented correct on all select / deselect interactions
  - issue found when (floods master is = 0, other flood channels are turned up, and flood groupe is selected)
  
*/

import processing.serial.*;

Serial DMX_connection; // Serial object for the DMX interface (Arduino Uno + DMX shield with the DMX simple library example "SerialToDMX" installed)

EquipmentButton [] eba; // array of lamp buttons

DimmerButtonGrid dbg;

EquipmentButton currentEnabled = null; // reference variable for the current enabled button

ArrayList<EquipmentButton> combined_list = new ArrayList<EquipmentButton>();

PImage rig;
PFont font_Prime_Regular_48;
PFont font_ArialMT_10;
PFont font_ArialMT_15;

final color MAIN_COL =  color(255,105,204);

// Variables for slider sections 

// current selected button (equipment)
SliderSection section_enabled_rgb_spot;
SliderSection section_enabled_flood;

// combined buttons (equipment)
SliderSection section_combined_rgb_spots;
SliderSection section_combined_floods;

// select multiple
EquipmentButton all_exhibition_rgb;
EquipmentButton all_floor_rgb;
EquipmentButton all_floor_flood;




// return states for EB update function
final int ENABLED_STATE = 0; 
final int COMBINE_STATE = 1;
final int TYPE_RGB_SPOT = 0;
final int TYPE_FLOOD = 1;


final int [] alpha_address =   {301, 307, 313, 319, 325, 331, 337, 343}; // alpha channels that needs to be turned up from beginning


void setup(){
  size(1104-140+40+135, 940);
  
  font_Prime_Regular_48 = loadFont("Prime-Regular-48.vlw");
  font_ArialMT_10 = loadFont("ArialMT-10.vlw");
  font_ArialMT_15 = loadFont("ArialMT-15.vlw");
  
  dbg = new DimmerButtonGrid(830, 105); // setup dimmer button grid
  
  //eba = new EquipmentButton[x_positions.length];
  eba = new EquipmentButton[25];
  
  setupFlood(0, 664, 874, 464, "FL1");
  setupFlood(1, 478, 874, 466, "FL2");
  setupFlood(2, 664, 687, 468, "FL3");
  setupFlood(3, 478, 687, 470, "FL4");
  setupFlood(4, 1012-348+20-20, 264, 472, "FL5");
  setupFlood(5, 776-348+20+30, 264, 474, "FL6");
  setupFlood(6, 1012-348+20-20, 74, 476, "FL7");
  setupFlood(7, 776-348+20+30, 74, 478, "FL8");
  
  setupRGB(8, 899-348+20, 750+20, 301, "RGB1");
  setupRGB(9, 710-348+20, 749+20, 307, "RGB2");
  setupRGB(10, 899-348+20, 560+20, 313, "RGB3");
  setupRGB(11, 710-348+20, 561+20, 319, "RGB4");
  setupRGB(12, 901-348+20, 385-30, 325, "RGB5");
  setupRGB(13, 711-348+20, 385-30, 331, "RGB6");
  setupRGB(14, 899-348+20, 197-30, 337, "RGB7");
  setupRGB(15, 710-348+20, 197-30, 343, "RGB8");
  
  
  setupRGBdesire(16, 740+20, 381, 200, "RGB10");
  setupRGBdesire(17, 741+20, 425, 205, "RGB11");
  setupRGBdesire(18, 740+20, 529, 210, "RGB12");
  setupRGBdesire(19, 739+20, 589, 215, "RGB13");
  setupRGBdesire(20, 739+20, 651, 220, "RGB14");
  setupRGBdesire(21, 739+20, 715, 225, "RGB15");
  setupRGBdesire(22, 739+20, 757, 230, "RGB17");
  setupRGBdesire(23, 739+20, 801, 235, "RGB18");
  setupRGBdesire(24, 709+20, 684, 240, "RGB19");
  
  
  all_exhibition_rgb = new EquipmentButton(870+20, 40+400-27, "exhibition groupe");
  all_exhibition_rgb.setType("flood");
  all_exhibition_rgb.setSize(150, 40);
  all_exhibition_rgb.setFont(font_ArialMT_15);
  
  all_floor_rgb = new EquipmentButton(870+20, 90+400-27, "floor RGB groupe");
  all_floor_rgb.setType("flood");
  all_floor_rgb.setSize(150, 40);
  all_floor_rgb.setFont(font_ArialMT_15);
  
  all_floor_flood = new EquipmentButton(870+20, 140+400-27, "floor Flood groupe");
  all_floor_flood.setType("flood");
  all_floor_flood.setSize(150, 40);
  all_floor_flood.setFont(font_ArialMT_15);


  section_enabled_rgb_spot = new SliderSection(35+20, 344+40-274);
  section_enabled_rgb_spot.addSlider("red");
  section_enabled_rgb_spot.addSlider("green");
  section_enabled_rgb_spot.addSlider("blue");
  
  section_enabled_flood = new SliderSection(35+20, 344+40-274);
  section_enabled_flood.addSlider("warm");
  section_enabled_flood.addSlider("cold");
  
  section_combined_rgb_spots = new SliderSection(35+20, 559+40-10-274);
  section_combined_rgb_spots.addSlider("red");
  section_combined_rgb_spots.addSlider("green");
  section_combined_rgb_spots.addSlider("blue");
  section_combined_rgb_spots.addSlider("master");
  section_combined_rgb_spots.getChannel("master").value = 255;
  
  section_combined_floods = new SliderSection(35+20, 809+40-274);
  section_combined_floods.addSlider("warm");
  section_combined_floods.addSlider("cold");
  section_combined_floods.addSlider("master");
  section_combined_floods.getChannel("master").value = 255;
  println("just added cold", section_combined_floods.sliders.get(1).channel.name);
  
  
  
  // --- CONNECTION TO SERIAL DEVICES ---
  println(Serial.list());
  for (int i = 0; i < Serial.list().length; i++){ // Arduino connected to universe 2
    println(Serial.list()[i]);
      //if (Serial.list()[i].indexOf("/dev/ttyACM0") != -1) {
      if (Serial.list()[i].indexOf("/dev/tty.usbmodem") != -1) {
        println("Serial connection to: ", Serial.list()[i]);
        DMX_connection = new Serial(this, Serial.list()[i], 115200);//230400);
    }
  }
  
  delay(3000); // wait for serial to be ready
  
  // turn up alpha channels
  if (DMX_connection != null){
    for (int i = 0; i < alpha_address.length; i++){
      if (alpha_address[i] != -1) sendDMX(alpha_address[i], 255);
    }
  }
  else println("Serial ERROR: not connected to DMX interface");
  
  rig = loadImage("rig.png");
  imageMode(CENTER);
  
  //textFont(font);
}

void draw(){
  background(0);
  
  //image(rig, width/2, height/2);
  rectMode(CORNER);
  
  //drawFrame(20+20, 20, 284, 304, "Power blocks");
  drawFrame(870+20-75, 70, 284, 304, "Power blocks");
  String label = "Single light";
  if (currentEnabled != null){
    if (currentEnabled.type == TYPE_RGB_SPOT) label += " : RGB Spot";
    else if (currentEnabled.type == TYPE_FLOOD) label += " : Flood";
  }
  drawFrame(20+20, 344-274, 284, 185, label);
  label = "Grouped lights : RGB";
  drawFrame(20+20, 549-274, 284, 235, label); // 325
  label = "Grouped lights : Flood";
  drawFrame(20+20, 804-274, 284, 190, label);
  drawRig(360+20, 70);
  
  for (int i = 0; i < eba.length; i++){
    eba[i].show(); // show buttons 
  }
  dbg.show(); // show buttons 
  
  
  if (currentEnabled != null){ // show current enabled slider section
    if (currentEnabled.type == TYPE_RGB_SPOT) section_enabled_rgb_spot.show();
    else if (currentEnabled.type == TYPE_FLOOD) section_enabled_flood.show();
  }
  
  // show the combined slider sections if any buttons are selected for combine
  if (countCombined(TYPE_FLOOD) > 0) {
    section_combined_floods.show();
    println(combined_list.size(), combined_list.get(0).ID);
  }
  if (countCombined(TYPE_RGB_SPOT) > 0) section_combined_rgb_spots.show();
  
  // show combine select by groupe buttons
  all_exhibition_rgb.show();
  all_floor_rgb.show();
  all_floor_flood.show();
  
}

void mouseReleased(){
  
  buttonManager(mouseX, mouseY, mouseButton);
  updateEnabledGUI();
  updateCombinedGUI();
  //println(countCombined(TYPE_FLOOD), countCombined(TYPE_RGB_SPOT));
  dbg.update(mouseX, mouseY);
  println(mouseX, mouseY);
}

void mouseDragged(){
  
  //buttonManager(mouseX, mouseY, mouseButton);
  updateEnabledGUI();
  updateCombinedGUI();
  //println(countCombined(TYPE_FLOOD), countCombined(TYPE_RGB_SPOT));
}

void keyReleased(){
  sendDMX(313, 255);
  
}

void buttonManager(int mouse_x, int mouse_y, int mouse_button){
  
  
  for (int i = 0; i < eba.length; i++){ // traverse all the buttons in Equipment Button Array (eba)
    
    int result = eba[i].update(mouse_x, mouse_y, mouse_button); // update on the current button
    
    // a enable action (on/off) "left click" was taken on a button
    if (result == ENABLED_STATE) { // this button was clicked
      if (eba[i].enabled_state) { // this button was enabled
        if (currentEnabled != null) currentEnabled.enabled_state = false; // disable previous button, if there is one
        currentEnabled = eba[i]; // set new reference to current button
        if (currentEnabled.type == TYPE_RGB_SPOT) section_enabled_rgb_spot.connectButton(currentEnabled); // connect current button channels to sliders
        else if (currentEnabled.type == TYPE_FLOOD) section_enabled_flood.connectButton(currentEnabled); // connect current button channels to sliders
      }
      else {
        // disconnect might not be needed, but good practice
        if (currentEnabled.type == TYPE_RGB_SPOT) section_enabled_rgb_spot.disconnectButton(); // disconnect current button channels from sliders
        else if (currentEnabled.type == TYPE_FLOOD) section_enabled_flood.disconnectButton(); // disconnect current button channels from sliders
        currentEnabled = null; // button state disabled
      }
    }
    // a combine action (on/off) "right click" was taken on a button
    else if (result == COMBINE_STATE){ // the combine state of this button was changed
      
      if (eba[i].combine_state){ // this button was added to combine
        // add thid button the the combined array list
        
        addCombined(eba[i]);
        
        
      }
      else { // this button was removed from combined
        // remove this button from the combined arraylist
        removeCombined(eba[i]);
      }
      // debug - to show the current combined buttons/lamps
      /*println();
      for (int j = 0; j < combined_list.size(); j++){
        println(combined_list.get(j).ID);
      } */
      
    }
  }
  
  // select / deselect a whole groupe
  setCombinedGroupe( (EquipmentButton[]) subset(eba, 0, 8), all_floor_flood);
  setCombinedGroupe( (EquipmentButton[]) subset(eba, 8, 8), all_floor_rgb);
  setCombinedGroupe( (EquipmentButton[]) subset(eba, 16, 9), all_exhibition_rgb);
  
  
  
}

void addCombined(EquipmentButton add_item){
  combined_list.add(add_item);
  
  // update this button/lamp with the combined gui slider data
        if (add_item.type == TYPE_RGB_SPOT) {
          float factor = map(section_combined_rgb_spots.getChannel("master").value, 0, 255, 0, 1);
          for (Slider ss : section_combined_rgb_spots.sliders){
            if (!ss.channel.name.equals("master")) {
              add_item.updateChannel(ss.channel.name, ss.channel.value);
              // send DMX date
              Channel ch = add_item.getChannel(ss.channel.name);
              println("UPDATE combine added", ch.name, ch.address, int(ch.value*factor));
              sendDMX(ch.address, int(ch.value*factor));
            }
          }
        }
        else if (add_item.type == TYPE_FLOOD) {
          float factor = map(section_combined_floods.getChannel("master").value, 0, 255, 0, 1);
          for (Slider ss : section_combined_floods.sliders){
            if (!ss.channel.name.equals("master")) {
              add_item.updateChannel(ss.channel.name, ss.channel.value);
              // send DMX data
              Channel ch = add_item.getChannel(ss.channel.name);
              println("UPDATE combine added", ch.name, ch.address, int(ch.value*factor));
              sendDMX(ch.address, int(ch.value*factor));
            }
          }
        }
}

void removeCombined(EquipmentButton remove_item){
  for (int i = 0; i < combined_list.size(); i++){
    if (combined_list.get(i).ID == remove_item.ID) combined_list.remove(i);
  }
}

void updateEnabledGUI(){
  
  if (currentEnabled != null){
    Channel ch = null;
    if (currentEnabled.type == TYPE_RGB_SPOT) ch = section_enabled_rgb_spot.update();
    else if (currentEnabled.type == TYPE_FLOOD) ch = section_enabled_flood.update();
    
    if (ch != null) {
      println("UPDATED enable:", ch.name, ch.address, ch.value); // NB: ch will ne 'null' if no sliders where moved - send DMX data out here
      sendDMX(ch.address, ch.value);
    }
  }
}

void updateCombinedGUI(){
  
  // NB: the reason for having two quite similar sections here is that it is sddressing two different slider sections
  
  if (countCombined(TYPE_RGB_SPOT) > 0){
    Channel combine_ch = null;
    combine_ch = section_combined_rgb_spots.update();
    if (combine_ch != null) { // a rgb spot combined slider was moved
      float factor = map(section_combined_rgb_spots.getChannel("master").value, 0, 255, 0, 1);
      println("master factor", factor);
      boolean isMaster = false;
      if (combine_ch.name.equals("master")) isMaster = true;
      
      for (EquipmentButton eb : combined_list){
        if (eb.type == TYPE_RGB_SPOT) { // FILTER: use only the rgb spots
        
          if(!isMaster){
            eb.updateChannel(combine_ch.name, combine_ch.value);
            Channel ch = eb.getChannel(combine_ch.name); // get the channel altered for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
          }
          else {
            Channel ch = eb.getChannel("red"); // get the red channel for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined master red:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
            ch = eb.getChannel("green"); // get the green channel for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined master green:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
            ch = eb.getChannel("blue"); // get the red channel for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined master blue:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
          }
        }
      }
    }
  }
  if (countCombined(TYPE_FLOOD) > 0){
    Channel combine_ch = null;
    combine_ch = section_combined_floods.update();
    if (combine_ch != null) { // a rgb spot combined slider was moved
      
      float factor = map(section_combined_floods.getChannel("master").value, 0, 255, 0, 1);
      println("master factor", factor);
      boolean isMaster = false;
      if (combine_ch.name.equals("master")) isMaster = true;
      
      for (EquipmentButton eb : combined_list){
        if (eb.type == TYPE_FLOOD) { // FILTER: use only the floods
          
          if(!isMaster){
            eb.updateChannel(combine_ch.name, combine_ch.value);
            Channel ch = eb.getChannel(combine_ch.name); // get the channel altered for this equipment button 
            println("UPDATED combined:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
            sendDMX(ch.address, int(ch.value*factor));
          }
          else{
            Channel ch = eb.getChannel("warm"); // get the red channel for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined master warm:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
            ch = eb.getChannel("cold"); // get the green channel for this equipment button
            sendDMX(ch.address, int(ch.value*factor));
            println("UPDATED combined master cold:", ch.name, ch.address, int(ch.value*factor)); // send DMX data out here
          }
        }
      }
    }
  }

}

int countCombined(int type){
  int count = 0;
  for (EquipmentButton eb : combined_list){
    if (eb.type == type) count++; 
  }
  return count;
}

// helper function for sendint out the DMX messages via the serial connection
void sendDMX(int address, int value){
  if (DMX_connection != null) DMX_connection.write(address + "c" + value + "w");
  else println("DMX ERROR : null pointer exception");
  println("DMX", address, value);
}

void setupFlood(int index, int x, int y, int addr, String id){
  eba[index] = new EquipmentButton(x, y, id);
  eba[index].setType("flood");
  eba[index].addChannel("cold", addr);
  eba[index].addChannel("warm", addr+1);
}

void setupRGB(int index, int x, int y, int addr, String id){
  eba[index] = new EquipmentButton(x, y, id);
  eba[index].setType("rgb_spot");
  eba[index].addChannel("red", addr+1);
  eba[index].addChannel("green", addr+2);
  eba[index].addChannel("blue", addr+3);
}

void setupRGBdesire(int index, int x, int y, int addr, String id){
  eba[index] = new EquipmentButton(x, y, id);
  eba[index].setType("rgb_spot");
  eba[index].addChannel("red", addr);
  eba[index].addChannel("green", addr+1);
  eba[index].addChannel("blue", addr+2);
}

void drawRig(int x, int y){
  
  
  
  fill(255,105,204);
  noStroke();
  int w = 7;
  int l = 383;
  
  textFont(font_Prime_Regular_48);
  textSize(38);
  textAlign(CENTER, BOTTOM);
  text("Atrium", x+l/2-w/2, y-2);
  
  
  rect(x, y, w, l);
  rect(x+l/2-w/2, y, w, l);
  rect(x+l-w, y, w, l);
  
  rect(x, y, l, w);
  rect(x, y+l/2-w/2, l, w);
  rect(x, y+376, l, w);
  
  
  y += 421; 
  rect(x, y, w, l);
  rect(x+l/2-w/2, y, w, l);
  rect(x+l-w, y, w, l);
  
  rect(x, y, l, w);
  rect(x, y+l/2-w/2, l, w);
  rect(x, y+376, l, w);
  
  textAlign(CENTER, TOP);
  text("Window", x+l/2-w/2+5, y+l+10);
  
}


void drawFrame(int x, int y, int w, int h, String label){
  rectMode(CORNER);
  stroke(MAIN_COL);
  strokeWeight(2);
  fill(0);  
  rect(x, y, w, h);
  fill(MAIN_COL);
  textFont(font_ArialMT_15);
  textSize(12);
  textAlign(LEFT, TOP);
  text(label, x+15, y+13);
}

void setCombinedGroupe(EquipmentButton [] eb_array, EquipmentButton trigger_button){
  // select exhibition RGB groupe
  int result = trigger_button.update(mouseX, mouseY, LEFT);
  if (result == 0){
    if (trigger_button.enabled_state) {
      for (int i = 0; i < eb_array.length; i++) {
        if (!hasCombined(eb_array[i].ID)) {
          addCombined(eb_array[i]);
          eb_array[i].combine_state = true;
        }
      }
        
    }
    else {
      for (int i = 0; i < eb_array.length; i++) {
        removeCombined(eb_array[i]);
        eb_array[i].combine_state = false;
      }
    }
  }

}

boolean hasCombined(String ID){
  
  for (EquipmentButton eb : combined_list){
    if (eb.ID.equals(ID)) return true;
  }
  return false;
}
