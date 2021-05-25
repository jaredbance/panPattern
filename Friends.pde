import java.util.*;
import javafx.util.*;

// create links between clumps

////////////////////////////////////////////////////
////////////////////////////////////////////////////
static int scale = 6;
static int widthActual = 100;
static float strokeWeight = 1;
static boolean drawPath_s = false;
static boolean slowMode = false;
static int slowModeFrameRate = 5;
static int dotProbabilty = 10;
static int clumpThreshold = 1;
static int maxAttractionDistance_s = widthActual/8; //6
public boolean wait_s = true;
public int waitTime = 500;
public boolean specialPointMode = false;
public int specialPointPosition = 50;
static boolean clumpMode = true; 
static int numberOfAllowedClumpParticles = 850; //800
static int colorMode = 1;
////////////////////////////////////////////////////
////////////////////////////////////////////////////

public int widthScaled = scale * widthActual;
public ArrayList<Friend> friends; // = new ArrayList();
public HashSet<Integer> usedIDs; //= new HashSet();
public static HashSet<Friend>[][] mapMemory; // = new HashSet[widthActual+500][widthActual+500];
public ArrayList<Pair<Float, Float>> specialPoints; // = new ArrayList();
public int clumpCounter; // = 0;
ArrayList<Pair<String,Pair<Integer,Integer>>> globalDirections = new ArrayList(Arrays.asList(
     new Pair("right", new Pair(1,0)), 
     new Pair("upRight", new Pair(1,-1)), 
     new Pair("up", new Pair(0,-1)), 
     new Pair("upLeft", new Pair(-1,-1)), 
     new Pair("left", new Pair(-1,0)), 
     new Pair("downLeft", new Pair(-1, 1)), 
     new Pair("down", new Pair(0, 1)), 
     new Pair("downRight", new Pair(1, 1))
   ));
public boolean drawPath;
public int maxAttractionDistance;
public boolean wait;
public boolean firstRun = true;
public Integer waitCount;
public colorMode[] colorModes = {
  new colorMode(color(40,40,40), color(240,240,240)),
  new colorMode(color(255), color(0))
};

public class Friend{
  boolean special = false;
  Integer id;
  int x;
  int y;
  boolean clumped = false;
  public Friend(int x, int y){
    id = int(random(1000000));
    while(usedIDs.contains(id)){
      id = int(random(1000000));
    }
    usedIDs.add(id);  
    this.x = x;
    this.y = y;
  }
}

public class colorMode{
  color bgColor;
  color strokeColor;
  public colorMode(color bgColor, color strokeColor){
    this.bgColor = bgColor;
    this.strokeColor = strokeColor;
  }
}

void settings(){
  size(widthScaled, widthScaled);
}

void setup(){
  stroke(colorModes[colorMode].strokeColor);
  friends = new ArrayList();
  usedIDs= new HashSet();
  mapMemory= new HashSet[widthActual+500][widthActual+500];
  specialPoints = new ArrayList();
  clumpCounter = 0;
  maxAttractionDistance = maxAttractionDistance_s;
  drawPath = drawPath_s;
  wait = wait_s;
  waitCount = 0;
  if (firstRun){
    scale(scale);
    firstRun = false;
  }
  if (slowMode) frameRate(slowModeFrameRate);
  background(colorModes[colorMode].bgColor);
  strokeWeight(strokeWeight);
  for(int i = 0; i < widthActual+500; i++){
    for(int j = 0; j < widthActual+500; j++){
      mapMemory[i][j] = new HashSet<Friend>();
    }
  }
  for(int i = 0; i < widthActual; i++){
    for(int j = 0; j < widthActual; j++){
      if ((i == specialPointPosition && j == specialPointPosition) || int(random(dotProbabilty)) == 0){
        Friend friend = new Friend(i,j);
        friends.add(friend);
        mapMemory[i][j].add(friend);
        if (specialPointMode && i == specialPointPosition && j == specialPointPosition){
          friend.special = true;
        }
      }
    }
  }
  drawFriends();
  //test();
  //testExponentialIncrease();
}
  
void draw() {
  if (wait){
    try{Thread.sleep(waitTime);}catch(Exception e){}
    wait = false;
  }
  
  if (waitCount < 40) {
    waitCount++;
    //saveFrame("frames/####.tif");
    return;
  }
  
  if (clumpCounter >= numberOfAllowedClumpParticles){
    maxAttractionDistance = widthActual / 3;
    drawPath = true;
  }
  scale(scale);
  stroke(colorModes[colorMode].strokeColor);
  if (!drawPath) background(colorModes[colorMode].bgColor);;
  Collections.shuffle(friends);
  friends = getNewPositions(friends);
  drawFriends();
  //saveFrame("frames/####.tif");
}

public void drawFriends() {
  for(int i = 0; i < friends.size(); i++){
      Friend friend = friends.get(i);
      //square(friend.x, friend.y, 1);
      point(friend.x, friend.y);
      if (friend.special){
        specialPoints.add(new Pair<Float, Float>(float(friend.x), float(friend.y)));
      }
  }
  stroke(0,128,0);
  strokeWeight(1);
  for(Pair pair : specialPoints){
    point((Float) pair.getKey(), (Float) pair.getValue());
  }
  strokeWeight(strokeWeight);
  stroke(0,0,0);
}

public float circular_mean(ArrayList<Float> angles, ArrayList<Float> weights){
    float x = 0, y = 0;
    for (int i = 0; i < angles.size(); i++){
        x += cos(angles.get(i)) * weights.get(i);
        y += sin(angles.get(i)) * weights.get(i);
    } 
    float mean = degrees(atan2(y,x));
    if (mean < 0) {
      mean = mean + float(360);
    }
    return mean;
}

public ArrayList<Friend> getNewPositions(ArrayList<Friend> friends){
  for(int i = 0; i < friends.size(); i++){
    Friend friend = friends.get(i);
    if (clumpMode == true && friend.clumped == true) {
      continue;
    }
    ArrayList<Float> angles = new ArrayList();
    ArrayList<Float> weights = new ArrayList();
    //int friendsInSameSpaceCounter = 0;
    for(int j = 0; j < friends.size(); j++){
      if (friend == friends.get(j)) continue; 
      Friend otherFriend = friends.get(j);
      float distance = sqrt(pow(otherFriend.x - friend.x, 2) + pow(otherFriend.y - friend.y, 2));
      if (distance == 0f){
        //friendsInSameSpaceCounter++;
        continue;
      } else if (distance > maxAttractionDistance){
        continue;
      }
      float angle = atan2(friend.y - otherFriend.y, otherFriend.x - friend.x);
      angles.add(angle);
      weights.add((widthActual*2)-distance);
      //weights.add(pow(2,(1/distance)));
    }
    float mean = circular_mean(angles, weights);
    // do nothing if no friends nearby
    if (angles.size() == 0) {
      // do nothing 
    }
    moveFriend(mean, friend);
  }
  return friends;
}

public void moveFriend(float meanAngle, Friend friend) {
   ArrayList<Pair<String,Pair<Integer,Integer>>> directions = (ArrayList<Pair<String,Pair<Integer,Integer>>>) globalDirections.clone();
   int oldX = friend.x;
   int oldY = friend.y;
   boolean hasBeenBlockedOnce = false;
   while (true){
     float angleBetweenDirections = 360f / float(directions.size());
     int quadrant = ceil((meanAngle/(angleBetweenDirections) - 0.5)); 
     Pair<String,Pair<Integer,Integer>> direction;
     if (quadrant < 0 || quadrant == directions.size()) {
       direction = directions.get(0);
     } else {
       direction = directions.get(quadrant);
     }
     
     Boolean result;
     if (mapMemory[friend.x + direction.getValue().getKey()][friend.y + direction.getValue().getValue()].size() >= clumpThreshold){
       result = false;
     }
     else {
       friend.x += direction.getValue().getKey();
       friend.y += direction.getValue().getValue();
       result = true;
     }
   
     if (result.equals(true)){
       break;
     } else {
       if (!hasBeenBlockedOnce){
         hasBeenBlockedOnce = true;
         int[] backwardDirectionsToRemove = {quadrant+3,quadrant+4,quadrant+5};
         ArrayList<Pair<String,Pair<Integer,Integer>>> directionsToRemove = new ArrayList(); 
         for (int i = 0; i < backwardDirectionsToRemove.length; i++){
           if (backwardDirectionsToRemove[i] > 7) {
             backwardDirectionsToRemove[i] = backwardDirectionsToRemove[i] - 8;
           }
           directionsToRemove.add(directions.get(backwardDirectionsToRemove[i]));
         }
         directions.removeAll(directionsToRemove);
       }
       directions.remove(direction);
       if (directions.size() == 0) {
         if (clumpMode == true && clumpCounter <= numberOfAllowedClumpParticles){
           friend.clumped = true;
           clumpCounter++;
         } 
         break;
       }
     }
   }
   mapMemory[oldX][oldY].remove(friend);
   mapMemory[friend.x][friend.y].add(friend);
}

void keyPressed(){
    if(key=='s'||key=='S')
            saveFrame(); 
    if (key==' ') {
      setup();
    }
}

//////////////////////////////
////////TEST FUNCTIONS////////
//////////////////////////////

public void test(){
  ArrayList<Float> angles = new ArrayList();
  ArrayList<Float> weights = new ArrayList();
  angles.add(new Float(45));
  angles.add(new Float(315));
  weights.add(new Float(1));
  weights.add(new Float(1));
  System.out.printf("%.50f", circular_mean(angles,weights));
}

public void angleTest() {
   int x1 = 2;
   int y1 = 2;
   int x2 = 1;
   int y2 = 1;

   float angle = degrees(atan2(y1 - y2, x2 - x1));
   System.out.println(String.valueOf(angle));
}

public void testExponentialIncrease(){
  float distance = 2;
  float x = pow(2,10*(1/distance));
  System.out.printf("%.50f", x);
}
