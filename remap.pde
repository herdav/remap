// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmenbruecke
// -----------------------------------------

RSS feedZS, feedLU;
wanderer wandererA;
Waypoints[] waypoint;

// Setup -----------------------------------

int cycles = 8000;
int maxCycles = 8000;
boolean showMAP = true;
boolean showXML = true;
boolean video = false;

// -----------------------------------------

int numberWaypoints = 90;
int radiusWaypoint = 10;
int systemSize = 4;
int textSize = 30;

float maxResource = 100;
float resourceCycle = 0.2;

color colorStroke = color(0, 255, 0, 150);
color colorWaypoint = color(100, 100);
color colorPath = color(255, 50);
color colorBackground = color(200);
color colorText = color(255, 200);

PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB;

int explorations;
int[] countExplorations = new int[numberWaypoints];
int mapWidth, mapPartWidth;
int rasterMapBountX, rasterMapBountY, rasterMapBountXY;
int rss, countRSS;
int cycleResource, cycle, count;
int day = day();
int month = month();
int year = year();

float[] waypointsGrowth = new float[numberWaypoints];
float[] resource = new float[numberWaypoints];
float[] deltaResource = new float[numberWaypoints];
float waypointsGrowthTotal, speedWanderer, gainRSS;

PVector wanderer;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector[cycles];

boolean mouseClicked;
boolean[] countExploration = new boolean[numberWaypoints];

PFont cour;

String[] search, text;

void setup() {
  size(3000, 1500, P2D); //1840, 920
  smooth(8);
  frameRate(25);
  background(colorBackground);
  cour = createFont("\\data\\courbd.ttf", textSize);
  mapWidth = height / 3 * 5;
  wandererA = new wanderer();
  waypoint = new Waypoints[numberWaypoints];
  for (int i = 0; i < path.length; i++) {
    path[i] = new PVector(0, 0);
  }
  mapOrg = loadImage("\\img\\map_2400x4000_bw_light.jpg");
  mapOrg.resize(mapWidth, height);
  mapOrg.loadPixels();
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
  int millis = millis();
  if (cycle > 100) {
    showMAP = false;
    showXML = false;
  }
  if (cycle <= maxCycles) {
    if (showMAP == true) {
      image(mapImageBfull, 0, 0);
    }
    if (showMAP == false) {
      fill(colorBackground);
      rect(0, 0, width, height);
    }
    cycleResource++;
    cycle++;
    xml();
    net();
    wanderer();
    date();
    for (int i = 0; i < waypoint.length; i++) {     
      waypoint[i].display();
      waypoint[i].update();
      resource();
      waypointsGrowth();
    }    
    millis = millis() - millis;
    println("explorations:", explorations + "/" + numberWaypoints, " rss:", gainRSS + "/" + resourceCycle, "-", rss + "/" + countRSS, 
      " speed:", speedWanderer, " cycle:", cycle + "/" + maxCycles + "(" + cycles + ")", "-", millis + "ms");

    if (video == true) {
      saveFrame("\\capture\\video_####.jpg");
    }
  }
}

void keyPressed () { // Saves screenshot under specific folder.
  if (key == 's') {
    saveFrame("\\capture\\capture_####.jpg");   
  }
}

void date() { // Shows date and time on screen.
  int minute = minute();
  int hour = hour();
  textSize(textSize);
  textFont(cour);
  textAlign(LEFT);
  fill(255, 210);
  text(day + "." + month + "." + year + " " + hour + ":" + minute, width - systemSize * mapPartWidth + 30, height - 30);
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
  int rand = height / 6;
  for (int i = 0; i < waypoint.length; i++) {
    waypointCoordinate[i] = new PVector(random(rand, width-2*rand), random(rand, height-rand));
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
      countExploration[i] = true;
    }
  }
  explorations = 0;
  for (int i = 0; i < waypoint.length; i++) {
    if (countExploration[i] == true) {
      explorations += 1;
    }
  }
}

void net() { // Draws a net between "waypoint[]" and "wanderer()".
  for (int j = 0; j < path.length; j++) {
    for (int i = 0; i < waypoint.length; i++) {
      if (dist(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos) < height / 8) {
        strokeWeight(1);
        stroke(colorStroke);
        line(path[j].x, path[j].y, waypoint[i].xpos, waypoint[i].ypos);
      }
    }
  }
}

void resource() { // Calculates the "consumption" of the "waypoint[]" according to the hits in relation to each other.
  if (cycleResource == 1) {
    maxResource += resourceCycle;
    cycleResource = 0;
  }
  for (int i = 0; i < waypoint.length; i++) {
    resource[i] = maxResource/waypointsGrowthTotal*waypoint[i].gain;
    deltaResource[i] = resource[i]*waypoint[i].gain;
    float[] r = new float[waypoint.length];    
    if (explorations > 2) {
      r[i] = deltaResource[i] * 100;
      fill(0, 255, 0, 5);
      ellipse(waypoint[i].xpos, waypoint[i].ypos, r[i], r[i]);
    }
  }
}

class Waypoints {
  int border = height / 3;
  float xpos;
  float ypos;
  float gain;
  float radius;
  PVector pos;

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
    if (sq(xpos - wanderer.x) < border && sq(ypos - wanderer.y) < border) {
      gain += gainRSS;
      radius += gain;
    }
  }
}

void wanderer() { // Is looking for "waypoints[]" on the map and draw a "path[]".
  wandererA.move();
  wandererA.force();
  wandererA.path();

  speedWanderer = float(int(sqrt(sq(wandererA.xspeed) + sq(wandererA.yspeed))*10))/10;
}

class wanderer {
  float maxSpeed = 6;
  float n = 10;
  color c;
  float xpos, ypos;
  float xspeed, yspeed;
  int rand, distance;
  float[] deltaPos = new float [numberWaypoints];
  float rigth, left;

  wanderer() {
    distance = height / 4;
    rand = distance / 4;
    xpos = width - 700;
    ypos = height - 200;
    xspeed = 0;
    yspeed = 0;
  }
  void move() {
    wanderer = new PVector(xpos, ypos);

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
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, wanderer.x, wanderer.y);
      float attraction = 1/deltaPos[i];
      if (deltaPos[i] < distance) {
        xspeed += attraction;
        yspeed += attraction;
      }
      if (deltaPos[i] > distance) {
        xspeed -= attraction;
        yspeed -= attraction;
      }
    }
    left = wanderer.x;
    rigth = width - wanderer.x;

    if (rigth < height / 4) {
      xspeed -= (height / 8) / rigth;
      yspeed -= (height / 16) / rigth;
    }
    if (left < height / 8) {
      xspeed += (height / 8) / left;
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
        path[count] = new PVector(wanderer.x, wanderer.y);
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
  textAlign(LEFT);
  fill(colorText);

  search = new String[4];
  search[0] = "Emmen";
  search[1] = "Brücke";
  search[2] = "Stadt";
  search[3] = "Viscosi";

  feedZS = new RSS("https://www.srf.ch/news/bnf/rss/1966");
  feedLU = new RSS("http://www.luzernerzeitung.ch/storage/rss/rss/kanton_luzern.xml");

  feedZS.loadFeed(search);  
  feedLU.loadFeed(search);

  for (int i = 0; i < feedLU.result.length; i++) {
    if (feedLU.result[i] != null) {
      rss++;
      if (showXML == true) {
        text(feedLU.result[i], -textSize, 5*textSize+textSize*rss*1.5);
      }
    }
  }
  for (int i = 0; i < feedZS.result.length; i++) {
    if (feedZS.result[i] != null) {
      rss++;
      if (showXML == true) {
        text(feedZS.result[i], 0, 15*textSize+textSize+textSize*rss*1.5);
      }
    }
  }
  gainRSS = float(int((resourceCycle-resourceCycle/float(rss))*1000))/1000;
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
