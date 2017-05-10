// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmenbruecke
// -----------------------------------------

int cycles = 10000;
int numberWaypoints = 40;
int radiusWaypoint = 10;
int nPhotos = 21;
int count = 0;
int lifecycle = 0;
int systemSize = 1;
float maxResource = 100;
float resourceCecycle = 0.2;

color colorStroke = color(255, 255, 150, 100);
color colorWaypoint = color(255, 255, 150, 100);
color colorPath = color(255, 150);

PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB, photo;

int countHitTot;
int[] countHits = new int[numberWaypoints];
int mapWidth, mapPartWidth;
int rasterMapBountX, rasterMapBountY, rasterMapBountXY;
float[] waypointsGrowth = new float[numberWaypoints];
float[] resource = new float[numberWaypoints];
float[] delatResource = new float[numberWaypoints];
float waypointsGrowthTotal;

PVector pathfinder;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector[cycles];

boolean mouseClicked;
boolean[] countHit = new boolean[numberWaypoints];

PFont cour;

Pathfinder newPathfinder;
Waypoints[] waypoint;

void setup() {
  size(1780, 810, P2D);
  cour = createFont("\\data\\cour.ttf", 14);
  smooth();
  frameRate(30);
  background(240);
  mapWidth = height/3*5;
  newPathfinder = new Pathfinder();
  waypoint = new Waypoints[numberWaypoints];
  for (int i = 0; i < path.length; i++) {
    path[i] = new PVector(0, 0);
  }
  mapOrg = loadImage("\\img\\map_2400x4000_sw.jpg");
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
    lifecycle++;
    pathfinder();
    for (int i = 0; i < waypoint.length; i++) {     
      waypoint[i].display();
      waypoint[i].update();
      resource();
      printData();
    }
    net();
    waypointsGrowth();
  }
  showImage();
}

void keyPressed () {
  if (key == 's') {
    saveFrame ("\\capture\\capture_####.jpg");
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
  int rand = 100;
  for (int i = 0; i < waypoint.length; i++) {
    waypointCoordinate[i] = new PVector(random(rand, mapWidth-rand), random(rand, height-rand));
  }
}

void waypoints() { // generates the "waypoint[]".
  for (int i = 0; i < waypoint.length; i++) {
    waypoint[i] = new Waypoints(waypointCoordinate[i].x, waypointCoordinate[i].y, radiusWaypoint, 1);
  }
}

void waypointsGrowth() { // calculates the growth of each "waypoint[]".
  waypointsGrowthTotal = -waypoint.length*sq(radiusWaypoint)/2;
  for (int i = 0; i < waypoint.length; i++) {
    waypointsGrowth[i] = sq((waypoint[i].radius))/2;
    waypointsGrowthTotal += waypointsGrowth[i];
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

void net() {
  for (int j = 0; j < path.length; j++) {
    for (int i = 0; i < waypoint.length; i++) {
      if (dist(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos) < 100) {
        strokeWeight(1);
        stroke(colorStroke);
        line(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos);
      }
    }
  }
}

void resource() {
  if (lifecycle == 1) {
    maxResource += resourceCecycle;
    lifecycle = 0;
  }
  for (int i = 0; i < waypoint.length; i++) {
    resource[i] = maxResource/waypointsGrowthTotal*waypoint[i].gain;
    delatResource[i] = resource[i]*waypoint[i].gain;
    float[] r = new float[waypoint.length];
    if (countHitTot > 3) {
      r[i] = delatResource[i] * 100;
      //noStroke();
      fill(255, 255, 200, 5);
      ellipse(waypoint[i].xpos, waypoint[i].ypos, r[i], r[i]);
    }
  }
}

class Waypoints {
  float xpos;
  float ypos;
  float gain;
  PVector pos;
  int radius;
  int border = 400;

  Waypoints(float tempX, float tempY, int tempRadius, float tempGain) {
    xpos = tempX;
    ypos = tempY;
    gain = tempGain;
    radius = tempRadius;
    pos = new PVector(xpos, ypos);
  }
  void display() {
    noStroke();
    fill(colorWaypoint);
    ellipse(xpos, ypos, radius, radius);
  }
  void update() {
    if (sq(xpos - pathfinder.x) < border && sq(ypos - pathfinder.y) < border) {
      gain += 0.1;
      radius += gain;
    }
  }
}

void photos() { // loads the photos of the waypoints.
  photo = new PImage[nPhotos];
  for (int i = 0; i < nPhotos; i++) {
    photo[i] = loadImage("\\img\\felderkundung_" + i + ".jpg");
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

void pathfinder() { // is looking for "waypoints[]" on the map and draw a "path[]".
  newPathfinder.move();
  newPathfinder.force();
  newPathfinder.display();
  newPathfinder.path();
}

class Pathfinder {
  float maxSpeed = 0.5;
  float n = 2;
  color c;
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
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
    stroke(colorStroke);
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
        xspeed -= (n/deltaPos[i])*maxSpeed;
        yspeed -= (n/deltaPos[i])*maxSpeed;
      }
      if (deltaPos[i] > distance) {
        xspeed += (n/deltaPos[i])*maxSpeed;
        yspeed += (n/deltaPos[i])*maxSpeed;
      }
    }
  }
  void path() {
    if (count < cycles) {
      if (count < path.length) {
        path[count] = new PVector(pathfinder.x, pathfinder.y);
        count++;
      }
      if (count == cycles) {
        count = 0;
      }
    }
    for (int i = 0; i < path.length; i++) {
      fill(colorPath);
      noStroke();
      ellipse(path[i].x, path[i].y, 2, 2);
    }
  }
}

void printData() { // displays information on the screen.
  int time = millis()/1000;
  float rate = waypointsGrowthTotal/maxResource;
  fill(240);
  noStroke();
  rect(0, height, mapPartWidth*6, 40);
  fill(0);
  textFont(cour);
  textSize(14);
  text("Cycles: " + count + "/" + cycles + " - Time: " + time + "s" + " - Hits: " + countHitTot + "/" + numberWaypoints + " - Rate: " + rate, 10, height-5);
}
