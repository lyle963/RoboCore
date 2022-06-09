//import processing.serial.*;

//Serial myPort;
//int port=0;
//void SerialSetup() 
//{
//  try {
//    String names[] = Serial.list();
//    String portName = names[port]; 
//    myPort = new Serial(this, portName, 115200);
//  }
//  catch(Exception E) {
//  }
//}
//void send() {
//  String str = "C:"+(int)R2D(angles[1][1])+":"+sendDelay+","+(int)R2D(angles[2][0])+":"+sendDelay+","+(int)R2D(angles[3][0])+":"+sendDelay+",70:"+sendDelay+","+(int)R2D(angles[4][0])+":"+sendDelay+","+(int)R2D(angles[5][0])+":"+sendDelay+"\n";
//  println(str);
//  try {
//    myPort.write("A\n");
//    myPort.write(str);
//  }
//  catch(Exception E) {
//  }
//  sendTime = millis()+2*sendDelay;
//}
//void send(char C) {
//    try {
//  myPort.write(C+"\n");
//    }catch(Exception E) {
//  }
//}
