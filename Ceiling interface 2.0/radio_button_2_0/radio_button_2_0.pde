/* ToDo
  test the DMX serial connection
  Then test if the lights react as expected, with both individual setting colors and combined actions
  Setup the full ceiling rig map
  Implement dimmer blocks interface
  Test the dimmer block interface
  Implement Thomas input
  - A alpha channel on the combined settings
  - Shortcut fore something??? ask Thomas again
*/

import processing.serial.*;

Serial DMX_connection; // Serial object for the DMX interface (Arduino Uno + DMX shield with the DMX simple library example "SerialToDMX" installed)

EquipmentButton [] eba; // array of buttons

EquipmentButton currentEnabled = null; // reference variable for the current enabled button

ArrayList<EquipmentButton> combined_list = new ArrayList<EquipmentButton>();

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

// arrays to define all the equipment buttons - this is where the button layout is defined (add/remove equipment here)
final int [] x_positions = {    100,       100,          100,          100,       100};
final int [] y_positions = {    100,       150,          200,          250,       300};
final int [] addresses =   {      1,         5,           10,           15,        20};
final String [] types =    {"flood",   "flood",   "rgb_spot",   "rgb_spot",   "flood"};


void setup(){
  size(1000, 500);
  eba = new EquipmentButton[x_positions.length];
  
  for (int i = 0; i < eba.length; i++){
    eba[i] = new EquipmentButton(x_positions[i], y_positions[i], addresses[i]);
    eba[i].setType(types[i]);
    if (eba[i].type == TYPE_RGB_SPOT) {
      eba[i].addChannel("red", addresses[i]);
      eba[i].addChannel("green", addresses[i]+1);
      eba[i].addChannel("blue", addresses[i]+2);
    }
    else if (eba[i].type == TYPE_FLOOD){
      eba[i].addChannel("warm", addresses[i]);
      eba[i].addChannel("cold", addresses[i]+1);
    }
  }
  
  section_enabled_rgb_spot = new SliderSection(200, 100);
  section_enabled_rgb_spot.addSlider("red");
  section_enabled_rgb_spot.addSlider("green");
  section_enabled_rgb_spot.addSlider("blue");
  
  section_enabled_flood = new SliderSection(200, 100);
  section_enabled_flood.addSlider("warm");
  section_enabled_flood.addSlider("cold");
  
  section_combined_rgb_spots = new SliderSection(600, 20);
  section_combined_rgb_spots.addSlider("red");
  section_combined_rgb_spots.addSlider("green");
  section_combined_rgb_spots.addSlider("blue");
  
  section_combined_floods = new SliderSection(600, 200);
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
      DMX_connection = new Serial(this, Serial.list()[i], 9600);
    }
  }
  
  
}

void draw(){
  background(0);
  
  for (int i = 0; i < eba.length; i++){
    eba[i].show(); // show buttons 
  }
  
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
}

void mouseDragged(){
  
  //buttonManager(mouseX, mouseY, mouseButton);
  updateEnabledGUI();
  updateCombinedGUI();
  //println(countCombined(TYPE_FLOOD), countCombined(TYPE_RGB_SPOT));
}

void buttonManager(int mouse_x, int mouse_y, int mouse_button){
  
  
  for (int i = 0; i < eba.length; i++){ // traverse all the buttons
    
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
}
