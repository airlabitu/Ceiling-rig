class SliderSection{
  
  int x, y;
  ArrayList <Slider> sliders;
  
  SliderSection(int x_, int y_){
    x = x_;
    y = y_;
    sliders = new ArrayList<Slider>();
  }
  
  Channel update(){
    for (Slider sl : sliders){
      if (sl.update()) return sl.channel;
    }
    return null;
  }
  
  void addSlider(String label_){
    Slider s = new Slider(x, y+10+sliders.size()*50, label_);
    sliders.add(s);
  }
  
  void show(){
    for (Slider sl : sliders){
      sl.show();
    }
  }
  
  void connectButton(EquipmentButton eb){
    for (Slider s : sliders){
      s.channel = eb.getChannel(s.label);  
    }
  }
  
  void disconnectButton(){
    for (Slider s : sliders){
      s.channel = null;  
    }
  }
  
  
  Channel getChannel(String ch_name){
    for (int i = 0; i < sliders.size(); i++){
      if (sliders.get(i).channel.name.equals(ch_name)) return sliders.get(i).channel;
    }
    return null;
  }
  
}
