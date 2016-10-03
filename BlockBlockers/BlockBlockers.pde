// Phoebe Chua, Von Bock, Jeffrey Daub 
// Date: January 27, 2015 

import processing.opengl.*;
import ddf.minim.*;

class Button {
  PVector pos;
  color textColor, hoverColor;
  float size, tWidth;
  String text;

  Button(String text, PVector pos, float size, color textColor, color hoverColor) {
    this.pos = pos;
    this.textColor = textColor;
    this.hoverColor = hoverColor;
    this.size = size;
    this.text = text;
    textSize(size);
    tWidth = textWidth(text);
  }

  void drawText() {
    textSize(size);
    if (isKeyboard){
    if (containsMouse()) fill(hoverColor);
    else fill(textColor);
    }
//    
//    if (isController){
//    if (this == menuButtons[0] && menuSelect == 0) fill(hoverColor); 
//    else if (this == menuButtons[1] && menuSelect == 1) fill(hoverColor); 
//    else if (this == menuButtons[2] && menuSelect == 2) fill(hoverColor);
//    else fill(textColor);
//    } 
    
    text(text, pos.x, pos.y + size);
  }

  boolean containsMouse() {
    if (mouseX > pos.x && mouseX < pos.x + tWidth && mouseY > pos.y && mouseY < pos.y + size )
      return true;
    else return false;
  }
}

class Box {
  int id;
  int w, h;

  Box(int x, int y, int w, int h) {
    id = world.addBox(x, y, w, h);
    world.setUserData(id, this);
    this.w = w;
    this.h = h;
  }

  void drawPlayer() {
    pushMatrix();

    // Get this box's current position and orientation
    // from the physics simulation; use them to adjust
    // the coordinate system so it's drawn where the
    // simulation says it should be.
    translate(world.getX(id), world.getY(id));
    rotate(world.getAngle(id));

    PImage iceGuy = loadImage("chief.png");
    imageMode(CENTER); 
    image(iceGuy, 0, 0, w, h);
    popMatrix();
  }

  void drawBox() {
    pushMatrix();

    // Get this box's current position and orientation
    // from the physics simulation; use them to adjust
    // the coordinate system so it's drawn where the
    // simulation says it should be.
    translate(world.getX(id), world.getY(id));
    rotate(world.getAngle(id));

    PImage iceBlock = loadImage("iceBlock.png");
    imageMode(CENTER);
    image(iceBlock, 0, 0, w, h);
    popMatrix();
  }

  void push(float x, float y) {
    world.applyForce(id, x, y);
  }
}

float transX;
float transY;
boolean boost;
int booster;
int menuSelect = 0;
int timeLapse = 30;

Minim minim;
AudioPlayer song;

Button[] menuButtons;
Button[] controllerOptionsButtons;
boolean drawBoxes;
boolean isControllerOptions; 
boolean isMainMenu;
boolean isInstructions;
boolean isStory;
boolean isLeaderboard;
boolean isLevel;
boolean isController;
boolean isKeyboard = true;

World world;
Box player;
Box[] boxes;
int boxCount;
int startTime;
int elapsedTime;
int gameTime;
int lives;
int level;
int lastLevel;
boolean isGameOver;

void setup() {
  size(480, 640);
  rectMode(CENTER);
  textSize(4);
  textAlign(CENTER, CENTER);
  noStroke();

  menuButtons = new Button[4];
  controllerOptionsButtons = new Button[3];
  isMainMenu = true;
  isInstructions = false;
  isStory = false;
  isLeaderboard = false;
  isLevel = false;

  // Set up physics simulation and objects that exist
  // from the beginning of the game.  
  world = new World(this, true);

  world.addPlatform(0, 70, 100, 1); // top wall
  world.addPlatform(-40, 40, 5, 400); // left wall
  world.addPlatform(40, 40, 5, 400); // right wall
  world.addPlatform(0, -40, 35, 2); // middle platform
  world.addPlatform(30, 5, 20, 2); // right platform
  world.addPlatform(-30, 5, 20, 2); // left platform
  world.addPlatform(-37, 7, 3, 3); // little blocks in the corners
  world.addPlatform(37, 7, 3, 3);

  // Array to hold references to falling box objects as
  // they're created.
  boxes = new Box[999];
  boxCount = 0;

  minim = new Minim(this);
  song = minim.loadFile("MenuMusic.mp3");
  song.play();

  lives = 1;
  isGameOver = false;
  gameTime = 60;
}

// resets global variables when returning to the menu and resets the world
void reset() {
  loop();
  isMainMenu = true;
  isInstructions = false;
  isStory = false;
  isLevel = false;
  world = new World(this, true);
  world.addPlatform(0, 70, 100, 1); // top wall
  world.addPlatform(-40, 40, 5, 400); // left wall
  world.addPlatform(40, 40, 5, 400); // right wall
  world.addPlatform(0, -40, 35, 2); // middle platform
  world.addPlatform(30, 5, 20, 2); // right platform
  world.addPlatform(-30, 5, 20, 2); // left platform
  world.addPlatform(-37, 7, 3, 3); // little blocks in the corners
  world.addPlatform(37, 7, 3, 3);
  boxes = new Box[999];
  boxCount = 0;
  player = new Box(0, 0, 5, 5);
  lives = 1;
  isGameOver = false;
  gameTime = 60;
}

void draw() {
  background(180);
  fill(0); 

  if (isMainMenu && !isLevel) {
    PImage instructions = loadImage("blankScreen.jpg");
    imageMode(CENTER); 
    image(instructions, width / 2, height / 2, 480, 640);

    menuButtons[0] = new Button("Play", new PVector(width / 2 - 50, height / 2 - 20), 50, color(215, 125, 0), color(255, 0, 0));
    menuButtons[1] = new Button("Instructions", new PVector(width / 2 - 140, height / 2 + 40), 50, color(215, 125, 0), color(255, 0, 0));
    menuButtons[2] = new Button("Story", new PVector(width / 2 - 60, height / 2 + 100), 50, color(215, 125, 0), color(255, 0, 0));
    menuButtons[3] = new Button("BLOCK BLOCKERS", new PVector(width / 2 - 127, height / 2 - 130), 30, color(255, 255, 255), color(255, 0, 0));
    //text("BLOCK BLOCKERS", width / 2 - 127, height / 2 - 130);
    displayMenu();
    transY = 0;
  }

  if (isInstructions) {
    PImage instructions = loadImage("instructions.jpg");
    imageMode(CENTER); 
    image(instructions, width / 2, height / 2, 480, 640);

    menuButtons[3] = new Button("Main Menu", new PVector(width / 2 - 200, height / 2 + 260), 30, color(215, 125, 0), color(255, 0, 0));
    menuButtons[3].drawText();
  }

  if (isStory) {
    PImage story = loadImage("story.jpg");
    imageMode(CENTER);
    image(story, width / 2, height / 2, 480, 640);

    menuButtons[3] = new Button("Main Menu", new PVector(width / 2 - 200, height / 2 + 260), 30, color(215, 125, 0), color(255, 0, 0));
    menuButtons[3].drawText();
  }

  if (isLevel) {
    // Tell the simulation to move forward in time.  (One
    // move for each frame of the animation.)
    world.step();

    translate(width / 2, height / 2);
    scale(height / 100, -height / 100);

    fill(50);
    rectMode(CENTER);
    rect(-40, 40, 5, 400); //left wall
    rect(40, 40, 5, 400); //right wall

    rect(0, -40, 35, 2); // bottom platform
    rect(30, 5, 20, 2); // right platform
    rect(-30, 5, 20, 2); // left platform

    rect(-37, 7, 3, 3); // corner blocks
    rect(37, 7, 3, 3);

    PImage building1 = loadImage("building1.png");
    PImage building2 = loadImage("building2.png");
    PImage building3 = loadImage("building3.png");
    PImage building4 = loadImage("building4.png");
    imageMode(CENTER); 
    image(building3, -28, 9, 8, 8);
    image(building1, 28, 9, 8, 8);
    image(building2, -5, -35, 8, 8);
    image(building4, 10, -35, 8, 8);

    int score = 0;

    // Draw existing boxes.
    for (int i = 0; i < boxCount; i++) {

      if (world.getY(boxes[i].id) > -75) {
        boxes[i].drawBox();
      } 
      else {
        score += 10 * boxes[i].w;
      }
    }

    if (world.getY(player.id) > -75) {
      // Draw player
      fill(255, 0, 0);

      player.drawPlayer();
    } 
    else {
      if (lives > 0) {
        lives--;
        player = new Box(0, 0, 4, 4);
      } 
      else {
        pushMatrix();
        scale(0.15, -0.15);
        fill(0);
        drawGameOver();
        popMatrix();
        noLoop();
      }
    }

    if (score >= 12800) {
      level = 6;
    } 
    else if (score >= 6400) {
      level = 5;
    } 
    else if (score >= 3200) {
      level = 4;
    } 
    else if (score >= 1600) {
      level = 3;
    } 
    else if (score >= 800) {
      level = 2;
    } 
    else {
      level = 1;
    }

    // Generate new boxes at regular intervals.
    if (frameCount % (60 - level) == 0 && boxCount < boxes.length) {
      int size = 4 + (2 * int(random(0, level)));
      boxes[boxCount++] = new Box(int(random(-35, 35)), 60, size, size);
    }

    if (lastLevel != level) {
      startTime = millis();
    }

    lastLevel = level;

    // draws the timer
    pushMatrix();
    translate(-35, -40);
    scale(10, -10);
    elapsedTime = millis() - startTime;
    drawTimer();
    popMatrix();

    // draws the score
    pushMatrix();
    translate(35, -41);
    scale(0.1, -0.1);
    drawStatus(score);
    popMatrix();
  }

  if (!song.isPlaying()) {
    song.loop();
  }
}

void displayMenu() {
  imageMode(CENTER);
 
   if (isMainMenu) {
    
    world.step();

    pushMatrix();
    translate(width / 2, height / 2);
    scale(height / 100, -height / 100);

    fill(180);
    rectMode(CENTER);
    rect(-40, 40, 5, 400); //left wall
    rect(40, 40, 5, 400); //right wall

    rect(0, -40, 35, 2); // bottom platform
    rect(30, 5, 20, 2); // right platform
    rect(-30, 5, 20, 2); // left platform

    rect(-37, 7, 3, 3); // corner blocks
    rect(37, 7, 3, 3);


    for (int i = 0; i < boxCount; i++) {

      if (world.getY(boxes[i].id) > -75) {
        boxes[i].drawBox();
      }
    }

    if (frameCount % 240 == 0 && boxCount < boxes.length) {
      int size = 4 + (2 * int(random(0, 3)));
      boxes[boxCount++] = new Box(int(random(-35, 35)), 60, size, size);
    }
    popMatrix();

    textAlign(BASELINE);

    for (int i = 0; i < menuButtons.length; i++) {
      menuButtons[i].drawText();
    }
  }
}

void drawTimer() {
  pushMatrix();

  // Put (0, 0) at center of 1 x 1 square; Rotate so that an
  // angle of zero points up.
  translate(0.5, 0.5);
  rotate(-HALF_PI);

  // Draw red circle with (thick) gray outline.
  fill(255, 60, 20);
  strokeWeight(0.1);
  stroke(100);
  ellipse(0, 0, 1, 1);

  // Draw black pie-shaped circle portion; the wedge cut out
  // of the pie starts at zero (straight up) and ends at an
  // angle determined by the amount of time since the program
  // started.
  fill(100);
  noStroke();
  float endAngle = TWO_PI * elapsedTime / 1000 / gameTime;
  arc(0, 0, 1, 1, endAngle, TWO_PI, PIE);

  popMatrix();

  // After 60 seconds the wedge out of the pie is the whole pie;
  // at this point stop updating the window.  Time has run out
  // for the player.
  if (endAngle >= TWO_PI) {
    pushMatrix();
    scale(0.1, 0.1);
    translate(35, -40);
    scale(0.15, 0.15);
    drawGameOver();
    popMatrix();
    noLoop();
  }
}

int pushForce;
void handleButton0Press() { //A button 
  if (isLevel) {
    pushForce = -75;
    player.push(0, pushForce);
  }
  else if (isMainMenu) {
    if (menuSelect == 0) {
      reset();
      isLevel = true; 
      isMainMenu = false;
      startTime = millis();

    } 
    else if (menuSelect == 1) {
      isMainMenu = false;
      isInstructions = true;
    } 
    else if (menuSelect == 2) {
      isMainMenu = false;
      isStory = true;
    }
  }
}

void handleButton0Release() { //jumps on release
  if (isLevel) {
    pushForce = 0;
    //  fill(255);
  }
}

void handleButton1Press() { //B button 
  if (isInstructions || isStory || isGameOver)
    reset();
}

void handleButton1Release() { //jumps on release

}

void handleButton5Press() { //RB
if (isLevel){
  boost = true;
  booster = 20;
}
}

void handleButton5Release() { //sets color back to white after release
 if (isLevel){
    boost = false;
  booster = 0;
 }
}

void keyPressed() {
  
  int force = 50; 
  if (isLevel) {
    if (isKeyboard) {
      if (keyCode == LEFT) {
        // boxes[boxCount - 1].push(-50, 0);
        player.push(-force, 0);
      } 
      else if (keyCode == RIGHT) {
        //boxes[boxCount - 1].push(50, 0);
        player.push(force, 0);
      } 
      else if (keyCode == DOWN) {
        player.push(0, force);
      } 
      else if (key == '4') {
        player.push(-force, 0);
      } 
      else if (key == '6') {
        player.push(force, 0);
      } 
      else if (key == '2') {
        player.push(0, force);
      }
    }

    if (isGameOver && keyCode == ENTER) {
      reset();
    }
  }
}

void keyReleased() {
  if (isLevel)
    if (keyCode == UP) {
      player.push(0, -100);
    } 
    else if (key == '8') {
      player.push(0, -100);
    }
}

void mousePressed() {

  if (!isControllerOptions && menuButtons[3].containsMouse()) {
    isInstructions = false;
    isStory = false;
    isMainMenu = true;
  }

  else if (isMainMenu) {
    if (menuButtons[0].containsMouse()) {
      reset();
      isLevel = true;
      isMainMenu = false;
      startTime = millis();
    } 
    else if (menuButtons[1].containsMouse()) {
      isMainMenu = false;
      isInstructions = true;
    } 
    else if (menuButtons[2].containsMouse()) {
      isMainMenu = false;
      isStory = true;
    }
  }
}

void collision(Object userDataA, Object userDataB, float approachVelocity) {

  if (approachVelocity > 0) {
    int midiVelocity = int(approachVelocity) * 4;

    if (midiVelocity > 5) {

      if (userDataA != null) {
        Box boxA = (Box) userDataA;
      }

      if (userDataB != null) {
        Box boxB = (Box) userDataB;
      }
    }
  }
}

void drawStatus(int score) {
  fill(0);
  textAlign(RIGHT);
  text("LIVES: " + lives + "\nLEVEL: " + level + "\nSCORE: " + score, 0, 0);
}

void drawGameOver() {
  isGameOver = true;
  fill(0);
  textAlign(CENTER);
  text("GAME OVER!\nPRESS ENTER", 0, 0);
}

