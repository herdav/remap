// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmenbruecke
// -----------------------------------------

int cycles = 4000;
int numberWaypoints = 21;
int radiusWaypoint = 10;
int nPhotos = 21;
int count = 0;
int lifecycle = 0;
int systemSize = 3;
int rss;
float maxResource = 100;
float resourceCecycle = 0.2;
color colorStroke = color(255, 0, 0, 200);
color colorWaypoint = color(0, 100);
color colorPath = color(255, 50);
PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB, photo;
int countHitTot;
int[] countHits = new int[numberWaypoints];
int mapWidth, mapPartWidth;
int rasterMapBountX, rasterMapBountY, rasterMapBountXY;
float[] waypointsGrowth = new float[numberWaypoints];
float[] resource = new float[numberWaypoints];
float[] deltaResource = new float[numberWaypoints];
float waypointsGrowthTotal;
PVector pathfinder;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector[cycles];
boolean mouseClicked;
boolean[] countHit = new boolean[numberWaypoints];
PFont cour;
XML rssZS, rssLU;
String[] search;
String[] ZS, titleZS, descriptionZS;
String[] LU, titleLU, descriptionLU;
Pathfinder newPathfinder;
Waypoints[] waypoint;

void setup() {
  size(1755, 810, P2D);
  cour = createFont("\\data\\cour.ttf", 14);
  smooth(4);
  frameRate(25);
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
    tint(200, 5);
    //image(mapImageBfull, 0, 0);
    lifecycle++;
    net();
    pathfinder();
    for (int i = 0; i < waypoint.length; i++) {     
      waypoint[i].display();
      waypoint[i].update();
      resource();
      //printData();
    }
    waypointsGrowth();   
    xml();
  }
  showImage();
  saveFrame("\\capture\\capture_####.jpg");
}

void keyPressed () {
  if (key == 's') {
    saveFrame("\\capture\\capture_####.jpg");
  }
}

void raster() { // Determines the number of partial images.
  rasterMapBountX = systemSize*5;
  rasterMapBountY = rasterMapBountX/5*3;
  rasterMapBountXY = rasterMapBountX*rasterMapBountY;
  gridMaster = new PVector[rasterMapBountXY];
  mapPartWidth = mapWidth/rasterMapBountX;
}

void gridMaster() { // Generated vectors according "raster()".
  int k = 0;
  for (int j = 0; j < rasterMapBountY; j++) {    
    for (int i = 0; i < rasterMapBountX; i++) {      
      gridMaster[k] = new PVector(i*mapPartWidth, j*mapPartWidth);
      k += 1;
    }
  }
}

void createMapImage() { // Converts "mapOrg" into whole pixel image "mapImage..".
  mapImageA = new PImage[rasterMapBountXY];
  mapImageB = new PImage[rasterMapBountXY];
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageA[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageB[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageA[i].loadPixels();
    mapImageB[i].loadPixels();
  }
}

void mapA() { // Disassembled PImage "mapOrg" in subpictures "mapImageB[]".
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

void mapB() { // Reorders "mapImageB[]".
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

void createNewMap() { // Creates a new map according to "map..()".
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

void waypointCoordinate() { // Generates the coordinates for "waypoint[]".
  waypointCoordinate = new PVector[waypoint.length];
  int rand = 100;
  for (int i = 0; i < waypoint.length; i++) {
    waypointCoordinate[i] = new PVector(random(rand, mapWidth-rand), random(rand, height-rand));
  }
}

void waypoints() { // Generates the "waypoint[]".
  for (int i = 0; i < waypoint.length; i++) {
    waypoint[i] = new Waypoints(waypointCoordinate[i].x, waypointCoordinate[i].y, radiusWaypoint, 1);
  }
}

void waypointsGrowth() { // Calculates the growth of each "waypoint[]".
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

void net() { // Draws a net between "waypoint[]" and "pathfinder()".
  for (int j = 0; j < path.length; j++) {
    for (int i = 0; i < waypoint.length; i++) {
      if (dist(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos) < 100) {
        strokeWeight(1);
        stroke(colorStroke);
        line(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos);
      }
    }
  }
  for (int j = 0; j < path.length; j++) {
    for (int i = 0; i < path.length; i++) {
      if (dist(path[j].x, path[j].y, path[i].x, path[i].y) < 3) {
        path[j].x = path[i].x;
        path[j].y = path[i].y;
      }
    }
  }
}

void resource() { // Calculates the "consumption" of the "waypoint[]" according to the hits in relation to each other.
  if (lifecycle == 1) {
    maxResource += resourceCecycle;
    lifecycle = 0;
  }
  for (int i = 0; i < waypoint.length; i++) {
    resource[i] = maxResource/waypointsGrowthTotal*waypoint[i].gain;
    deltaResource[i] = resource[i]*waypoint[i].gain;
    float[] r = new float[waypoint.length];
    if (countHitTot > 2) {
      r[i] = deltaResource[i] * 100;
      fill(100, 10);
      ellipse(waypoint[i].xpos, waypoint[i].ypos, r[i], r[i]);
    }
  }
}

class Waypoints {
  float xpos;
  float ypos;
  float gain;
  PVector pos;
  float radius;
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
      radius += gain + float(rss)/50;
    }
  }
}

void photos() { // Loads the photos of the waypoints.
  photo = new PImage[nPhotos];
  for (int i = 0; i < nPhotos; i++) {
    photo[i] = loadImage("\\img\\felderkundung_" + i + ".jpg");
    photo[i].resize(height/6*3, height/3);
  }
}

void showImage() { // Shows photos according to "pathfinder()".
  float[] deltaPos = new float[nPhotos];
  if (mouseClicked == true) {
    for (int i = 0; i < nPhotos; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, pathfinder.x, pathfinder.y);
    }
  }
  for (int j = 0; j < 3; j++) {
    for (int i = nPhotos/3*j; i < nPhotos/3*(j+1); i++) {
      if (deltaPos[i] < 200) {
        image(photo[i], width - photo[i].width, height/3*j);
      }
    }
  }
}

void pathfinder() { // Is looking for "waypoints[]" on the map and draw a "path[]".
  newPathfinder.move();
  newPathfinder.force();
  //newPathfinder.display();
  newPathfinder.path();
}

class Pathfinder {
  float maxSpeed = 0.5;
  float n = 2;
  color c;
  float xpos, ypos;
  float xspeed, yspeed;
  int rand, distance;
  float[] deltaPos = new float [numberWaypoints];
  float rigth, left, top, bottom;

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
    if (xpos > width-rand || xpos < rand) {
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
    left = pathfinder.x;
    rigth = width - pathfinder.x;
    top = pathfinder.y;
    bottom = height - pathfinder.y;
    if (rigth < 300) {
      xspeed -= 100/rigth;
    }
    if (left < 100) {
      xspeed += 100/left;
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
      fill(colorStroke);
      noStroke();
      ellipse(path[i].x, path[i].y, 2, 2);
    }
  }
}

void xml() { // Imports rss-feeds and count specific data.
  textSize(10);
  textFont(cour);
  fill(150, 50);
  rss = 0;
  search = new String[4];
  search[0] = "luzern";
  search[1] = "emmen";
  search[2] = "stadt";
  search[3] = "haus";
  rssZS = loadXML("https://www.srf.ch/news/bnf/rss/1966");
  rssLU = loadXML("http://www.luzernerzeitung.ch/storage/rss/rss/kanton_luzern.xml");
  XML[] titlesZS = rssZS.getChildren("channel/item/title");
  XML[] descriptionsZS = rssZS.getChildren("channel/item/description");  
  XML[] titlesLU = rssLU.getChildren("channel/item/title");
  XML[] descriptionsLU = rssZS.getChildren("channel/item/description");
  for (int i = 0; i < titlesZS.length; i++) {   
    titleZS = new String[titlesZS.length];
    titlesZS[i].getContent();
    titleZS[i] = titlesZS[i].getContent();
    descriptionZS = new String[titlesZS.length];
    descriptionsZS[i].getContent();   
    descriptionZS[i] = descriptionsZS[i].getContent();
    for (int j =0; j < search.length; j++) {
      if (titleZS[i].contains(search[j]) || descriptionZS[i].contains(search[j]) == true) {
        rss++;
        println("RSS ZS: ", i, titleZS[i]);
      }
    }
    text(titleZS[i] + "   " + descriptionZS[i], 0, 12*i);
  }
  for (int i = 0; i < titlesLU.length; i++) {  
    titleLU = new String[titlesLU.length];
    titlesLU[i].getContent();
    titleLU[i] = titlesLU[i].getContent();
    descriptionLU = new String[titlesLU.length];
    descriptionsLU[i].getContent();   
    descriptionLU[i] = descriptionsLU[i].getContent();
    for (int j =0; j < search.length; j++) {
      if (titleLU[i].contains(search[j]) || descriptionLU[i].contains(search[j]) == true) {
        rss++;
        println("RSS LU: ", i, titleLU[i]);
      }
    }
  }  
  println("Total: ", rss);
}

void printData() { // Displays information on the screen, isn't used for praesentation.
  int time = millis()/1000;
  float rate = maxResource/waypointsGrowthTotal;
  fill(240);
  noStroke();
  rect(0, height, width, 40);
  fill(0);
  textFont(cour);
  textSize(14);
  text("Cycles: " + count + "/" + cycles + " - Time: " + time + "s" + " - Hits: " + countHitTot + "/" + numberWaypoints + " - Rate: " + int(rate*100) + " - Nodes: " + sq(cycles)*numberWaypoints, 10, height-5);
}
