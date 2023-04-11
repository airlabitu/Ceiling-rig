class EquipmentButton{
  int type = 0; // type 0=rgb spot , type 1=flood
  int x, y;
  int size;
  color main_col, second_col;
  boolean enabled_state;
  boolean combine_state;
  String ID;
  ArrayList <Channel> channels = new ArrayList<Channel>();
  
  EquipmentButton(int x_, int y_, String ID_){
    x = x_;
    y = y_;
    size = 40;
    main_col = color(255,105,204);
    second_col = color(255, 255, 0);
    ID = ID_;
  }
  
  int update(int xPos, int yPos, int mouse_button){
    if (isOver(xPos, yPos)) {    
      if (mouse_button == LEFT) {
        enabled_state = ! enabled_state;
        return 0; // a change was made
      }
      else if (mouse_button == RIGHT) {
        combine_state = ! combine_state;
        return 1; // a change was made
      }
    }
    return -1; // no changes made
  }
  
  void show(){
    
    if (enabled_state) fill(main_col);
    else fill(0);//noFill();
    
    if (combine_state) stroke(second_col);
    else stroke(main_col);
      
    if (type == 1) {  
      rectMode(CENTER);
      rect(x, y, size, size); 
    }
    else if (type == 0){  
      ellipse(x, y, size, size);
    }
    
    
    if (enabled_state) fill(0);
    else fill(main_col);
    textSize(10);
    textAlign(CENTER, CENTER);
    textFont(font_small);
    text(ID, x, y);
  
  }
  
  boolean isOver(int xPos, int yPos){
    if (type == 1 && xPos > x-size/2 && xPos < x-size/2+size && yPos > y-size/2 && yPos < y-size/2+size) return true; // square
    else if (type == 0 && dist(xPos, yPos, x, y) < size/2) return true; // circle
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
}
