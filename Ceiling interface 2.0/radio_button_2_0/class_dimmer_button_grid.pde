class DimmerButtonGrid {
  EquipmentButton [] dba; // array of dimmer buttons
  
  int s = 66; // space
  int x = 804+56/2;//924;//r804+255-(s*3+15); // global x
  int y = 85; // global y
  
  

  
  DimmerButtonGrid (){
    dba = new EquipmentButton[16];
    
    // colum 1
    setupDimmButton(0, x, y, 432, "O1\n(Floods)");
    setupDimmButton(1, x+s, y, 433, "O2");
    setupDimmButton(2, x+s*2, y, 434, "O3");
    setupDimmButton(3, x+s*3, y, 435, "O4");
    // colum 2
    setupDimmButton(4, x, y+s, 436, "O5");
    setupDimmButton(5, x+s, y+s, 437, "O6");
    setupDimmButton(6, x+s*2, y+s, 438, "O7");
    setupDimmButton(7, x+s*3, y+s, 439, "O8");
    // colum 3
    setupDimmButton(8, x, y+s*2, 440, "O9\n(Kinect)");
    setupDimmButton(9, x+s, y+s*2, 441, "O10");
    setupDimmButton(10, x+s*2, y+s*2, 442, "O11");
    setupDimmButton(11, x+s*3, y+s*2, 443, "O12");
    // colum 3
    setupDimmButton(12, x, y+s*3, 444, "O13\n(Floods)");
    setupDimmButton(13, x+s, y+s*3, 445, "O14");
    setupDimmButton(14, x+s*2, y+s*3, 446, "O15");
    setupDimmButton(15, x+s*3, y+s*3, 447, "O16");
    
  }
  
  
  void update(int xPos, int yPos){
    
    for (int i = 0; i < dba.length; i++){
      if (dba[i].update(xPos, yPos, LEFT) == 0){ // a change was made
        sendDMX(dba[i].getChannel("dimm").address, 255*int(dba[i].enabled_state));
      }
    }
  }
  
  
  void show(){
    for (int i = 0; i < dba.length; i++){
      dba[i].show();
    }
  }
  
  void setupDimmButton(int index, int x, int y, int addr, String id){
    dba[index] = new EquipmentButton(x, y, id);
    dba[index].setType("dimm");
    dba[index].addChannel("dimm", addr);
    dba[index].size = 56;
  }
}
