float F = 50;
float T = 70;
float millisOld, gTime, gSpeed = 4;

void IK(){
  float X = posX;
  float Y = posY;
  float Z = posZ;

  float L = sqrt(Y*Y+X*X);
  float dia = sqrt(Z*Z+L*L);

  angles[1][1] = PI/2-(atan2(L, Z)+acos((T*T-F*F-dia*dia)/(-2*F*dia)));
  angles[2][0] = -PI+acos((dia*dia-T*T-F*F)/(-2*F*T));
  angles[3][0] = atan2(Y, X);
}

void setTime(){
  gTime += ((float)millis()/1000 - millisOld)*(gSpeed/4);
  if(gTime >= 4)  gTime = 0;  
  millisOld = (float)millis()/1000;
}

void writePos(){
  IK();
  setTime();
  posX = sin(gTime*PI/2)*20;
  posZ = sin(gTime*PI)*10;
}
;
