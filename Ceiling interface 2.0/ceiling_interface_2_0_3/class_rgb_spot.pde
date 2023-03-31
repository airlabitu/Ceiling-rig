class RGB_spot{
  String name = "RGB";
  String id;
  int address;
  boolean gui_enabled;
  boolean disable_close_gui;
  int x, y;
  int diam;
  
  int box_x;
  int box_y;
  int box_w;
  int box_h;
  
  Slider slider_red;
  Slider slider_green;
  Slider slider_blue;
  
  Button close_button;
  
  boolean combine_check;

  color combine_col = color(255, 255, 0);
  color standard_col = color(255,105,204);
  
  boolean DMX_enabled = true;
  
  
  
  RGB_spot(int x_, int y_, int box_x_, int box_y_){
    x = x_;
    y = y_;
    
    diam = 50;
  
    box_x = box_x_;//x-diam/2;
    box_y = box_y_;//y-diam/2;
    box_w = 275;
    box_h = 165;
    
    slider_red = new Slider(box_x+10, box_y+50, "red");
    slider_green = new Slider(box_x+10, box_y+90, "green");
    slider_blue = new Slider(box_x+10, box_y+130, "blue");
    
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
      slider_red.show();
      slider_green.show();
      slider_blue.show();
      //text(name + " (" + id + ")", box_x + 10, box_y+20);
      text(name + " (" + id + ")", box_x + 10, box_y+20);
    }
    
    // draw the lamp icon
    strokeWeight(2);
    if (combine_check) stroke(combine_col);
    else stroke(standard_col);
    
    // solid black background
    fill(0);
    ellipse(x, y, diam, diam); 
    
    // if the gui is enabled fill with semi-transparrent standard color
    if (gui_enabled) fill(standard_col);
    ellipse(x, y, diam, diam);
    
    // draw text
    if (gui_enabled) fill(0);
    else fill(standard_col);
    textAlign(CENTER);
    text(id, x, y+5);
    
    
  }
  
  int update_gui(){
    
    if (mouseButton == RIGHT && dist(mouseX, mouseY, x, y) < diam/2) {
      combine_check = !combine_check;
      return 0;
    }
    
    else if (mouseButton == LEFT){
      if (!gui_enabled){ // check for gui being closed
        if (dist(mouseX, mouseY, x, y) < diam/2) { // open the gui
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
        if (slider_red.update() || slider_green.update() || slider_blue.update()) {
          return 3; // red, green or blue updated
        }
      }
    }
    return 5; // none actions taken
  
  }
  
  boolean setRed(int val){
    return slider_red.setValue(val);
  }
  
  boolean setGreen(int val){
    return slider_green.setValue(val);
  }
  
  boolean setBlue(int val){
    return slider_blue.setValue(val);
  }
  
  int getRed(){
    return slider_red.val;
  }
  int getGreen(){
    return slider_green.val;
  }
  int getBlue(){
    return slider_blue.val;
  }
}
