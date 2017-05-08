// REMAP v.1 by David Herren - 2017
// HSLU D&K - IDA Enzyklopaedie Emmen
// ----------------------------------

PImage mapOrg, mapImageBfull;
PImage[] mapImageA, mapImageB, photo;

int mapWidth, mapPartWidth, rasterMapBountX, rasterMapBountY, rasterMapBountXY, systemSize;

PVector analyser;
PVector[] gridMaster, waypointCoordinate;
PVector[] path = new PVector [10000];

int numberWaypoints = 60;
int nPhotos = 21;
int count = 0;

boolean mouseClicked;

Analyser newAnalyser;
Waypoints[] waypoint;

void setup() {
  size(1780, 810);
  systemSize = 1; 
  smooth();
  frameRate(30);
  println("REMAP v.1 by David Herren - 2017");
  println("HSLU D&K - IDA Enzyklopaedie Emmen");
  println("---------------------------------------------- \n");
  background(240);
  mapWidth = height/3*5;

  newAnalyser = new Analyser();
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
  println("\n Program started. Press Mousebutton. \n");
}
void draw() {
  raster();
  createMapImage();
  gridMaster();
  createNewMap();
  if (mouseClicked == true) {
    image(mapImageBfull, 0, 0);
    analyser();
    for (int i = 0; i < numberWaypoints; i++) {
      waypoint[i].display();
      waypoint[i].update();
    }
  }
  showImage();
  if (keyPressed == true) {
    if (key == 'n') {   
      waypointCoordinate();
    }
  }
}

void keyPressed () {
  if (key == 's') {
    saveFrame ("capture_####.jpg");
  }
}

// photos() laed die Fotos fuer die Wegpunkte.

void photos() {
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

// raster() bestimmt die Anzahl Teilbilder.

void raster() {
  rasterMapBountX = systemSize*5;
  rasterMapBountY = rasterMapBountX/5*3;
  rasterMapBountXY = rasterMapBountX*rasterMapBountY;
  gridMaster = new PVector[rasterMapBountXY];
  mapPartWidth = mapWidth/rasterMapBountX;
}

// gridMaster() erzeugt Vektoren gemaess raster().

void gridMaster() {
  int k = 0;
  for (int j = 0; j < rasterMapBountY; j++) {    
    for (int i = 0; i < rasterMapBountX; i++) {      
      gridMaster[k] = new PVector(i*mapPartWidth, j*mapPartWidth);
      k = k+1;
    }
  }
}

// gridSquare() zeichnet Rechtecke gemaess gridMaster().

void gridSquare() {
  int s = 1;
  stroke(255);
  rect(0, 0, mapWidth-s, height-s);
  for (int i = 0; i < rasterMapBountXY; i++) {    
    strokeWeight(s);
    stroke(255);
    rect(gridMaster[i].x, gridMaster[i].y, mapPartWidth, mapPartWidth);
    fill(255);
    ellipse(gridMaster[i].x+mapPartWidth/2, gridMaster[i].y+mapPartWidth/2, 10, 10);
  }
}

// createMapImage() rechnet mapOrg in ganzes Pixelbild mapImage[A, B, C, etc.] um.

void createMapImage() {
  mapImageA = new PImage[rasterMapBountXY];
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageA[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageA[i].loadPixels();
  }  
  mapImageB = new PImage[rasterMapBountXY];
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageB[i] = createImage(mapPartWidth, mapPartWidth, RGB);
    mapImageB[i].loadPixels();
  }
}

// createNewMap() erzeugt eine neue Karte gemaess map[A, B, C, etc.].

void createNewMap() {
  if (mousePressed == true) {
    mouseClicked = false;
    int s = second();
    int m = minute();
    int h = hour();
    println("Mouse pressed! " + h + ":" + m + ":" + s);
    boolean t = true;
    while (t == true) {
      int s_start = millis();
      if (t == true) {
        mapA();
        print("Data loaded.. ");
        mapB();
        println(" calculated.");        
        delay(500);
        t = false;
      }
      int s_stop = millis();
      int s_tot = s_stop-s_start;
      mouseClicked = true;
      println("Parts=" + gridMaster.length + " Duration=" + s_tot + "ms");
      println("----------------------------------------------");
    }
  }
}

// mapA() zerlegt mapOrg in Teilbilder mapImageB.

void mapA() {
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

// mapB() ordnet mapImageB neu.

void mapB() {
  int[] randomXY =  new int[rasterMapBountXY];
  for (int i = 0; i < randomXY.length; i++) {
    randomXY[i]=i;
  }
  for (int i = 0; i < randomXY.length; i++) {
    int temp = randomXY[i]; 
    int j = (int)random(0, randomXY.length);    
    randomXY[i]=randomXY[j];
    randomXY[j]=temp;
  }
  for (int i = 0; i < rasterMapBountXY; i++) {
    mapImageB[i] = mapImageB[i];
  }
  for (int i = 0; i < rasterMapBountXY; i++) { 
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

// analyserA() sucht auf der Karte nach Wegmarken.

void analyser() {
  newAnalyser.move();
  newAnalyser.force();
  newAnalyser.display();
  count++;
  if (count < path.length) {
    path[count] = new PVector(analyser.x, analyser.y);
    int x = int(path[count].x);
    int y = int(path[count].y);
    print("Path Nr.:", count, "X:", x, "Y:", y, "\n");
  }
  for (int i = 0; i < path.length; i++) {
    fill(255, 255, 150, 100);
    noStroke();
    ellipse(path[i].x, path[i].y, 4, 4);
  }
}

class Analyser {
  color c;
  float xpos;
  float ypos;
  float xspeed = 0;
  float yspeed = 0;
  float maxSpeed = 0.2;
  int rand, distance;
  float[] deltaPos = new float [numberWaypoints];

  Analyser() {
    rand = 25;
    distance = 100;
    xpos = 500;
    ypos = 500;
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
    for (int i = 0; i < numberWaypoints; i++) {
      if (deltaPos[i] < distance) {
        strokeWeight(2);
        line(waypointCoordinate[i].x, waypointCoordinate[i].y, analyser.x, analyser.y);
      }
    }
  }
  void move() {
    analyser = new PVector(xpos, ypos);

    xpos = xpos + xspeed;
    if (xpos > mapWidth-rand) {
      xspeed = xspeed * -1;
    }
    if (xpos < rand) {
      xspeed = xspeed * -1;
    }

    ypos = ypos + yspeed;
    if (ypos > height-rand) {
      yspeed = yspeed * -1;
    }
    if (ypos < rand) {
      yspeed = yspeed * -1;
    }
  }
  void force() {
    for (int i = 0; i < numberWaypoints; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, analyser.x, analyser.y);

      if (deltaPos[i] < distance) {
        xspeed = xspeed - (1/deltaPos[i])*maxSpeed;
      }
      if (deltaPos[i] > distance) {
        xspeed = xspeed + (1/deltaPos[i])*maxSpeed;
      }
      if (deltaPos[i] < distance) {
        yspeed = yspeed - (1/deltaPos[i])*maxSpeed;
      }
      if (deltaPos[i] > distance) {
        yspeed = yspeed + (1/deltaPos[i])*maxSpeed;
      }
    }
  }
}

// showImage() zeigt Fotos gemaess analyser().

void showImage() {
  float[] deltaPos = new float[nPhotos];
  if (mouseClicked == true) {
    for (int i = 0; i < nPhotos; i++) {
      deltaPos[i] = dist(waypointCoordinate[i].x, waypointCoordinate[i].y, analyser.x, analyser.y);
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

void waypointCoordinate() {
  waypointCoordinate = new PVector[numberWaypoints];
  for (int i = 0; i < numberWaypoints; i++) {
    waypointCoordinate[i] = new PVector(random(100, mapWidth-100), random(100, height-100));
    print(waypointCoordinate[i]);
    println();
  }
}

void waypoints() {
  for (int i = 0; i < numberWaypoints; i++) {
    waypoint[i] = new Waypoints(waypointCoordinate[i].x, waypointCoordinate[i].y, 10, 1);
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
    ellipse(xpos, ypos, radius*gain, radius*gain);
  }
  void update() {
    if (sq(xpos - analyser.x) < 100 && sq(ypos - analyser.y) < 100) {
      gain = gain + 0.3;
    }
  }
}
