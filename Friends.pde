import java.util.*;
import javafx.util.*;
import java.lang.reflect.*;

// change conditions for clump
// add more directions

////////////////////////////////////////////////////
////////////////////////////////////////////////////
static int scale = 6;
static int widthActual = 100;
static float strokeWeight = 1;
static boolean drawPath = false;
static boolean slowMode = false;
static int slowModeFrameRate = 5;
static int dotProbabilty = 10;
static int clumpThreshold = 1;
static int maxAttractionDistance = widthActual/8; //6
public boolean wait = true;
public boolean specialPointMode = true;
static boolean clumpMode = true; 
static int numberOfAllowedClumpParticles = 900; //800
////////////////////////////////////////////////////
////////////////////////////////////////////////////

public int widthScaled = scale * widthActual;
public ArrayList<Friend> friends = new ArrayList();
public HashSet<Integer> usedIDs= new HashSet();
public static HashSet<Friend>[][] mapMemory = new HashSet[widthActual+500][widthActual+500];
HashMap<String, Method> directionMethods = new HashMap();
public ArrayList<Pair<Float, Float>> specialPoints = new ArrayList();
public int clumpCounter = 0;

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

public static class Directions{
  public static boolean right(Friend friend){
    if (mapMemory[friend.x+1][friend.y].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x++;
      return true;
    }
  }
  public static boolean upRight(Friend friend){
    if (mapMemory[friend.x+1][friend.y-1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x++;
      friend.y--;
      return true;
    }
  }
  public static boolean up(Friend friend) {
    if (mapMemory[friend.x][friend.y-1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.y--;
      return true;
    }
  }
  public static boolean upLeft(Friend friend){
    if (mapMemory[friend.x-1][friend.y-1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x--;
      friend.y--;
      return true;
    }
  }
  public static boolean left(Friend friend){
    if (mapMemory[friend.x-1][friend.y].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x--;
      return true;
    }
  }
  public static boolean downLeft(Friend friend){
    if (mapMemory[friend.x-1][friend.y+1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x--;
      friend.y++;
      return true;
    }
  }
  public static boolean down(Friend friend){
    if ( mapMemory[friend.x][friend.y+1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.y++;
      return true;
    }
  }
  public static boolean downRight(Friend friend){
    if (mapMemory[friend.x+1][friend.y+1].size() >= clumpThreshold){
      return false;
    }
    else {
      friend.x++;
      friend.y++;
      return true;
    }
  }
}

void settings(){
  size(widthScaled, widthScaled);
}

void setup(){
  scale(scale);
  if (slowMode) frameRate(slowModeFrameRate);
  background(#ffffff);
  strokeWeight(strokeWeight);
  for(int i = 0; i < widthActual+500; i++){
    for(int j = 0; j < widthActual+500; j++){
      mapMemory[i][j] = new HashSet<Friend>();
    }
  }
  for(int i = 0; i < widthActual; i++){
    for(int j = 0; j < widthActual; j++){
      if ((i == 100 && j == 100) || int(random(dotProbabilty)) == 0){
        Friend friend = new Friend(i,j);
        friends.add(friend);
        mapMemory[i][j].add(friend);
        if (specialPointMode && i == 100 && j == 100){
          friend.special = true;
        }
      }
    }
  }
  for (Method m : Directions.class.getDeclaredMethods()){
    directionMethods.put(m.getName(),m);
  }
  drawFriends();
  //test();
  //testExponentialIncrease();
}
  
void draw() {
  if (wait){
    try{Thread.sleep(500);}catch(Exception e){}
    wait = false;
  }
  if (clumpCounter >= numberOfAllowedClumpParticles){
    maxAttractionDistance = widthActual / 3;
    drawPath = true;
  }
  scale(scale);
  if (!drawPath) background(#ffffff);
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
    int friendsInSameSpaceCounter = 0;
    for(int j = 0; j < friends.size(); j++){
      if (friend == friends.get(j)) continue; 
      if (clumpMode == true && friendsInSameSpaceCounter >= clumpThreshold) { // if too many friends occupying a single space, clump them and stop moving
        //friend.clumped = true;
        //break;
      }
      Friend otherFriend = friends.get(j);
      float distance = sqrt(pow(otherFriend.x - friend.x, 2) + pow(otherFriend.y - friend.y, 2));
      if (distance == 0f){
        friendsInSameSpaceCounter++;
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
   ArrayList<String> directions = new ArrayList(Arrays.asList("right", "upRight", "up", "upLeft", "left", "downLeft"
    , "down", "downRight"));
   int oldX = friend.x;
   int oldY = friend.y;
   boolean hasBeenBlockedOnce = false;
   while (true){
     float angleBetweenDirections = 360f / float(directions.size());
     int quadrant = ceil((meanAngle/(angleBetweenDirections) - 0.5)); 
     String direction;
     if (quadrant < 0 || quadrant == directions.size()) {
       direction = directions.get(0);
     } else {
       direction = directions.get(quadrant);
     }
     Method m = directionMethods.get(direction);
     Boolean result = null;
     try{
       //result = (Boolean) m.invoke(Directions.class.newInstance(), friend);
       result = (Boolean) m.invoke(null, friend);
     }
     catch(InvocationTargetException e){
       e.printStackTrace();
     }
     catch(Exception e){
       System.out.print(e);
     }
     
     try{
       if (result.equals(true)){
         break;
       } else {
         if (!hasBeenBlockedOnce){
           hasBeenBlockedOnce = true;
           int[] backwardDirectionsToRemove = {quadrant+3,quadrant+4,quadrant+5};
           ArrayList<String> directionsToRemove = new ArrayList(); 
           for (int i = 0; i < backwardDirectionsToRemove.length; i++){
             if (backwardDirectionsToRemove[i] > 7) {
               backwardDirectionsToRemove[i] = backwardDirectionsToRemove[i] - 7;
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
     } catch (Exception e){ }
   }
   mapMemory[oldX][oldY].remove(friend);
   mapMemory[friend.x][friend.y].add(friend);
}

void keyPressed(){
    if(key=='s'||key=='S')
            saveFrame(); 
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
