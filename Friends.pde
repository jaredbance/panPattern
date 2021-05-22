import java.util.*;

////////////////////////////////////////////////////
////////////////////////////////////////////////////
static int scale = 4;
static int widthActual = 200;
static float strokeWeight = 2;
static boolean drawPath = false;
static boolean slowMode = false;
static int slowModeFrameRate = 5;
static int dotProbabilty = 100;
static int clumpThreshold = 3;
static int maxAttractionDistance = widthActual/6;
public boolean wait = true;
// static boolean clumpMode = false; DEPRICATED
////////////////////////////////////////////////////
////////////////////////////////////////////////////

public int widthScaled = scale * widthActual;
public ArrayList<Friend> friends = new ArrayList();
public HashSet<Integer> usedIDs= new HashSet();
public HashSet<Friend>[][] mapMemory = new HashSet[widthActual][widthActual];

public class Friend{
  Integer id;
  int x;
  int y;
  /* DEPRICATED
  boolean clumped = false;
  */
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

void settings(){
  size(widthScaled, widthScaled);
}

void setup() {
  scale(scale);
  if (slowMode) frameRate(slowModeFrameRate);
  background(#ffffff);
  strokeWeight(strokeWeight);
  
  for(int i = 0; i < widthActual; i++){
    for(int j = 0; j < widthActual; j++){
      mapMemory[i][j] = new HashSet<Friend>();
      if (int(random(dotProbabilty)) == 0){
        Friend friend = new Friend(i,j);
        friends.add(friend);
        mapMemory[i][j].add(friend);
      }
    }
  }
  drawFriends();
  //test();
  //testExponentialIncrease();
}
  
void draw() {
  if (wait){
    delay(1000);
    wait = false;
  }
  
  scale(scale);
  if (!drawPath) background(#ffffff);
  friends = getNewPositions(friends);
  drawFriends();
  
  //saveFrame("frames/####.tif");
}

public void drawFriends() {
  for(int i = 0; i < friends.size(); i++){
      Friend friend = friends.get(i);
      //square(friend.x, friend.y, 1);
      point(friend.x, friend.y);
  }
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
    /* DEPRICATED
    if (clumpMode == true && friend.clumped == true) {
      continue;
    }
    */
    ArrayList<Float> angles = new ArrayList();
    ArrayList<Float> weights = new ArrayList();
    /* DEPRICATED
    int friendsInSameSpaceCounter = 0;
    */
    for(int j = 0; j < friends.size(); j++){
      if (friend == friends.get(j)) continue; 
      /* DEPRICATED
      if (clumpMode == true && friendsInSameSpaceCounter >= clumpThreshold) { // if too many friends occupying a single space, clump them and stop moving
        friend.clumped = true;
        break;
      }
      */
      Friend otherFriend = friends.get(j);
      float distance = sqrt(pow(otherFriend.x - friend.x, 2) + pow(otherFriend.y - friend.y, 2));
      if (distance == 0f){
        /* DEPRICATED
        friendsInSameSpaceCounter++;
        */
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
    int oldX = friend.x;
    int oldY = friend.y; 
    
    // do nothing if no friends nearby
    if (angles.size() == 0) {
      // do nothing 
    }
    // right 
    else if (mean <= 22.5f) { 
      if (mapMemory[friend.x+1][friend.y].size() >= clumpThreshold) continue;
      friend.x++;
    } 
    // up-right 
    else if (mean <= 67.5f) {
      if (mapMemory[friend.x+1][friend.y-1].size() >= clumpThreshold) continue;
      friend.x++;
      friend.y--;
    }
    // up
    else if (mean <= 112.5f) {
      if (mapMemory[friend.x][friend.y-1].size() >= clumpThreshold) continue;
      friend.y--;
    }
    // up-left
    else if (mean <= 157.5) {
      if (mapMemory[friend.x-1][friend.y-1].size() >= clumpThreshold) continue;
      friend.x--;
      friend.y--;
    }
    // left
    else if (mean <= 202.5) {
      if (mapMemory[friend.x-1][friend.y].size() >= clumpThreshold) continue;
      friend.x--;
    }
    // down-left
    else if (mean <= 247.5) {
      if (mapMemory[friend.x-1][friend.y+1].size() >= clumpThreshold) continue;
      friend.x--;
      friend.y++;
    }
    // down
    else if (mean <= 292.5) {
      if (mapMemory[friend.x][friend.y+1].size() >= clumpThreshold) continue;
      friend.y++; //<>//
    } 
    // down-right
    else if (mean <= 337.5) {
      if (mapMemory[friend.x+1][friend.y+1].size() >= clumpThreshold) continue;
      friend.x++;
      friend.y++;
    }
    // right (again)
    else if (mean <= 360) {
      if (mapMemory[friend.x+1][friend.y].size() >= clumpThreshold) continue;
      friend.x++;
    }
    mapMemory[oldX][oldY].remove(friend);
    mapMemory[friend.x][friend.y].add(friend);
  }
  return friends;
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
