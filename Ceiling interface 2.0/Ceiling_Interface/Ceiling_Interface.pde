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

boolean usb_error = false;

// mouse interaction variables
int mouse_drag_y_origin;
int mouse_drag_x_origin;


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

// turn off all equipment
EquipmentButton kill_all;
long kill_all_pressed_time = 0;
//boolean kill_all_pressed = false;

// return states for EB update function
final int ENABLED_STATE = 0; 
final int COMBINE_STATE = 1;
final int TYPE_RGB_SPOT = 0;
final int TYPE_FLOOD = 1;

final int [] alpha_address =   {301, 307, 313, 319, 325, 331, 337, 343}; // alpha channels that needs to be turned up from beginning



void setup(){
  size(1179, 940);
  PImage icon = loadImage("icon.png");
  surface.setIcon(icon);

  font_Prime_Regular_48 = loadFont("Prime-Regular-48.vlw");
  font_ArialMT_10 = loadFont("ArialMT-10.vlw");
  font_ArialMT_15 = loadFont("ArialMT-15.vlw");
  
  dbg = new DimmerButtonGrid(870, 105); // setup dimmer button grid
  
  eba = new EquipmentButton[25];
  
  setupFlood(0, 684, 874, 464, "FL1");
  setupFlood(1, 498, 874, 466, "FL2");
  setupFlood(2, 684, 687, 468, "FL3");
  setupFlood(3, 498, 687, 470, "FL4");
  setupFlood(4, 684, 264, 472, "FL5");
  setupFlood(5, 498, 264, 474, "FL6");
  setupFlood(6, 684, 74, 476, "FL7");
  setupFlood(7, 498, 74, 478, "FL8");
  
  setupRGB(8, 591, 770, 301, "RGB1");
  setupRGB(9, 402, 769, 307, "RGB2");
  setupRGB(10, 591, 580, 313, "RGB3");
  setupRGB(11, 402, 581, 319, "RGB4");
  setupRGB(12, 591, 355, 325, "RGB5");
  setupRGB(13, 402, 355, 331, "RGB6");
  setupRGB(14, 591, 167, 337, "RGB7");
  setupRGB(15, 402, 167, 343, "RGB8");
  
  setupRGBdesire(16, 780, 381, 200, "RGB10");
  setupRGBdesire(17, 780, 425, 205, "RGB11");
  setupRGBdesire(18, 780, 529, 210, "RGB12");
  setupRGBdesire(19, 780, 589, 215, "RGB13");
  setupRGBdesire(20, 780, 651, 220, "RGB14");
  setupRGBdesire(21, 780, 715, 225, "RGB15");
  setupRGBdesire(22, 780, 757, 230, "RGB17");
  setupRGBdesire(23, 780, 801, 235, "RGB18");
  setupRGBdesire(24, 750, 684, 240, "RGB19");
  
  all_exhibition_rgb = new EquipmentButton(930, 413, "exhibition groupe");
  all_exhibition_rgb.setType("flood");
  all_exhibition_rgb.setSize(150, 40);
  all_exhibition_rgb.setFont(font_ArialMT_15);
  
  all_floor_rgb = new EquipmentButton(930, 463, "floor RGB groupe");
  all_floor_rgb.setType("flood");
  all_floor_rgb.setSize(150, 40);
  all_floor_rgb.setFont(font_ArialMT_15);
  
  all_floor_flood = new EquipmentButton(930, 513, "floor Flood groupe");
  all_floor_flood.setType("flood");
  all_floor_flood.setSize(150, 40);
  all_floor_flood.setFont(font_ArialMT_15);
  
  
  
  kill_all = new EquipmentButton(930, 563, "kill all");
  kill_all.setType("flood");
  kill_all.setSize(150, 40);
  kill_all.setFont(font_ArialMT_15);

  section_enabled_rgb_spot = new SliderSection(55, 110);
  section_enabled_rgb_spot.addSlider("red");
  section_enabled_rgb_spot.addSlider("green");
  section_enabled_rgb_spot.addSlider("blue");
  
  section_enabled_flood = new SliderSection(55, 110);
  section_enabled_flood.addSlider("warm");
  section_enabled_flood.addSlider("cold");
  
  section_combined_rgb_spots = new SliderSection(55, 315);
  section_combined_rgb_spots.addSlider("red");
  section_combined_rgb_spots.addSlider("green");
  section_combined_rgb_spots.addSlider("blue");
  section_combined_rgb_spots.addSlider("master");
  section_combined_rgb_spots.getChannel("master").value = 255;
  
  section_combined_floods = new SliderSection(55, 575);
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
  else {
    println("Serial ERROR: not connected to DMX interface");
    usb_error = true;
  }
  rig = loadImage("rig.png");
  imageMode(CENTER);
}

void draw(){
  background(0);
  rectMode(CORNER);
  
  drawFrame(855, 70, 284, 304, "Power blocks");
  String label = "Single light";
  if (currentEnabled != null){
    if (currentEnabled.type == TYPE_RGB_SPOT) label += " : RGB Spot";
    else if (currentEnabled.type == TYPE_FLOOD) label += " : Flood";
  }
  drawFrame(40, 70, 284, 185, label);
  label = "Grouped lights : RGB";
  drawFrame(40, 275, 284, 235, label); // 325
  label = "Grouped lights : Flood";
  drawFrame(40, 530, 284, 190, label);
  drawRig(400, 70);
  
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
    //println(combined_list.size(), combined_list.get(0).ID);
  }
  if (countCombined(TYPE_RGB_SPOT) > 0) section_combined_rgb_spots.show();
  
  // show combine select by groupe buttons
  all_exhibition_rgb.show();
  all_floor_rgb.show();
  all_floor_flood.show();
  // show kill all button
  kill_all.show();
  
  if (usb_error) USBError();
  
  if (kill_all.enabled_state && millis() > kill_all_pressed_time + 150) kill_all.enabled_state = false;
}

void mouseReleased(){
  buttonManager(mouseX, mouseY, mouseButton);
  updateEnabledGUI(mouse_drag_x_origin, mouseX, mouseY);
  updateCombinedGUI(mouse_drag_x_origin, mouseX, mouseY);
  dbg.update(mouseX, mouseY);
}


void mouseDragged(){
  updateEnabledGUI(mouse_drag_x_origin, mouseX, mouse_drag_y_origin);
  updateCombinedGUI(mouse_drag_x_origin, mouseX,mouse_drag_y_origin);
}

void keyReleased(){
  sendDMX(313, 255);
}

void mousePressed(){
  mouse_drag_y_origin = mouseY;
  mouse_drag_x_origin = mouseX;
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
  

  
  int result = kill_all.update(mouseX, mouseY, LEFT);
  if (result == 0){
    if (kill_all.enabled_state) {
      killAll();
    }
  }
  //if (kill_all_pressed_time >)
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

void updateEnabledGUI(int x_origin_, int x_, int y_){
  
  if (currentEnabled != null){
    Channel ch = null;
    if (currentEnabled.type == TYPE_RGB_SPOT) ch = section_enabled_rgb_spot.update(x_origin_, x_, y_);
    else if (currentEnabled.type == TYPE_FLOOD) ch = section_enabled_flood.update(x_origin_, x_, y_);
    
    if (ch != null) {
      println("UPDATED enable:", ch.name, ch.address, ch.value); // NB: ch will ne 'null' if no sliders where moved - send DMX data out here
      sendDMX(ch.address, ch.value);
    }
  }
}

void updateCombinedGUI(int x_origin_, int x_, int y_){
  
  // NB: the reason for having two quite similar sections here is that it is sddressing two different slider sections
  
  if (countCombined(TYPE_RGB_SPOT) > 0){
    Channel combine_ch = null;
    combine_ch = section_combined_rgb_spots.update(x_origin_, x_, y_);
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
    combine_ch = section_combined_floods.update(x_origin_, x_, y_);
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

void USBError(){
  background(0);
  fill(MAIN_COL);
  textFont(font_Prime_Regular_48);
  textAlign (CENTER, CENTER);
  text("DMX USB interface not connected", width/2, height/2);
  noLoop();
}

void killAll(){
  
  // ToDo
  // disconnect buttons from sliders, so sliders disapear again
  // make it send DMX
  
  for (EquipmentButton eb : eba){
    for (Channel ch : eb.channels){
      //if (ch.name.equals("master") eb.updateChannel(ch.name,255);
      if (ch.value != 0) sendDMX(ch.address, 0);
      eb.updateChannel(ch.name,0);
      eb.combine_state = false;
      eb.enabled_state = false;
      //sendDMX(ch.address, ch.value);
    }
  }
  
  for (EquipmentButton eb : dbg.dba){
    for (Channel ch : eb.channels){
      //if (ch.name.equals("master") eb.updateChannel(ch.name,255);
      println("CH value", ch.value);
      if (ch.value != 0) sendDMX(ch.address, 0);
      eb.updateChannel(ch.name,0);
      eb.combine_state = false;
      eb.enabled_state = false;
      //sendDMX(ch.address, 0);
    }
  }
  
  // reset all sliders
  for (Slider ss : section_combined_rgb_spots.sliders){
    if (ss.channel != null){
      if(ss.channel.name.equals("master")) ss.setValue(255);
      else ss.setValue(0);
    }
  }
   
  for (Slider ss : section_combined_floods.sliders){
    if (ss.channel != null){
      if(ss.channel.name.equals("master")) ss.setValue(255);
      else ss.setValue(0);
    }
  }
  
  for (Slider ss : section_enabled_rgb_spot.sliders){
    if (ss.channel != null) ss.setValue(0);
  }
  
  section_enabled_rgb_spot.disconnectButton();
  section_enabled_flood.disconnectButton();
  
  all_exhibition_rgb.enabled_state = false;
  all_floor_rgb.enabled_state = false;
  all_floor_flood.enabled_state = false;
  
  combined_list.clear(); 
  
  currentEnabled = null; // button state disabled
  
  kill_all_pressed_time = millis();
}
