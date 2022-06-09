#include <Servo.h>
#define Serial1 Serial
#include <SoftwareSerial.h>
class Motor{
  public:
    Motor(){
          setAngle(0);
          setDelay(0);
          joyPin = 0;
          servoPin = 0;
          replayActive = 0;
          maxPotVal = 0;
          minPotVal = 1000;
          isUpToDate = 0;
          for (int thisReading = 0; thisReading < numReadings; thisReading++) 
            readings[thisReading] = 0;
    }
    void initAngle(byte A){
          angle = newAngle = A;
    }
    void setAngle(float A){// set angle to go to
          newAngle =  A;
    }
    float getAngle(){// set angle currently
          return angle;
    }
    void setDelay(unsigned int delayTime){// set How long to take to reach that angle (milliseconds)
          if(delayTime==0) motorSpeed = 0;
          else motorSpeed = (float)abs(angle - newAngle)/(float)(delayTime); //Degrees/millisecond
    }
    float getSpeed(){// see angle to increment
          return motorSpeed;
    }
    void arm(byte pin,byte joystickPin){//// set pins
          servo.attach(pin);
          joyPin = joystickPin;
          servoPin = pin;
    }
    void arm(){
          servo.attach(servoPin);
    }
    void disarm(){// loosen motor
          servo.detach();
    }
    void replay(bool active){
      replayActive = active;
    }
    void update(){//update values every {1} milliseconds, 
          if(motorSpeed == 0){
            angle=newAngle;
          }else{
            if(newAngle>angle){
              angle+=motorSpeed;
            }else if(angle>newAngle){
              angle-=motorSpeed;
            }
          }
          if(angle > 0 || angle <= 180)
            servo.write(angle);
          if(replayActive) checkPot();
          // Serial.println("\t"+String(abs(angle-newAngle)));
          if(abs(angle-newAngle) < 2)
            isUpToDate = 1;
          else isUpToDate = 0;
    }
    void checkPot(){
      byte val = smooth(joyPin);      
      if(val > maxPotVal) maxPotVal = val;
      if(val < minPotVal) minPotVal = val;
      int destAngle = map(val, 40, 220, 180, 0);
      if(destAngle <= 180 && destAngle >= 0){
        setAngle(destAngle);
        setDelay(700);
      }
    }
    byte smooth(byte pin){
      byte val = (analogRead(pin) / 4);
      total = total - readings[readIndex];
      readings[readIndex] = val;
      total = total + readings[readIndex];
      readIndex = readIndex + 1;
      if (readIndex >= numReadings)
        readIndex = 0;
      average = total / numReadings;
      return average;
    }
    bool isUpToDate;
  private:
    float angle;
    float newAngle;
    Servo servo;
    float motorSpeed;
    byte joyPin;
    byte servoPin;
    bool replayActive;
    byte maxPotVal;
    byte minPotVal;
      byte numReadings = 15;
      byte readings[15];      // the readings from the analog input
      byte readIndex = 0;              // the index of the current reading
      int total = 0;                  // the running total
      byte average = 0;                // the average
};

class Robo{
  private:
    byte noOfMotors;
    bool armed;
    unsigned long MotorUpdateTimer;
  public:
    Motor* Motors = new Motor;

    Robo(int NoOfMotors){
      const int N = NoOfMotors;
      noOfMotors = N;
      Motors = new Motor[N];
      armed = 0;
      MotorUpdateTimer= 0;
    }
    void command(byte* angles,unsigned int duration,unsigned int delayTime){// take a list of angles, take time required to complete it. Excectute.
      Serial.print("[");
      for(int i=0;i<noOfMotors;i++){
        Motors[i].setAngle(angles[i]);
        Motors[i].setDelay(duration);
      }
      unsigned long localTimer = millis()+duration+delayTime;//Give the robot extra 500ms to complete the Job
      while(millis()<localTimer){
        update();
        if(micros()%1000000<100)Serial.print(".");
      }
      for(int i=0;i<noOfMotors;i++){
        Motors[i].setDelay(0);
      }
      Serial.print("]");
      while(getUpdateCount()<6){
        update();//wait for motors to finish
        Serial.println(String(getUpdateCount()));
      }
      Serial.println("");
    }
    void attach(byte* ServoPin,byte* joystickPin) {
      for(int i=0;i<noOfMotors;i++){
        Motors[i].arm(ServoPin[i],joystickPin[i]);
      }
      armed = 1;
      Serial.println("ARMED");
    }
    void attach(){
      for(int i=0;i<noOfMotors;i++){
        Motors[i].arm();
      }
      armed = 1;
      Serial.println("ARMED");
    }
    int getUpdateCount(){// returns 0 - 6 depending on how many motors have reached location
      byte updateCount = 0;
      for(int i=0;i<noOfMotors;i++){
        if(Motors[i].isUpToDate)
          updateCount++;
      }
      return updateCount;
    }
    void detach() {
      for (int i = 0; i < noOfMotors; i++)
        Motors[i].disarm();
      armed = 0;
      Serial.println("DISARMED");
    }
    void init(byte* angles){
      for(int i=0;i<noOfMotors;i++){
        Motors[i].initAngle(angles[i]);
      }
    }
    void update(){
      unsigned long now = micros();
      if(now>MotorUpdateTimer){
        byte missed = (now%100000)/1000-(MotorUpdateTimer%100000)/1000 + 1; //no of updates to be made based on millis skipped
        for (int i = 0; i < noOfMotors; i++){
          for(int j=0;j<missed;j++){
            Motors[i].update();
          }
        }
        MotorUpdateTimer=now+1000;
      }
    }
    void replay(bool active){
      for(int i=0;i<noOfMotors;i++){
        Motors[i].replay(active);
      }
    }
};
// END OF LIBRARY





//########  CODE GOES HERE  #############

#define MOTORCOUNT 6

Robo Robot(MOTORCOUNT);
// SoftwareSerial Serial1(2,4);
void setup() {
  // Serial.begin(9600);
  Serial1.begin(115200);
  wake();
}

void loop() {
  getSerial();
  Robot.update();
}




void wake(){
  byte ServoPins[] = {3,5,6,9,10,11};
  byte JoyPins[] = {A0,A1,A2,A3,A4,A5};
  byte initAngles[] = {75,90,180,70,170,0};
  Robot.attach(ServoPins,JoyPins);
  Robot.init(initAngles);
  // ready();
  // stretch();
  sleep();
}
void sleep(){
  byte angles[] = {75,90,180,70,170,0};
  Serial1.println("RUNNING:Sleep");
  Robot.command(angles,1500,50);
  Serial1.println("COMPLETED:Sleep");
}
void stretch(){
  byte angles[] = {90,70,80,70,80,0};
  Serial1.println("RUNNING:Stretch");
  Robot.command(angles,3000,50);
  Serial1.println( "COMPLETED:Stretch");
}
void ready(){
  byte angles[] = {0,120,180,80,110,30};
  Serial1.println("RUNNING:Ready");
  Robot.command(angles,1500,50);
  Serial1.println("COMPLETED:Ready");
}

void replay(){
  Robot.replay(1);
  digitalWrite(A5,1);
  Robot.Motors[3].replay(0);
}





























// Accept a String with all angles Eg: A:90,45,45,90,180,180,
String InputBuffer = "";
void getSerial(){  
  int success = -1;
  while (Serial1.available()) {//Append chars to the string
      char c =Serial1.read();
      if(c==10 || c==13 || c==' ' || c == 0)
        c = ' ';
      InputBuffer += c;
      delay(1);
      success = 0;
  }

  if (Robot.getUpdateCount()==6);
  else return; 

    String CMD ="";
    for(int i=0;i<InputBuffer.length();i++){
      char c = InputBuffer[i];
      if(c!=' ') CMD += InputBuffer[i];  
    }
    if(CMD != ""){
      Serial1.println("Input Buffer:");
      success = 0;
    }
    else return;
    if(CMD[0]==',') CMD = CMD.substring(1,CMD.length());
    Serial1.println(CMD);
    String val = "";//initialise value
    byte motorCount = 0;//iterate thru string
    switch(CMD[0]){
      case 'D': Robot.detach();
                Robot.replay(0);
                success = 1;
                InputBuffer = CMD.substring(1,CMD.length());
                break;
      case 'S': sleep();
                success = 1;
                InputBuffer = CMD.substring(1,CMD.length());
                break;
      case 'R': replay();
                success = 1;
                InputBuffer = CMD.substring(1,CMD.length());
                break;
      case 'W': wake();
                success = 1;
                InputBuffer = CMD.substring(1,CMD.length());
                break;
      case 'A': Robot.attach();
                if(CMD[1]==":"){
                  for (int i = 2; i < CMD.length(); i++) {
                    //Check for comma / NL / CR
                    if (CMD[i] == ',') {
                      //Save value
                      Robot.Motors[motorCount].setAngle(val.toFloat());
                      Robot.Motors[motorCount].setDelay(0);
                      motorCount++;
                      if (motorCount == MOTORCOUNT) {
                        success = 1;
                        InputBuffer = CMD.substring(1,CMD.length());
                        return;
                      }
                      //Reset Value
                      val = "";

                    }//Else append new character
                    else val += CMD[i];
                  }
                }
                break;
      case 'C':
                if (CMD[1] == ':') {
                  for (int i = 2; i < CMD.length(); i++) {
                    //Check for comma / NL / CR
                    if (CMD[i] == ':') {
                      Robot.Motors[motorCount].setAngle(val.toFloat());//save
                      Serial1.println("Motor["+String(motorCount)+"]="+String(val));
                      motorCount++;//next motor
                      val = "";//reset
                    }//Else append new character
                    else if (CMD[i] == ',') {
                      Robot.Motors[motorCount-1].setDelay(val.toInt());
                      Serial1.println("Motor["+String(motorCount-1)+"] Time="+String(val));
                      val = "";
                      if (motorCount == MOTORCOUNT) {
                        Serial1.println("Whats left:");
                        Serial1.println(CMD.substring(i+1,CMD.length()));
                        InputBuffer = CMD.substring(i+1,CMD.length());
                        success = 1;
                        return;
                      }
                    } else val += CMD[i];
                  }
                }
                break;
    }
    if(success==0){
      Serial1.println("\t\t\tBAD COMMAND. Moving to next in Queue");
      InputBuffer = CMD.substring(1,CMD.length());
    }
  // }
}
