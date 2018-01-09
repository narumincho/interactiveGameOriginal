// interactiveGameOriginal
// by narumincho 2018/ 1/ 9

// ゲームの概要
//  丸型リバーシのニップ
//  相手の石を挟んでひっくり返せ。縦横ななめ、円周上も
//  最後の1つで大逆転
// 操作方法
//  置きたいマスのところをクリック

final int stoneNum = 52;
color[] randomBg = setBgPattern();
PVector[] vertexPosition;
int[] connectionVertex = setConnectionVertex();

int[] stone = new int[stoneNum]; // 0=null 1=白 2=黒
int[] undoRedoLocation = new int[stoneNum];

int scene = 0; // 0=白 1=白アニメーション 2=黒 3=黒アニメーション 4=対戦結果
int whiteUser = 0; // 0=人間
int blackUser = 0; // 0=人間
boolean beforeMousePressed = false;
int annimationType; //0=ひっくり返す 1=Pass
int animationCount = -1;
int cauPutAnim = 0;
int passCount = 0;
void setup() {
  size(1600, 1200);
  vertexPosition = setVertexPosition();
  for (int i=0; i<stoneNum; i++) {
    stone[i] = 0;
  }
  stone[29]=1;
  stone[16]=1;
  stone[ 3]=2;
  stone[42]=2;
}

void draw() {
  // update
  int[] canPutLocations = null;
  int hoverStone = -1;
  if (scene==0 || scene==2) {
    canPutLocations = getCanPutLocations();
    if (canPutLocations.length==0) {
      scene += 1;
      animationCount = 60;
      annimationType = 1;
      passCount = (passCount + 1);
      if(1<passCount || 0==countStone(0)){
        scene = 4;
      }
    } else {
      passCount = 0;
      cauPutAnim = (cauPutAnim + 1) % 60;
      hoverStone = getHoverStone(canPutLocations);
      if (hoverStone!=-1) {
        updateStone(hoverStone);
      }
    }
  } else {
    animationCount -= 1;
    if (animationCount<0) {
      scene = (scene + 1)%4;
      return;
    }
  }
  beforeMousePressed = mousePressed;
  // draw
  drawBg();
  drawGameboard();
  drawStone();
  if (scene==0 || scene==2) {
    drawCanPut(canPutLocations);
    drawHoverStone(hoverStone);
  }
  drawTurnMessage();
  drawPassMessage();
  drawResultMessage();
}

int countStone(int stoneType) {
  int count = 0;
  for(int i=0;i<stoneNum;i++){
    if(stone[i]==stoneType){
      count += 1;
    }
  }
  return count;
}

void updateStone(int hoverStone) {
  if (scene==0||scene==2) {
    if (putStone(hoverStone)) {
      turnStones(hoverStone);
      if (scene == 0) {
        scene = 2;
      } else if (scene == 2) {
        scene = 0;
      }
    }
  }
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

int[] setConnectionVertex() {
  int[] connection = new int[32*2*4+42*2];
  int[] quarter = //32
  { 
    0, 1
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
  { 
    26, 0
      , 27, 1
      , 28, 2
      , 29, 3
      , 42, 16
      , 41, 15
      , 40, 14
      , 39, 13
      , 32, 45
      , 31, 44
      , 30, 43
      , 29, 42
      , 3, 16
      , 4, 17
      , 5, 18
      , 6, 19
      , 26, 1
      , 27, 2
      , 28, 3
      , 29, 16
      , 42, 15
      , 41, 14
      , 40, 13
      , 27, 0
      , 28, 1
      , 29, 2
      , 42, 3
      , 41, 16
      , 40, 15
      , 39, 14
      , 32, 44
      , 31, 43
      , 30, 42
      , 45, 31
      , 44, 30
      , 43, 29
      , 3, 17
      , 4, 18
      , 5, 19
      , 16, 4
      , 17, 5
      , 18, 6
  };
  for (int i=0; i<4; i++) {
    for (int j=0; j<32; j++) {
      //from
      connection[i*64 + j*2] = quarter[j*2] + i*stoneNum/4;
      //to
      connection[i*64 + j*2+1] = quarter[j*2+1] + i*stoneNum/4;
    }
  }
  for (int i=0; i<42*2; i++) {
    connection[64*4+i] = other[i];
  }
  return connection;
}
int[][][] getInterjectLinesStones() {
  return new int[][][]{
    { //0
      {26, 33, 38, 37, 32, 45, 50, 51, 46, 39, 13, 20, 25, 24, 19, 6, 11, 12, 7, 0}, 
      {27, 35, 31, 45}, 
      {1, 2, 3, 16, 15, 14, 13}, 
      {8, 10, 6}, 
      {7, 12, 11, 6, 19, 24, 25, 20, 13, 39, 46, 51, 50, 45, 32, 37, 38, 33, 26, 0}
    }, 
    { //1
      {27, 34, 38}, 
      {28, 30, 44, 50}, 
      {2, 3, 16, 15, 14, 13}, 
      {9, 5, 19}, 
      {8, 12}
    }, 
    { //2
      {1, 0}, 
      {27, 33}, 
      {28, 35, 36, 37}, 
      {29, 43, 49}, 
      {3, 16, 15, 14, 13}, 
      {4, 18, 24}, 
      {9, 10, 11}
    }, //3
    {
    }
    , 
    { //4
      {9, 8, 7}, 
      {2, 27, 33}, 
      {3, 29, 30, 31, 32}, 
      {16, 41, 47}, 
      {17, 22, 21, 20}, 
      {18, 24}, 
      {5, 6}, 
    }, 
    { //5
      {10, 12}, 
      {9, 1, 26}, 
      {4, 3, 29, 30, 31, 32}, 
      {17, 15, 40, 46}, 
      {18, 23, 25}
    }, 
    { //6
      {11, 12, 7, 0, 26, 33, 38, 37, 32, 45, 50, 51, 46, 39, 13, 20, 25, 24, 19, 6}, 
      {10, 8, 0}, 
      {5, 4, 3, 29, 30, 31, 32}, 
      {18, 22, 14, 39}, 
      {19, 24, 25, 20, 13, 39, 46, 51, 50, 45, 32, 37, 38, 33, 26, 0, 7, 12, 11, 6}
    }, 
    { //7
      {0, 26, 33, 38, 37, 32, 45, 50, 51, 46, 39, 13, 20, 25, 24, 19, 6, 11, 12, 7}, 
      {1, 28, 30, 44, 50}, 
      {8, 9, 4, 17, 22, 21, 20}, 
      {12, 11, 6, 19, 24, 25, 20, 13, 39, 46, 51, 50, 45, 32, 37, 38, 33, 26, 0, 7}
    }, 
    { //8
      {1, 27, 34, 38}, 
      {2, 29, 43, 49}, 
      {9, 4, 17, 22, 21, 20}, 
      {10, 6}
    }, 
    { //9
      {8, 7}, 
      {1, 26}, 
      {2, 28, 35, 36, 37}, 
      {3, 42, 48, 51}, 
      {4, 17, 22, 21, 20}, 
      {5, 19}, 
      {10, 11}
    }, 
    { //10
      {8, 0}, 
      {9, 2, 28, 35, 36, 37}, 
      {4, 16, 41, 47}, 
      {5, 18, 23, 25}
    }, 
    { //11
      {12, 7, 0, 26, 33, 38, 37, 32, 45, 50, 51, 46, 39, 13, 20, 25, 24, 19, 6, 11}, 
      {10, 9, 2, 28, 35, 36, 37}, 
      {5, 17, 15, 40, 46}, 
      {6, 19, 24, 25, 20, 13, 39, 46, 51, 50, 45, 32, 37, 38, 33, 26, 0, 7, 12, 11}
    }, 
    { //13
      {7, 0, 26, 33, 38, 37, 32, 45, 50, 51, 46, 39, 13, 20, 25, 24, 19, 6, 11, 12}, 
      {8, 1, 27, 34, 38}, 
      {9, 3, 42, 48, 51}, 
      {10, 5, 18, 23, 25}, 
      {11, 6, 19, 24, 25, 20, 13, 39, 46, 51, 50, 45, 32, 37, 38, 33, 26, 0, 7, 12}
    }
  };
}

int getHoverStone(int[] canPutLocation) {
  if (vmin()/3+90 < vec(mouseX, mouseY).sub(width/2, height/2).mag()) {
    return -1;
  }
  int minIndex = canPutLocation[0];
  float minValue = vec(mouseX, mouseY).sub(vertexPosition[canPutLocation[0]]).mag();
  for (int i=1; i<canPutLocation.length; i++) {
    final float value = vec(mouseX, mouseY).sub(vertexPosition[canPutLocation[i]]).mag();
    if (value < minValue) {
      minIndex = canPutLocation[i];
      minValue = value;
    }
  }
  return minIndex;
}

int[][] getInterjectLine(int pos) {
  int offset = pos / (stoneNum/4);
  int[][] lines = getInterjectLinesStones()[pos % (stoneNum/4)];
  for (int i=0; i<lines.length; i++) {
    for (int j=0; j<lines[i].length; j++) {
      if (offset==0||offset==2) {
        lines[i][j]=(lines[i][j]+offset*stoneNum/4)%stoneNum;
      } else {
        if ((lines[i][j]/(stoneNum/4)) % 2 == 1) {
          lines[i][j]=(lines[i][j]+offset*stoneNum/4+stoneNum/2)%stoneNum;
        } else {
          lines[i][j]=(lines[i][j]+offset*stoneNum/4)%stoneNum;
        }
      }
    }
  }
  return lines;
}

int[] getCanPutLocations() {
  ArrayList<Integer> canPutLocations = new ArrayList<Integer>();
  for (int i=0; i<stoneNum; i++) {
    if (stone[i]!=0) {
      continue;
    }
    if (canPut(i)) {
      canPutLocations.add(i);
    }
  }
  int[] result = new int[canPutLocations.size()];
  for (int i=0; i<result.length; i++) {
    result[i] = canPutLocations.get(i);
  }
  return result;
}

boolean canPut(int pos) {
  final int[][] lines = getInterjectLine(pos);
  for (int i=0; i<lines.length; i++) {
    if(canPutLine(lines[i])){
      return true;
    }
  }
  return false;
}

boolean canPutLine(int[] line) {
  final int same = (scene==0)? 1:2;
  for (int i=0; i<line.length; i++) {
    if (stone[line[i]]==0 ) {
      return false;
    }
    if (i==0 && stone[line[i]]==same) {
      return false;
    }
    if (0<i && stone[line[i]]==same) {
      return true;
    }
  }
  return false;
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

void turnStones(int pos) {
  final int same = (scene==0)? 1:2;
  final int diff = (scene==0)? 2:1;
  int[][] lines = getInterjectLine(pos);
  for(int i=0; i<lines.length; i++) {
    if (canPutLine(lines[i])) {
      for(int j=0; j<lines[i].length; j++){
        if(stone[lines[i][j]]!=diff) {
          break;
        }
        stone[lines[i][j]] = same;
      }
    }
  }
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
  for (int i=0; i<connectionVertex.length/2; i++) {
    line(vertexPosition[connectionVertex[i*2]], vertexPosition[connectionVertex[i*2+1]]);
  }
  textSize(30);
  for (int i=0; i<stoneNum; i++) {
    fill(110, 152, 135);
    circle(vertexPosition[i], 25);
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
  stroke(#ff9800);
  fill(stoneColor(nowStone()), 100);
  circle(vertexPosition[hoverStone], 50);
}

void drawCanPut(int[] pos) {
  for (int i=0; i<pos.length; i++) {
    colorMode(HSB, 360, 100, 100);
    fill(i*360/pos.length, 100, 100, 30+((30<=cauPutAnim)?60-cauPutAnim:cauPutAnim)*4);
    colorMode(RGB, 256, 256, 256);
    noStroke();
    circle(vertexPosition[pos[i]], 50);
  }
}


void drawTurnMessage() {
  textAlign(LEFT, TOP);
  if (scene == 0) {
    fill(stoneColor(nowStone()));
    text("white", 0, 0);
  } else if(scene == 1) {
    fill(stoneColor(nowStone()));
    text("white anim", 0, 0);    
  }else if (scene == 2) {
    fill(stoneColor(nowStone()));
    text("black", 0, 0);
  }else if (scene == 3) {
    fill(stoneColor(nowStone()));
    text("black anim", 0, 0);
  }
}

void drawPassMessage() {
  if(!(annimationType==1&&animationCount!=-1&&(scene==1||scene==3))){
    return;
  }
  fill(#ffffff);
  textAlign(CENTER, CENTER);
  textSize(60);
  text("-PASS-",width*(60-animationCount)/60,height/2);
}

void drawResultMessage() {
  if(scene!=4){
    return;
  }
  textAlign(CENTER, CENTER);
  textSize(120);
  final int whiteNum = countStone(1);
  final int blackNum = countStone(2);
  String msg = "";
  if(blackNum < whiteNum){
    msg = "white win";
  }else if(whiteNum < blackNum){
    msg = "black win";
  }else{
    msg = "draw";
  }
  fill(#FFaa22);
  text(msg, width/2, height/2 + 5);  
  fill(#FF9800);
  text(msg, width/2, height/2);  
  textSize(60);
  text(str(whiteNum)+"-"+str(blackNum),width/2, height/2+100);
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

int nowStone() {
  return (scene<=1)? 1:2;
}

color stoneColor(int stone) {
  return (stone==1)? #ffffff: #000000;
}