// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmenbruecke
// -----------------------------------------

int cycles = 10000;
int numberWaypoints = 21;
int radiusWaypoint = 10;
int nPhotos = 21;
int count = 0;
int systemSize = 1;

PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB, photo;

int countHitTot;
int mapWidth, mapPartWidth;
int rasterMapBountX, rasterMapBountY, rasterMapBountXY;
float[] waypointsResource = new float[numberWaypoints];
float waypointsResourceTotal;

PVector pathfinder;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector[cycles];

boolean mouseClicked;
boolean[] countHit = new boolean[numberWaypoints];

PFont cour;

Pathfinder newPathfinder;
Waypoints[] waypoint;

void setup() {
  size(1780, 810);
  cour = createFont("cour.ttf", 14);
  smooth();
  frameRate(30);
  background(240);
  mapWidth = height/3*5;
  newPathfinder = new Pathfinder();
  waypoint = new Waypoints[numberWaypoints];
  for (int i = 0; i < path.length; i++) {
    path[i] = new PVector(0, 0);
  }
  mapOrg = loadImage("map_2400x4000_sw.jpg");
  mapOrg.resize(mapWidth, height);
  mapOrg.loadPixels();
  image(mapOrg, 0, 0);
  photos();
  waypointCoordinate();
  waypoints();
}
void draw() {
  raster();
  createMapImage();
  gridMaster();
  createNewMap();
  if (mouseClicked == true) {
    image(mapImageBfull, 0, 0);
    pathfinder();
    for (int i = 0; i < waypoint.length; i++) {
      waypoint[i].display();
      waypoint[i].update();
      printData();
    }
    waypointsResource();
  }
  showImage();
}
void keyPressed () {
  if (key == 's') {
    saveFrame ("capture_####.jpg");
  }
}

void raster() { // determines the number of partial images.
  rasterMapBountX = systemSize*5;
  rasterMapBountY = rasterMapBountX/5*3;
  rasterMapBountXY = rasterMapBountX*rasterMapBountY;
  gridMaster = new PVector[rasterMapBountXY];
  mapPartWidth = mapWidth/rasterMapBountX;
}

void gridMaster() { // generated vectors according "raster()".
  int k = 0;
  for (int j = 0; j < rasterMapBountY; j++) {    
    for (int i = 0; i < rasterMapBountX; i++) {      
      gridMaster[k] = new PVector(i*mapPartWidth, j*mapPartWidth);
      k += 1;
    }
  }
}

void createMapImage() { // converts "mapOrg" into whole pixel image "mapImage..".
  mapImageA = new PImage[rasterMapBountXY];
  mapImageB = new PImage[rasterMapBountXY];
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageA[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageB[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageA[i].loadPixels();
    mapImageB[i].loadPixels();
  }
}

void mapA() { // disassembled PImage "mapOrg" in subpictures "mapImageB[]".
  for (int l = 0; l < rasterMapBountY; l++) {
    for (int k = 0; k < rasterMapBountX; k++) {
      for (int j = 0; j < mapPartWidth; j++) {
        for (int i = 0; i < mapPartWidth; i++) {                                    
          mapImageB[k+l*rasterMapBountX].pixels[i+j*mapPartWidth] = mapOrg.pixels[j*mapWidth+i+mapWidth*l*mapPartWidth+k*mapPartWidth];
        }
      }
    }
  }
  for (int i = 0; i < rasterMapBountXY; i++) {
    image(mapImageB[i], gridMaster[i].x, gridMaster[i].y);
  }
}

void mapB() { // reorders "mapImageB[]".
  int[] randomXY =  new int[rasterMapBountXY];
  for (int i = 0; i < randomXY.length; i++) {
    randomXY[i] = i;
    int temp = randomXY[i]; 
    int j = (int)random(0, randomXY.length);    
    randomXY[i] = randomXY[j];
    randomXY[j] = temp;
  }
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageB[i] = mapImageB[i];
    for (int j = 0; j < rasterMapBountXY; j++) {
      int pos = randomXY[j];
      image(mapImageB[j], gridMaster[pos].x, gridMaster[pos].y);
    }
  }
  mapImageBfull = createImage(mapWidth, height, RGB);
  mapImageBfull.loadPixels();
  mapImageBfull = get();
  image(mapImageBfull, 0, 0);
}

void createNewMap() { // creates a new map according to "map..()".
  if (mousePressed == true) {
    mouseClicked = false;
    boolean t = true;
    while (t == true) {
      if (t == true) {
        mapA();
        mapB();
        t = false;
      }
      mouseClicked = true;
    }
  }
}

void waypointCoordinate() { // generates the coordinates for "waypoints()".
  waypointCoordinate = new PVector[waypoint.length];
  for (int i = 0; i < waypoint.length; i++) {
    waypointCoordinate[i] = new PVector(random(100, mapWidth-100), random(100, height-100));
  }
}

void waypoints() { // generates the "waypoint[]".
  for (int i = 0; i < waypoint.length; i++) {
    waypoint[i] = new Waypoints(waypointCoordinate[i].x, waypointCoordinate[i].y, radiusWaypoint, 1);
  }
}

void waypointsResource() { // calculates the requirements of each "waypoint[]".
  waypointsResourceTotal = -waypoint.length*sq(radiusWaypoint)/2;
  for (int i = 0; i < waypoint.length; i++) {
    waypointsResource[i] = sq((waypoint[i].radius))/2;
    waypointsResourceTotal += waypointsResource[i];
    if (waypoint[i].radius > radiusWaypoint) {
      countHit[i] = true;
    }
  }
  countHitTot = 0;
  for (int i = 0; i < waypoint.length; i++) {
    if (countHit[i] == true) {
      countHitTot += 1;
    }
  }
}

class Waypoints {
  float xpos;
  float ypos;
  float gain;
  PVector pos;
  int radius;

  Waypoints(float tempX, float tempY, int tempRadius, float tempGain) {
    xpos = tempX;
    ypos = tempY;
    gain = tempGain;
    radius = tempRadius;
  }
  void display() {
    noStroke();
    fill(255, 255, 0, 150);
    ellipse(xpos, ypos, radius, radius);
  }
  void update() {
    if (sq(xpos - pathfinder.x) < 100 && sq(ypos - pathfinder.y) < 100) {
      gain += 0.3;
      radius += sqrt(2*gain);
    }
  }
}

void photos() { // loads the photos of the waypoints.
  photo = new PImage[nPhotos];
  photo[0] = loadImage("felderkundung_0.jpg");
  photo[1] = loadImage("felderkundung_1.jpg");
  photo[2] = loadImage("felderkundung_2.jpg");
  photo[3] = loadImage("felderkundung_3.jpg");
  photo[4] = loadImage("felderkundung_4.jpg");
  photo[5] = loadImage("felderkundung_5.jpg");
  photo[6] = loadImage("felderkundung_6.jpg");
  photo[7] = loadImage("felderkundung_7.jpg");
  photo[8] = loadImage("felderkundung_8.jpg");
  photo[9] = loadImage("felderkundung_9.jpg");
  photo[10] = loadImage("felderkundung_10.jpg");
  photo[11] = loadImage("felderkundung_11.jpg");
  photo[12] = loadImage("felderkundung_12.jpg");
  photo[13] = loadImage("felderkundung_13.jpg");
  photo[14] = loadImage("felderkundung_14.jpg");
  photo[15] = loadImage("felderkundung_15.jpg");
  photo[16] = loadImage("felderkundung_16.jpg");
  photo[17] = loadImage("felderkundung_17.jpg");
  photo[18] = loadImage("felderkundung_18.jpg");
  photo[19] = loadImage("felderkundung_19.jpg");
  photo[20] = loadImage("felderkundung_20.jpg");
  for (int i = 0; i < nPhotos; i++) {
    photo[i].resize(height/6*3, height/3);
  }
}

void showImage() { // shows photos according to "pathfinder()".
  float[] deltaPos = new float[nPhotos];
  if (mouseClicked == true) {
    for (int i = 0; i < nPhotos; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, pathfinder.x, pathfinder.y);
    }
  }
  for (int i = 0; i < nPhotos/3; i++) {
    if (deltaPos[i] < 200) {
      image(photo[i], width - photo[i].width, 0);
    }
  }
  for (int i = nPhotos/3; i < nPhotos/3*2; i++) {
    if (deltaPos[i] < 200) {
      image(photo[i], width - photo[i].width, height/3);
    }
  }
  for (int i = nPhotos/3*2; i < nPhotos; i++) {
    if (deltaPos[i] < 200) {
      image(photo[i], width - photo[i].width, height/3*2);
    }
  }
}

void pathfinder() { // is looking for "waypoints[]" on the map.
  newPathfinder.move();
  newPathfinder.force();
  newPathfinder.display();
  count++;
  if (count < path.length) {
    path[count] = new PVector(pathfinder.x, pathfinder.y);
  }
  for (int i = 0; i < path.length; i++) {
    fill(255, 255, 150, 100);
    noStroke();
    ellipse(path[i].x, path[i].y, 4, 4);
  }
}

class Pathfinder {
  color c;
  float xpos;
  float ypos;
  float xspeed = 0;
  float yspeed = 0;
  float maxSpeed = 0.2;
  int rand, distance;
  float[] deltaPos = new float [numberWaypoints];

  Pathfinder() {
    rand = 25;
    distance = 100;
    xpos = 500;
    ypos = 200;
    xspeed = 0;
    yspeed = 0;
  }
  void display() {
    rectMode(CENTER);
    noStroke();
    noFill();
    strokeWeight(2);
    stroke(255, 255, 0, 100);
    ellipse(xpos, ypos, 50, 50);
    for (int i = 0; i < waypoint.length; i++) {
      if (deltaPos[i] < distance) {
        strokeWeight(2);
        line(waypointCoordinate[i].x, waypointCoordinate[i].y, pathfinder.x, pathfinder.y);
      }
    }
  }
  void move() {
    pathfinder = new PVector(xpos, ypos);
    xpos = xpos + xspeed;
    if (xpos > mapWidth-rand || xpos < rand) {
      xspeed *= -1;
    }
    ypos = ypos + yspeed;
    if (ypos > height-rand || ypos < rand) {
      yspeed *= -1;
    }
  }
  void force() {
    for (int i = 0; i < waypoint.length; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, pathfinder.x, pathfinder.y);
      if (deltaPos[i] < distance) {
        xspeed -= (1/deltaPos[i])*maxSpeed;
        yspeed -= (1/deltaPos[i])*maxSpeed;
      }
      if (deltaPos[i] > distance) {
        xspeed += (1/deltaPos[i])*maxSpeed;
        yspeed += (1/deltaPos[i])*maxSpeed;
      }
    }
  }
}

void printData() { // displays information on the screen.
  int time = millis()/1000;
  fill(240);
  noStroke();
  rect(0, height, mapPartWidth*4, 40);
  fill(0);
  textFont(cour);
  textSize(14);
  text("Cycles: " + count + " - Time: " + time + "s" + " - Resource: " + waypointsResourceTotal + " - Hits: " + countHitTot + "/" + numberWaypoints, 10, height-5);
}
