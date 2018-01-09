// interactiveGameOriginal
// by narumincho 2018/ 1/ 9

// ゲームの概要
//  ニップ
// 操作方法
//  置きたいマスのところをクリック

final int stoneNum = 52;
color[] randomBg = setBgPattern();
PVector[] vertexPosition;
int[] connectionVertex = connectionVertex();

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
    if (putStone(hoverStone)) {
      if (scene == 0) {
        scene = 2;
      } else if (scene == 2) {
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
  final int size = 10;
  color[] colors = new color[size*size];
  for (int i=0; i<size*size; i++) {
    colors[i] = color(random(100, 115), random(142, 157), random(125, 140));
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

int[] connectionVertex() {
  int[] connection = new int[32*2*4+42*2];
  int[] quarter = //32
    { 0, 1
    , 1, 2
    , 2, 3
    , 7, 8
    , 8, 9
    , 9, 4
    , 12, 10
    , 10, 5
    , 11, 6
    , 0, 7
    , 1, 8
    , 2, 9
    , 3, 4
    , 8, 12
    , 9, 10
    , 4, 5
    , 10, 11
    , 5, 6
    , 0, 8
    , 1, 9
    , 2, 4
    , 7, 12
    , 8, 10
    , 9, 5
    , 12, 11
    , 10, 6
    , 1, 7
    , 2, 8
    , 3, 9
    , 9, 12
    , 4, 10
    , 5, 11
  };
  int[] other = //42
    { 26, 0
    ,27, 1
    ,28, 2
    ,29, 3
    ,42,16
    ,41,15
    ,40,14
    ,39,13
    ,32,45
    ,31,44
    ,30,43
    ,29,42
    ,3,16
    ,4,17
    ,5,18
    ,6,19
    ,26,1
    ,27,2
    ,28,3
    ,29,16
    ,42,15
    ,41,14
    ,40,13
    ,27,0
    ,28,1
    ,29,2
    ,42,3
    ,41,16
    ,40,15
    ,39,14
    ,32,44
    ,31,43
    ,30,42
    ,45,31
    ,44,30
    ,43,29
    ,3,17
    ,4,18
    ,5,19
    ,16,4
    ,17,5
    ,18,6
  };
  for(int i=0; i<4; i++){
    for(int j=0; j<32; j++) {
      //from
      connection[i*64 + j*2] = quarter[j*2] + i*stoneNum/4;
      //to
      connection[i*64 + j*2+1] = quarter[j*2+1] + i*stoneNum/4;
    }
  }
  for(int i=0; i<42*2; i++) {
    connection[64*4+i] = other[i];
  }
  return connection;
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
  for (int x=0; x<width/8; x++) {
    for (int y=0; y<height/8; y++) {
      noStroke();
      fill(randomBg[x%10+y%10*10]);
      rect(x*8, y*8, 8, 8);
    }
  }
}

void drawGameboard() {
  stroke(#000000);
  strokeWeight(3);
  for(int i=0; i<connectionVertex.length/2; i++) {
    line(vertexPosition[connectionVertex[i*2]],vertexPosition[connectionVertex[i*2+1]]);    
  }
  textSize(30);
  for (int i=0; i<stoneNum; i++) {
    fill(#aaaaaa);
    circle(vertexPosition[i], 25);
    fill(#ff0000);
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

void line(PVector position0, PVector position1) {
  line(position0.x, position0.y, position1.x, position1.y);
}

float vmin() {
  return min(width, height);
}