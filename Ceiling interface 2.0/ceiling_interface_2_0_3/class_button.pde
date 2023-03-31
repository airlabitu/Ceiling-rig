class Button{
  int x, y, w, h;
  color col;
  
  String type = "toggle"; // toggle, close
  boolean toggle_state;
  
  int address;
  
  Button(int x_, int y_, int w_, int h_, String type_){
    col = color(255,105,204);
    type = type_;
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }
  
  boolean detectPress(){
    if (mouseX > x && mouseY > y && mouseX < x+w && mouseY < y+h){
      if (type.equals("toggle")) toggle_state = !toggle_state;
      return true;
    }
    return false;
  }
  
  void show(){
    strokeWeight(1);
    stroke(col);
    if (type.equals("close")){
      fill(0);
      rect(x, y, w, h);
      line(x,y,x+w, y+h);
      line(x+w,y,x, y+h);
    }
    else if (type.equals("toggle")){
      if (toggle_state) fill(col);
      else fill(0);
      rect(x, y, w, h);
    }
  }
}
