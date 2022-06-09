import android.content.Intent;
import android.os.Bundle;

import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

import oscP5.*;

KetaiBluetooth bt;

void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
  println("Creating KetaiBluetooth");
}

void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}

void btSetup(){
  bt.start();
  ArrayList<String> names = bt.getPairedDeviceNames();
  names = bt.getPairedDeviceNames();
  println("Got Names");
  while(!bt.isStarted());
  println("Connecting now");
  bt.connectToDeviceByName("Barry The Arm");
  println("Connected");
  OscMessage m = new OscMessage("A\n");
  bt.broadcast(m.getBytes());
}

void btSend() {
  String str = "C:"+(int)R2D(angles[1][1])+":"+sendDelay+","+(int)R2D(angles[2][0])+":"+sendDelay+","+(int)R2D(angles[3][0])+":"+sendDelay+","+(int)R2D(angles[6][0])+":"+sendDelay+","+(int)R2D(angles[4][0])+":"+sendDelay+","+(int)R2D(angles[5][0])+":"+sendDelay+",\n";
  println(str);
  try {
    //bt.broadcast("A\n".getBytes());
    bt.broadcast(new OscMessage(str).getBytes());
  }
  catch(Exception E) {
  }
  sendTime = millis() + 10*sendDelay;
}
void btSend(char C) {
    try {
  bt.broadcast((C+"\n").getBytes());
    }catch(Exception E) {
  }
}
