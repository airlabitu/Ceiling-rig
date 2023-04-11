/* ToDo
  Setup the full ceiling rig map
  Implement dimmer blocks interface
  
  Test the dimmer block interface
  Implement Thomas input
  - A alpha channel on the combined settings
  - Shortcut fore something??? ask Thomas again
*/

import processing.serial.*;

Serial DMX_connection; // Serial object for the DMX interface (Arduino Uno + DMX shield with the DMX simple library example "SerialToDMX" installed)

EquipmentButton [] eba; // array of lamp buttons

DimmerButtonGrid dbg;

EquipmentButton currentEnabled = null; // reference variable for the current enabled button

ArrayList<EquipmentButton> combined_list = new ArrayList<EquipmentButton>();

PImage rig;
PFont font;
PFont font_small;

// Variables for slider sections 

// current selected button (equipment)
SliderSection section_enabled_rgb_spot;
SliderSection section_enabled_flood;

// combined buttons (equipment)
SliderSection section_combined_rgb_spots;
SliderSection section_combined_floods;


// return states for EB update function
final int ENABLED_STATE = 0; 
final int COMBINE_STATE = 1;
final int TYPE_RGB_SPOT = 0;
final int TYPE_FLOOD = 1;


final int [] alpha_address =   {301, 307, 313, 319, 325, 331, 337, 343}; // alpha channels that needs to be turned up from beginning


void setup(){
  size(1104, 950);
  
  dbg = new DimmerButtonGrid(); // setup dimmer button grid
  
  //eba = new EquipmentButton[x_positions.length];
  eba = new EquipmentButton[25];
  
  setupFlood(0, 1012-348, 874, 464, "FL1");
  setupFlood(1, 776-348, 874, 466, "FL2");
  setupFlood(2, 1012-348, 687, 468, "FL3");
  setupFlood(3, 776-348, 687, 470, "FL4");
  setupFlood(4, 1012-348, 264, 472, "FL5");
  setupFlood(5, 776-348, 264, 474, "FL6");
  setupFlood(6, 1012-348, 74, 476, "FL7");
  setupFlood(7, 776-348, 74, 478, "FL8");
  
  setupRGB(8, 899-348, 750, 301, "RGB1");
  setupRGB(9, 710-348, 749, 307, "RGB2");
  setupRGB(10, 899-348, 560, 313, "RGB3");
  setupRGB(11, 710-348, 561, 319, "RGB4");
  setupRGB(12, 901-348, 409, 325, "RGB5");
  setupRGB(13, 711-348, 385, 331, "RGB6");
  setupRGB(14, 899-348, 140, 337, "RGB7");
  setupRGB(15, 710-348, 197, 343, "RGB8");
  
  
  setupRGBdesire(16, 740, 381, 200, "RGB10");
  setupRGBdesire(17, 741, 425, 205, "RGB11");
  setupRGBdesire(18, 740, 529, 210, "RGB12");
  setupRGBdesire(19, 739, 589, 215, "RGB13");
  setupRGBdesire(20, 739, 651, 220, "RGB14");
  setupRGBdesire(21, 739, 715, 225, "RGB15");
  setupRGBdesire(22, 739, 757, 230, "RGB17");
  setupRGBdesire(23, 739, 801, 235, "RGB17");
  setupRGBdesire(24, 709, 684, 240, "RGB18");
  
  
  

  section_enabled_rgb_spot = new SliderSection(45, 85);
  section_enabled_rgb_spot.addSlider("red");
  section_enabled_rgb_spot.addSlider("green");
  section_enabled_rgb_spot.addSlider("blue");
  
  section_enabled_flood = new SliderSection(45, 85);
  section_enabled_flood.addSlider("warm");
  section_enabled_flood.addSlider("cold");
  
  section_combined_rgb_spots = new SliderSection(804, 340);
  section_combined_rgb_spots.addSlider("red");
  section_combined_rgb_spots.addSlider("green");
  section_combined_rgb_spots.addSlider("blue");
  
  section_combined_floods = new SliderSection(804, 520);
  section_combined_floods.addSlider("warm");
  section_combined_floods.addSlider("cold");
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
  font = loadFont("Prime-Regular-48.vlw");
  font_small = loadFont("ArialMT-10.vlw");
  //textFont(font);
}

void draw(){
  background(0);
  
  //image(rig, width/2, height/2);
  rectMode(CORNER);
  
  drawRig(360, 70);
  //drawRigModule(360, 491);
  
  for (int i = 0; i < eba.length; i++){
    eba[i].show(); // show buttons 
  }
  dbg.show(); // show buttons 
  
  
  if (currentEnabled != null){ // show current enabled slider section
    if (currentEnabled.type == TYPE_RGB_SPOT) section_enabled_rgb_spot.show();
    else if (currentEnabled.type == TYPE_FLOOD) section_enabled_flood.show();
  }
  
  // show the combined slider sections if any buttons are selected for combine
  if (countCombined(TYPE_FLOOD) > 0) section_combined_floods.show();
  if (countCombined(TYPE_RGB_SPOT) > 0) section_combined_rgb_spots.show();
  
  
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
        
        // update this button/lamp with the combined gui slider data
        if (eba[i].type == TYPE_RGB_SPOT) {
          for (Slider ss : section_combined_rgb_spots.sliders){
            eba[i].updateChannel(ss.channel.name, ss.channel.value);
            // send DMX date
            Channel ch = eba[i].getChannel(ss.channel.name);
            println("UPDATE combine added", ch.name, ch.address, ch.value);
            sendDMX(ch.address, ch.value);
          }
        }
        else if (eba[i].type == TYPE_FLOOD) {
          for (Slider ss : section_combined_floods.sliders){
            eba[i].updateChannel(ss.channel.name, ss.channel.value);
            // send DMX data
            Channel ch = eba[i].getChannel(ss.channel.name);
            println("UPDATE combine added", ch.name, ch.address, ch.value);
            sendDMX(ch.address, ch.value);
          }
        }
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
  
  
  
}

void addCombined(EquipmentButton add_item){
  combined_list.add(add_item);
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
      for (EquipmentButton eb : combined_list){
        if (eb.type == TYPE_RGB_SPOT) { // FILTER: use only the rgb spots
          eb.updateChannel(combine_ch.name, combine_ch.value);
          Channel ch = eb.getChannel(combine_ch.name); // get the channel altered for this equipment button 
          println("UPDATED combined:", ch.name, ch.address, ch.value); // send DMX data out here
          sendDMX(ch.address, ch.value);
        }
      }
    }
  }
  if (countCombined(TYPE_FLOOD) > 0){
    Channel combine_ch = null;
    combine_ch = section_combined_floods.update();
    if (combine_ch != null) { // a rgb spot combined slider was moved
      for (EquipmentButton eb : combined_list){
        if (eb.type == TYPE_FLOOD) { // FILTER: use only the floods
          eb.updateChannel(combine_ch.name, combine_ch.value);
          Channel ch = eb.getChannel(combine_ch.name); // get the channel altered for this equipment button 
          println("UPDATED combined:", ch.name, ch.address, ch.value); // send DMX data out here
          sendDMX(ch.address, ch.value);
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
  DMX_connection.write(address + "c" + value + "w");
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
  
  textFont(font);
  textSize(52);
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
  text("Window", x+l/2-w/2, y+l+10);
  
}
