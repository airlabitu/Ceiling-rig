class EquipmentButton{
  int type = 0; // type 0=rgb spot , type 1=flood
  int x, y;
  int w, h, d;
  color main_col, second_col;
  boolean enabled_state;
  String ID;
  ArrayList <Channel> channels = new ArrayList<Channel>();
  PFont font;
  
  EquipmentButton(int x_, int y_, String ID_){
    x = x_;
    y = y_;
    setSize(40, 40);
    setSize(40);
    main_col = color(255,105,204);
    second_col = color(255, 255, 0);
    ID = ID_;
    font = loadFont("ArialMT-10.vlw");
  }
  
  int update(int xPos, int yPos, int mouse_button){
    if (isOver(xPos, yPos)) {    
      if (mouse_button == LEFT) {
        enabled_state = ! enabled_state;
        return 0; // a change was made
      }
    }
    return -1; // no changes made
  }
  
  void show(){
    strokeWeight(1);
    stroke(main_col);
    if (enabled_state) fill(main_col);
    else fill(0);
    if (type == 1) {  
      rectMode(CENTER);
      rect(x, y, w, h); 
    }
    else if (type == 0){  
      ellipse(x, y, d, d);
    }
    
    
    if (enabled_state) fill(0);
    else fill(main_col);
    //textSize(10);
    textAlign(CENTER, CENTER);
    textFont(font);
    text(ID, x, y);
  }
  
  boolean isOver(int xPos, int yPos){
    if (type == 1 && xPos > x-w/2 && xPos < x-w/2+w && yPos > y-h/2 && yPos < y-h/2+h) return true; // square
    else if (type == 0 && dist(xPos, yPos, x, y) < d/2) return true; // circle
    else return false;
  }
  
  void setType(String type_){
    if (type_.equals("flood")) type = 1;
    else if (type_.equals("rgb_spot")) type = 0;
    else if (type_.equals("dimm")) type = 1;
  }
  
  void addChannel(String ch_name, int address_){
    channels.add(new Channel(ch_name, address_));
  }
  
  Channel getChannel(String ch_name){
    for (int i = 0; i < channels.size(); i++){
      if (channels.get(i).name.equals(ch_name)) return channels.get(i);
    }
    return null;
  }
  
  void updateChannel(String ch_name, int val){
    println(ch_name, val, "type:", type);
    getChannel(ch_name).value = val;
  }
  
  void setSize(int w_, int h_){
    w = w_;
    h = h_;
  }
  
  void setSize(int d_){
    d = d_;
    
  }
  
  void setFont(PFont font_){
    font = font_;
  }
}
