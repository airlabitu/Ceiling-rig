class Slider{

  int x, y;
  int w = 255;
  int h = 20;
  int min, max;
  int val, last_val;
  
  String label;
  
  color col = color(255,105,204);//color(238,246,89);
  //color foreground = color(238,246,89);
  //color background = color(255,105,204);
  
  Slider(int x_, int y_, String label_){
    x = x_;
    y = y_;
    max = 255;
    label = label_;
  }
  
  
  boolean update(){
    
    if (mouseX >= x && mouseX <= x+w && mouseY > y && mouseY < y + h){ 
      val = int(map (mouseX, x, x + w, min, max));
        if (val != last_val) {
          last_val = val;
          return true;
      }
    }
    return false;
  }
  
  boolean setValue(int val_){
    int old_val = val;
    val = val_;
    if (old_val == val) return false;
    return true;
  }
  
  
  void show(){
    noFill();
    strokeWeight(1);
    stroke(col);
    rect(x, y, w, h);
    fill(col);
    rect(x, y, map(val, min, max, 0, w), h);
    text(label, x, y-5);
  
  }
  
}
