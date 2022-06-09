public class position {
  position(){
    X = 0;
    Y = 0;
    width = 0;
    height = 0;
  }
  int X,Y,width,height;
};

position images[] = new position[7];

void initPositions() {
  for (int i=1; i<7; i++) {
    images[i]=new position();
    images[i].width = 200;
    images[i].height = 200;
  }
  images[1].X = 110;
  images[1].Y = 10;
  images[4].X = 10;
  images[4].Y = 220;
  images[3].X = 220;
  images[3].Y = 220;
  images[2].X = 110;
  images[2].Y = 430;
  images[5].X = width-210;
  images[5].Y = (height/2) +105;
  images[6].X = width-210;
  images[6].Y = (height/2) -105;
}
void drawImages() {
  for (int i=1; i<7; i++)
    image(img[i], images[i].X, images[i].Y, images[i].width, images[i].height);
}

boolean checkImageClick(int imageNo,int MouseX,int MouseY){
  if(MouseX > images[imageNo].X && MouseX < images[imageNo].X+images[imageNo].width)
    if(MouseY > images[imageNo].Y && MouseY < images[imageNo].Y+images[imageNo].height)
      return true;
  return false;
}
