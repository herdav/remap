// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmenbruecke
// -----------------------------------------

RSS feedZS, feedLU;
Pathfinder pathfinderA;
Waypoints[] waypoint;

int cycles = 4000;
int numberWaypoints = 30;
int radiusWaypoint = 10;
int systemSize = 5;
int textSize = 14;

float maxResource = 100;
float resourceCycle = 0.2;

color colorStroke = color(0, 255, 0, 150);
color colorWaypoint = color(100, 100);
color colorPath = color(255, 50);

PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB;

int countHitTot;
int[] countHits = new int[numberWaypoints];
int mapWidth, mapPartWidth;
int rasterMapBountX, rasterMapBountY, rasterMapBountXY;
int rss, countRSS;
int newCycle, cycle, count;

float[] waypointsGrowth = new float[numberWaypoints];
float[] resource = new float[numberWaypoints];
float[] deltaResource = new float[numberWaypoints];
float waypointsGrowthTotal, speedPathfinder, gainRSS;

PVector pathfinder;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector[cycles];

boolean mouseClicked;
boolean[] countHit = new boolean[numberWaypoints];

PFont cour;

String[] search, text;

void setup() {
  size(1920, 960, P2D); 
  smooth(4);
  frameRate(25);
  background(240);
  cour = createFont("\\data\\cour.ttf", textSize);
  
  mapWidth = height/3*5;
  pathfinderA = new Pathfinder();
  waypoint = new Waypoints[numberWaypoints];
  for (int i = 0; i < path.length; i++) {
    path[i] = new PVector(0, 0);
  } 
  mapOrg = loadImage("\\img\\map_2400x4000_bw.jpg");
  mapOrg.resize(mapWidth, height);
  mapOrg.loadPixels();
  image(mapOrg, 0, 0);
  waypointCoordinate();
  waypoints();
  xml();
  raster();
  createMapImage();
  gridMaster();
  mapA();
  mapB();
}

void draw() {
  if (cycle++ <= cycles) {
    int t = millis();
    image(mapImageBfull, 0, 0);
    newCycle++;
    cycle++;
    net();
    pathfinder();
    for (int i = 0; i < waypoint.length; i++) {     
      waypoint[i].display();
      waypoint[i].update();
      resource();
      waypointsGrowth();
    }    
    xml(); 
    t = millis() - t;
    println("hits:", countHitTot + "/" + numberWaypoints, " rss:", gainRSS, "-", rss + "/" + countRSS,
      " cycle:", t + "ms", "-", cycle + "/" + cycles, " speed:", speedPathfinder, "-", int((speedPathfinder/t)*1000) + "px/s");
    saveFrame("\\capture\\capture_####.jpg");
  }
}

void keyPressed () { // Saves screenshot under specific folder.
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

void waypointCoordinate() { // Generates the coordinates for "waypoint[]".
  waypointCoordinate = new PVector[waypoint.length];
  int rand = 100;
  for (int i = 0; i < waypoint.length; i++) {
    waypointCoordinate[i] = new PVector(random(rand, width-rand), random(rand, height-rand));
  }
}

void waypoints() { // Generates the "waypoint[]".
  for (int i = 0; i < waypoint.length; i++) {
    waypoint[i] = new Waypoints(waypointCoordinate[i].x, waypointCoordinate[i].y, radiusWaypoint, gainRSS);
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
  if (newCycle == 1) {
    maxResource += resourceCycle;
    newCycle = 0;
  }
  for (int i = 0; i < waypoint.length; i++) {
    resource[i] = maxResource/waypointsGrowthTotal*waypoint[i].gain;
    deltaResource[i] = resource[i]*waypoint[i].gain;
    float[] r = new float[waypoint.length];    
    if (countHitTot > 2) {
      r[i] = deltaResource[i] * 100;
      fill(0, 255, 0, 5);
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
      gain += gainRSS;
      radius += gain;
    }
  }
}

void pathfinder() { // Is looking for "waypoints[]" on the map and draw a "path[]".
  pathfinderA.move();
  pathfinderA.force();
  pathfinderA.path();

  speedPathfinder = float(int(sqrt(sq(pathfinderA.xspeed) + sq(pathfinderA.yspeed))*10))/10;
}

class Pathfinder {
  float maxSpeed = 6;
  float n = 1;
  color c;
  float xpos, ypos;
  float xspeed, yspeed;
  int rand, distance;
  float[] deltaPos = new float [numberWaypoints];
  float rigth, left;

  Pathfinder() {
    rand = 25;
    distance = 200;
    xpos = 200;
    ypos = 200;
    xspeed = 0;
    yspeed = 0;
  }
  void move() {
    pathfinder = new PVector(xpos, ypos);
    
    xpos = xpos + xspeed;
    ypos = ypos + yspeed;

    if (xpos > width-rand || xpos < rand) {
      xspeed *= -1;
    }
    if (ypos > height-rand || ypos < rand) {
      yspeed *= -1;
    }
  }
  void force() {
    for (int i = 0; i < waypoint.length; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, pathfinder.x, pathfinder.y);
      if (deltaPos[i] < distance) {
        xspeed -= (n/deltaPos[i]);
        yspeed -= (n/deltaPos[i]);
      }
      if (deltaPos[i] > distance) {
        xspeed += (n/deltaPos[i]);
        yspeed += (n/deltaPos[i]);
      }
    }
    left = pathfinder.x;
    rigth = width - pathfinder.x;

    if (rigth < 200) {
      xspeed -= 100/rigth;
      yspeed -= 50/rigth;
    }
    if (left < 100) {
      xspeed += 100/left;
    }
    if (xspeed > maxSpeed) {
      xspeed = maxSpeed;
    }
    if (xspeed < -maxSpeed) {
      xspeed = -maxSpeed;
    }
    if (yspeed > maxSpeed) {
      yspeed = maxSpeed;
    }
    if (yspeed < -maxSpeed) {
      yspeed = -maxSpeed;
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
      ellipse(path[i].x, path[i].y, 4, 4);
    }
  }
}

void xml() { // Imports rss-feeds and count specific data.
  rss = 0;
  textSize(textSize);
  textFont(cour);
  fill(0, 255, 0, 100);

  search = new String[4];
  search[0] = "Luzern";
  search[1] = "Emmen";
  search[2] = "Stadt";
  search[3] = "Entwicklung";

  feedZS = new RSS("https://www.srf.ch/news/bnf/rss/1966");
  feedLU = new RSS("http://www.luzernerzeitung.ch/storage/rss/rss/kanton_luzern.xml");

  feedZS.loadFeed(search);  
  feedLU.loadFeed(search);

  for (int i = 0; i < feedLU.result.length; i++) {
    if (feedLU.result[i] != null) {
      rss++;
      text(feedLU.result[i], -textSize, textSize+textSize*i);
    }
  }
  for (int i = 0; i < feedZS.result.length; i++) {
    if (feedZS.result[i] != null) {
      rss++;
      text(feedZS.result[i], 0, 10*textSize+textSize+textSize*i);
    }
  }
  gainRSS = float(int((resourceCycle-1/float(rss))*100))/100;
  countRSS = feedZS.title.length + feedLU.title.length;
}

class RSS {
  String xml;
  String[] title, description, result;
  XML feed;

  RSS(String tempXML) {
    xml = tempXML;
    feed = loadXML(xml);
  }
  void loadFeed(String[] search) {
    XML[] titles = feed.getChildren("channel/item/title");
    XML[] descriptions = feed.getChildren("channel/item/description");

    result = new String[titles.length];

    for (int i = 0; i < titles.length; i++) {
      title = new String[titles.length];
      titles[i].getContent();
      title[i] = titles[i].getContent();

      description = new String[descriptions.length];
      descriptions[i].getContent();
      description[i] = descriptions[i].getContent();

      for (int j = 0; j < search.length; j++) {
        if (description[i].contains(search[j]) || title[i].contains(search[j]) == true) {
          result[i] = title[i] + " - " + description[i];
        }
      }
    }
  }
}
