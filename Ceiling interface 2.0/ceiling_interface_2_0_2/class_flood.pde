class Flood{
  String name = "Flood";
  String id;
  int address;
  boolean gui_enabled;
  boolean disable_close_gui;
  int x, y;
  int size;
  
  int box_x;
  int box_y;
  int box_w;
  int box_h;
  
  Slider slider_warm;
  Slider slider_cold;
  
  Button close_button;
  
  boolean combine_check;

  color combine_col = color(255, 255, 0);
  color standard_col = color(255,105,204);
  
  boolean DMX_enabled = true;
  
  
  
  Flood(int x_, int y_, int box_x_, int box_y_){
    
    
    size = 50;
    
    x = x_ - size/2;
    y = y_ - size/2;
  
    box_x = box_x_;//x-diam/2;
    box_y = box_y_;//y-diam/2;
    box_w = 275;
    box_h = 125;
    
    slider_warm = new Slider(box_x+10, box_y+50, "warm");
    slider_cold = new Slider(box_x+10, box_y+90, "cold");
    
    close_button = new Button(box_x + box_w-20, box_y, 20, 20, "close");
    close_button.address = -1; // means non DMX button
    
  }
  
  void show_gui(){
    if (gui_enabled){ // draw the open gui
      strokeWeight(2);
      stroke(standard_col);
      
      //fill(gui_background);
      fill(0);
      rect(box_x, box_y, box_w, box_h);
      
      if (!disable_close_gui)  close_button.show(); // draw close button
        
      textAlign(LEFT);
      slider_warm.show();
      slider_cold.show();      
      text(name + " (" + id + ")", box_x + 10, box_y+20);
    }
    
    // draw the lamp icon
    strokeWeight(2);
    if (combine_check) stroke(combine_col);
    else stroke(standard_col);
    
    // solid black background
    fill(0);
    rect(x, y, size, size); 
    
    // if the gui is enabled fill with semi-transparrent standard color
    if (gui_enabled) fill(standard_col);
    rect(x, y, size, size);
    
    // draw text
    if (gui_enabled) fill(0);
    else fill(standard_col);
    textAlign(CENTER);
    //text(name + "\n(" + id + ")", x, y+5, size, size);
    text(id, x, y+18, size, size);
    
    
  }
  
  int update_gui(){
    
    //if (mouseButton == RIGHT && dist(mouseX, mouseY, x, y) < size/2) {
    if (mouseButton == RIGHT && mouseX > x && mouseX < x+size && mouseY > y && mouseY < y+size) {
      combine_check = !combine_check;
      return 0;
    }
    
    else if (mouseButton == LEFT){
      if (!gui_enabled){ // check for gui being closed
        //if (dist(mouseX, mouseY, x, y) < size/2) { // open the gui
        if (mouseX > x && mouseX < x+size && mouseY > y && mouseY < y+size) { // open the gui
          gui_enabled = true;
          return 1; // open gui
        }
      }
      else { // gui already open
        if (!disable_close_gui && close_button.detectPress()) { // detect close gui action
          gui_enabled = false;
          return 2; // close gui
        }
        
        // interact with sliders
        if (slider_warm.update() || slider_cold.update()) {
          return 3; // warm or cold updated
        }
      }
    }
    return 5; // none actions taken
  
  }
  
  boolean setWarm(int val){
    return slider_warm.setValue(val); //) println(name, id, "warm", slider_warm.val);
  }
  
  boolean setCold(int val){
    return slider_cold.setValue(val); //) println(name, id, "cold", slider_cold.val);
  }
  int getWarm(){
    return slider_warm.val;
  }
  int getCold(){
    return slider_cold.val;
  }
  
}
