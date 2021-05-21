import java.util.*;

public int scale = 4;
public int widthActual = 100;
public int widthScaled = scale * widthActual;
public Boolean[][] friends;

void settings(){
  size(widthScaled, widthScaled);
}

void setup() {
  
  scale(scale);
  //frameRate(60);
  background(#ffffff);
  //strokeWeight(0.6);
  
  friends = new Boolean[widthActual][widthActual];
  for(int i = 0; i < widthActual; i++){
    for(int j = 0; j < widthActual; j++){
      //System.out.print(int(random(2)));
      if (int(random(40)) == 0){
        friends[i][j] = true;
      } else{
        friends[i][j] = false;
      }
    }
  }
  drawFriends();
  
  test();
}

void draw() {
  background(#ffffff);
}

public void drawFriends() {
   for(int i = 0; i < friends.length; i++){
    for(int j = 0; j < friends[0].length; j++){
      if (friends[i][j] == true) {
        point(i,j);
      }
    }
  }
}

public float circular_mean(ArrayList<Float> angles, ArrayList<Float> weights ){
    float x = 0, y = 0;
    
    for (int angle = 0, weight = 0; angle < angles.size(); angle++, weight++){
        x += cos(radians(angles.get(angle))) * weights.get(weight);
        y += sin(radians(angles.get(angle))) * weights.get(weight);
    }
    
    float mean = degrees(atan2(y,x));
    
    
    /*
    for angle, weight in zip(angles, weights):
        x += math.cos(math.radians(angle)) * weight
        y += math.sin(math.radians(angle)) * weight

    mean = math.degrees(math.atan2(y, x))
    */
    return mean;
}

public void test(){
  ArrayList<Float> angles = new ArrayList();
  ArrayList<Float> weights = new ArrayList();
  angles.add(new Float(45));
  angles.add(new Float(315));
  weights.add(new Float(1));
  weights.add(new Float(1));
  
 
  System.out.printf("%.50f", circular_mean(angles,weights));
}
