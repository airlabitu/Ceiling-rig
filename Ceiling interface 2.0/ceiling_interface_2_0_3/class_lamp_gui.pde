import java.util.Map;


class LampGui{

  HashMap<String,Slider> channels = new HashMap<String,Slider>();
  int x, y;
  int h, w;
  
  LampGui(int x_, int y_){
    x = x_;
    y = y_;
    w = 275;
    h = 125;
  }
  
  void addSlider(String channel_name){
    channels.put(channel_name, new Slider(x+10, y+50+channels.size()*40, channel_name));
  }
  
  void set(String channel, int value){
    channels.get(channel).setValue(value);
  }
  
  
}
