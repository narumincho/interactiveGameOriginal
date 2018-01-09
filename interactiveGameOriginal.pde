// interactiveGameOriginal
// by narumincho 2018/ 1/ 9

// ゲームの概要
//  ニップ
// 操作方法
//  置きたいマスのところをクリック

final int stoneNum = 52;
color[] randomBg = setBgPattern();
PVector[] vertexPosition;
int[] stone = new int[stoneNum]; // 0=null 1=白 2=黒
int scene = 0; // 0=白 1=白アニメーション 2=黒 3=黒アニメーション 4=対戦結果
int whiteUser = 0; // 0=人間
int blackUser = 0; // 0=人間
boolean beforeMousePressed = false;

void setup() {
  size(1600, 1200);
  vertexPosition = setVertexPosition();
  for (int i=0; i<stoneNum; i++) {
    stone[i] = 0;
  }
}

void draw() {
  // update
  final int hoverStone = getHoverStone();
  if (scene==0||scene==2) {
    if(putStone(hoverStone)){
      if(scene == 0) {
        scene = 2;
      }else if(scene == 2){
        scene = 0;
      }
    }
  }
  beforeMousePressed = mousePressed;
  // draw
  drawBg();
  drawGameboard();
  drawStone();
  drawHoverStone(hoverStone);
  drawTurnMessage();
}

color[] setBgPattern() {
  final int size = 6;
  color[] colors = new color[size*size];
  for (int i=0; i<size*size; i++) {
    colors[i] = color(random(110, 115), random(152, 157), random(135, 140));
  }
  return colors;
}

PVector[] setVertexPosition() {
  PVector[] position = new PVector[stoneNum];
  PVector[] quarterPosition =
    { vec(35, 5)
    , vec(25, 5)
    , vec(15, 5)
    , vec(5, 5)
    , vec(5, 15)
    , vec(5, 25)
    , vec(5, 35)
    , vec(33, 15)
    , vec(25, 15)
    , vec(15, 15)
    , vec(15, 25)
    , vec(15, 33)
    , vec(25, 25)
  };
  for (int i=0; i<4; i++) {
    for (int j=0; j<13; j++) {
      position[i*13+j] = vec((1-2*(i & 1))*quarterPosition[j].x, (1-2*((i>>1) & 1))*quarterPosition[j].y);
      position[i*13+j].mult(vmin()/3/35).add(width/2, height/2);
    }
  }
  return position;
}

int getHoverStone() {
  if (vmin()/3+90 < vec(mouseX, mouseY).sub(width/2, height/2).mag()) {
    return -1;
  }
  int minIndex = 0;
  float minValue = vec(mouseX, mouseY).sub(vertexPosition[0]).mag();
  for (int i=1; i<stoneNum; i++) {
    final float value = vec(mouseX, mouseY).sub(vertexPosition[i]).mag();
    if (value < minValue) {
      minIndex = i;
      minValue = value;
    }
  }
  return minIndex;
}

boolean putStone(int hoverStone) {
  if (!(!beforeMousePressed && mousePressed)) {
    return false;
  }
  if (hoverStone==-1) {
    return false;
  }
  if (scene==0) {
    stone[hoverStone] = 1;
  } else if (scene==2) {
    stone[hoverStone] = 2;
  }
  return true;
}

void drawBg() {
  for (int x=0; x<width/3; x++) {
    for (int y=0; y<height/3; y++) {
      noStroke();
      fill(randomBg[(x+(y*width/3))%36]);
      rect(x*3, y*3, 3, 3);
    }
  }
}

void drawGameboard() {
  for (int i=0; i<stoneNum; i++) {
    stroke(#000000);
    strokeWeight(3);
    fill(#aaaaaa);
    circle(vertexPosition[i], 25);
    fill(#ff0000);
    textSize(30);
    text(str(i), vertexPosition[i]);
  }
}

void drawStone() {
  for (int i=0; i<stoneNum; i++) {
    if (stone[i]==0) {
      continue;
    }
    if (stone[i] == 1) {
      fill(#ffffff);
      stroke(#000000);
    } else if (stone[i] == 2) {
      fill(#000000);
      stroke(#ffffff);
    }
    strokeWeight(5);
    circle(vertexPosition[i], 40);
  }
}

void drawHoverStone(int hoverStone) {
  if (hoverStone == -1) {
    return;
  }
  noStroke();
  fill(#00ff00, 100);
  circle(vertexPosition[hoverStone], 50);
}

void drawTurnMessage() {
  fill(#ffffff);
  textAlign(LEFT, TOP);
  if (scene == 0) {
    text("white", 0, 0);
  } else if (scene == 2) {
    text("black", 0, 0);
  }
}

PVector vec(float x, float y) {
  return new PVector(x, y);
}

void circle(PVector position, float radious) {
  ellipse(position.x, position.y, radious*2, radious*2);
}

void text(String disc, PVector position) {
  text(disc, position.x, position.y);
}

float vmin() {
  return min(width, height);
}