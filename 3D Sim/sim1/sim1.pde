import android.view.WindowManager;

///Environment Variables
PShape segments[] = new PShape[5];//base, shoulder, upArm, loArm, end;
int colours[] = {#3A3A3A, #5F4328, #FFE308, #FFE308, #FFE308};
float angles[][] = {{0, 0}, {0, 0.0}, {D2R(70), PI}, {D2R(80), PI}, {D2R(80), PI}, {D2R(0), PI}, {D2R(0), PI}};
float offsets[] = {0, D2R(110), D2R(155), D2R(-80), D2R(-80)};
float scalers[] = {1, 1, 1.2, 1.1, -1};
int positions[][] = {{0, -40, 0}, {0, 4, 0}, {0, 25, 0}, {0, 0, 50}, {0, 0, -50}};
int segmentSelect = 0;
float rotX, rotY;
float posX=20, posY=50, posZ=50;
float size = -2.5;
long sendTime = 0;
long sendDelay = 150;
PImage img[] = new PImage[7];

void setup() {
  fullScreen(OPENGL);
  orientation(LANDSCAPE);
  runOnUiThread(new Runnable() {
    @Override
      public void run() {
      getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
  }
  );
  background(32);
  smooth();
  lights();
  img[0] = loadImage("logo.jpg");
  img[1] = loadImage("up.jpg");
  img[2] = loadImage("down.jpg");
  img[3] = loadImage("clock.jpg");
  img[4] = loadImage("anticlock.jpg");
  img[5] = loadImage("open.jpg");
  img[6] = loadImage("close.jpg");

  image(img[0], 0, 0, width, height);
  initPositions();
  segments[0] = loadShape("r5.obj");
  segments[1] = loadShape("r1.obj");
  segments[2] = loadShape("r2.obj");
  segments[3] = loadShape("r3.obj");
  segments[4] = loadShape("r4.obj");
  segments[0].disableStyle();
  segments[1].disableStyle();
  segments[2].disableStyle();
  segments[3].disableStyle();
  segments[4].disableStyle();
  //SerialSetup();
  btSetup();
}

void draw() { 
  //writePos()

  background(32);
  smooth();
  lights(); 
  directionalLight(51, 102, 126, -1, 0, 0);
  noStroke();
  noFill();
  drawImages();
  translate(width/2, height/2+100);
  rotateX(rotX);
  rotateY(-rotY);
  scale(size);

  fill(color(100, 100, 100));
  box(300, 2, 100);
  translate(-100, 66, 10);
  fill(color(50, 50, 1));
  pushMatrix();
  for (int i=0; i<5; i++) {
    translate(positions[i][0], positions[i][1], positions[i][2]);
    if (i == segmentSelect && i > 0) fill(#FF3300); 
    else fill(colours[i]);
    angles[i][0] = Norm(angles[i][0]);
    angles[i][1] = Norm(angles[i][1]);
    rotateY(offset(angles[i][1], i, 'Y'));
    rotateX(offset(angles[i][0], i, 'X'));
    shape(segments[i]);
  }
  popMatrix();
  //translate(posX,posY,posZ);
  //fill(color(50, 50, 150));
  //box(15, 3, 35);
  //move();
  if (segmentSelect == 0)
    ;//IK();
  else {
    if (millis()>sendTime)
      btSend();
  }
  //text("Gripper Angle:"+angles[5][0], 78, 80);
}

void mousePressed() {
  //if (mouseY<height/3) {
  //  if (segmentSelect<4)
  //    segmentSelect++;
  //} else if (mouseY>2*height/3) {
  //  if (segmentSelect>0)
  //    segmentSelect--;
  //}
  int MouseX = mouseX;
  int MouseY = mouseY;
  if (checkImageClick(1, MouseX, MouseY)) {
    if (segmentSelect<4)
      segmentSelect++;
    println("Clicked 1");
  } else if (checkImageClick(2, MouseX, MouseY)) {
    if (segmentSelect>0)
      segmentSelect--;
    println("Clicked 2");
  } else if (checkImageClick(4, MouseX, MouseY)) {
    if (angles[6][0]+D2R(10)>= 0 && angles[6][0]+D2R(10) <= D2R(180))
      angles[6][0]+=D2R(10);
    println("Clicked 3"+angles[6][0]);
  } else if (checkImageClick(3, MouseX, MouseY)) {
    if (angles[6][0]-D2R(10)>= 0 && angles[6][0]-D2R(10) <= D2R(180))
      angles[6][0]-=D2R(10);
    println("Clicked 4"+angles[6][0]);
  } else if (checkImageClick(5, MouseX, MouseY)) {
    if (angles[5][0]+D2R(10)>= 0 && angles[5][0]+D2R(10) <= D2R(180))
      angles[5][0]+=D2R(10);
    println("Clicked 5"+angles[5][0]);
  } else if (checkImageClick(6, MouseX, MouseY)) {
    if (angles[5][0]-D2R(10)>= 0 && angles[5][0]-D2R(10) <= D2R(180))
      angles[5][0]-=D2R(10);
    println("Clicked 6"+angles[5][0]);
  }
  //send();
  //btSend();
}

void mouseDragged() {
  rotY -= (mouseX - pmouseX) * 0.01;
  //rotX -= (mouseY - pmouseY) * 0.01;
  applyMouseAngle();
}

void keyPressed() {
  if (key == CODED) {
  } else {
    switch(key) {
    case 'Q': 
      println("Prev");
      if (segmentSelect>0)segmentSelect--;
      break;
    case '=':
      //if(angles[5][0])
      angles[5][0]=1;
      break;
    case '-':
      angles[5][0]=0.1;
      break;
    case '.' :
      println("Next");
      segmentSelect++;
      if (segmentSelect>=5) segmentSelect=0;
      break;
    case ENTER :
      print("ENTER");
      segmentSelect=0;
      break;
    default:
      //send(key);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  angles[5][0]+= e/10;
  //segmentSelect -= e;
  //if (segmentSelect>=5 || segmentSelect < 0) segmentSelect=0;
}

void applyMouseAngle() {
  //if (mousePressed) return;
  float newAngle;
  if (segmentSelect==1) {
    newAngle = -(float)(mouseX - pmouseX) * 0.01;
    if (angles[segmentSelect][1]+newAngle>= 0 && angles[segmentSelect][1]+newAngle <= D2R(180)) {
      angles[segmentSelect][1]+=newAngle;
    }
  } else if (segmentSelect == 2) {
    newAngle = (float)(mouseY - pmouseY) * 0.01;
    if (angles[segmentSelect][0]+newAngle>= D2R(10) && angles[segmentSelect][0]+newAngle <= D2R(140)) {
      angles[segmentSelect][0]+=newAngle;
    }
  } else if (segmentSelect == 3 || segmentSelect == 4) {
    newAngle = -(float)(mouseY - pmouseY) * 0.01;
    if (angles[segmentSelect][0]+newAngle>= D2R(10) && angles[segmentSelect][0]+newAngle <= D2R(170)) {
      angles[segmentSelect][0]+=newAngle;
    }
  }
  //else if (segmentSelect == 3 && angles[segmentSelect][0]+newAngle>= D2R(0) && angles[segmentSelect][0]+newAngle <= D2R(180)) {
  //  println((angles[segmentSelect][0]+newAngle )*180/PI);
  //  angles[segmentSelect][0]+=newAngle;
  //}
}

float Norm(float angle) {//normalise and offset
  while (angle*180/PI >= 360)
    angle -= 6.28318;
  while (angle*180/PI < 0)
    angle += 6.28318;
  return angle;
}

float offset(float angle, int Segment, char axis) {
  if (Segment==1 && axis == 'Y') {
    //print("\t\t\t"+angle*180/PI+"->");
    angle+=offsets[Segment];
    angle = Norm(angle);
    angle*=scalers[Segment];
  } else if (Segment >= 2 && axis == 'X') {
    //print("\t\t\t"+angle*180/PI+"->");
    angle+=offsets[Segment];
    angle*=scalers[Segment];
    //println(angle*180/PI);
  }
  return angle;
}

float D2R(float m) {
  return m*PI/180;
}
float R2D(float m) {
  return m*180/PI;
}
