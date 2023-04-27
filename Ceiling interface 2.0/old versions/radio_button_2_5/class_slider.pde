class Slider{

  int x, y;
  int w = 255;
  int h = 20;
  int min, max;
  //int val, 
  int last_val;
  Channel channel;
  
  String label;
  
  color col = color(255,105,204);

  
  Slider(int x_, int y_, String label_){
    x = x_;
    y = y_;
    max = 255;
    label = label_;
    channel = new Channel (label_, 999);
  }
  
  boolean update(){
    
    if (mouseX >= x && mouseX <= x+w && mouseY > y && mouseY < y + h){ 
      channel.value = int(map (mouseX, x, x + w, min, max));
        if (channel.value != last_val) {
          last_val = channel.value;
          return true;
      }
    }
    return false;
  }
  
  boolean setValue(int val_){
    int old_val = channel.value;
    channel.value = val_;
    if (old_val == channel.value) return false;
    return true;
  }
  
    void show(){
    rectMode(CORNER);
    textAlign(LEFT, BASELINE);
    noFill();
    strokeWeight(1);
    stroke(col);
    rect(x, y, w, h);
    fill(col);
    rect(x, y, map(channel.value, min, max, 0, w), h);
    text(label, x, y-5);
  
  }
  
}
