/*
  send 64 bytes: 8 bytes for each 8 output streams, one color needs 3 bytes    
  
  Example buffer to send out:  
  11111111 00000000 11111111 00000000 11111111 11111111 11111111 00000000 (8 Bytes)
  11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111 (8 Bytes)
  00000001 00000011 00000111 00001111 00011111 00111111 01111111 11111111 (8 Bytes)
  ...
  
  this get transfered into:
  D0: 10101110 11111111 00000001 ...
  D1: 10101110 11111111 00000011
  D2: 10101110 11111111 00000111
  D3: 10101110 11111111 00001111
  D4: 10101110 11111111 00011111
  D5: 10101110 11111111 00111111
  D6: 10101110 11111111 01111111
  D7: 10101110 11111111 11111111
  
  
  Example backwards, I want the first pixel on all leds in color purple:
  D0: 11111111 00000000 11111111
  D1: 11111111 00000000 11111111
  D2: 11111111 00000000 11111111
  D3: 11111111 00000000 11111111
  D4: 11111111 00000000 11111111
  D5: 11111111 00000000 11111111
  D6: 11111111 00000000 11111111
  D7: 11111111 00000000 11111111
  
  Example buffer to send out:
  11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111  |  0x255 0x255 0x255 0x255 0x255 0x255 0x255 0x255 
  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000  |  0x000 0x000 0x000 0x000 0x000 0x000 0x000 0x000
  11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111  |  0x255 0x255 0x255 0x255 0x255 0x255 0x255 0x255 
  
  
  
  Another Example backwards
  D0: 11100001 00000000 11111111
  D1: 00000000 00000000 00000000
  D2: 00000000 00000000 00000000
  D3: 00000000 00000000 00000000
  D4: 00000000 00000000 00000000
  D5: 00000000 00000000 00000000
  D6: 00000000 00000000 00000000
  D7: 00000000 00000000 00000000

  Example buffer to send out:
  10000000 10000000 10000000 00000000 00000000 00000000 00000000 00000000  |  0x128 0x128 0x128 0x000 0x000 0x000 0x000 0x000 
  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000  |  0x000 0x000 0x000 0x000 0x000 0x000 0x000 0x000
  10000000 10000000 10000000 10000000 10000000 10000000 10000000 10000000  |  0x128 0x128 0x128 0x128 0x128 0x128 0x128 0x128 

  Conclusion:
  -to set 1 pixel on each line, i need to send out 24 bytes
  -send out 3x64 bytes to update 8 pixels on each line
*/   

SerialSend srl;

//buffer
int[] gammaTab;

boolean initialized = false;

/////////////
void setup() {
  frameRate(1850);

  try {
    srl = new SerialSend(this, "/dev/tty.usbmodem12341", 50);          
    this.initialized=true;
    println("Ping result: "+ this.initialized);    
    
    gammaTab = generateGammaTab(2.5);
  } catch (Exception e) {
    println("failed");
    e.printStackTrace();
  }
  
}

int pos=0;
//set random colors
void fxWheel(int delayTime) {  
  long l1=System.currentTimeMillis();
  for (int a=0; a<6; a++) {    
    byte[] buffer = fillBufferWithWheel();
    srl.sendFrame( Arrays.copyOfRange(buffer, 0, 64) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 64, 128) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 128, 192) );
  }
  long l2=System.currentTimeMillis()-l1;
  println(pos+" needed time: "+l2);
  delay(delayTime);  
}


//set random colors
void fxChaos(int delayTime) {  
  long l1=System.currentTimeMillis();
  for (int a=0; a<7; a++) {
    
    byte[] buffer = fillBufferWithRandomColor();
    srl.sendFrame( Arrays.copyOfRange(buffer, 0, 64) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 64, 128) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 128, 192) );
  }
  long l2=System.currentTimeMillis()-l1;
  println("needed time: "+l2);
  delay(delayTime);  
}  



//my first color stuff
void fxStroboCol(int delayTime) {  
  int col = (int)random(0xffffff);
  byte[] buffer = fillBufferWithSolidColor(col);
  
  //color
  for (int a=0; a<6; a++) {
    srl.sendFrame( Arrays.copyOfRange(buffer, 0, 64) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 64, 128) );
    srl.sendFrame( Arrays.copyOfRange(buffer, 128, 192) );
  }

  delay(delayTime);  
}  

//simple white/black strobo
void fxStroboBW(int delayTime) {
    long l1=System.currentTimeMillis();
    
    byte[] colorArray = fillArray(0);
    for (int a=0; a<7; a++) {
      //one loop send data for eight pixel
      srl.sendFrame(colorArray);
      srl.sendFrame(colorArray);
      srl.sendFrame(colorArray);
    }
    long l2=System.currentTimeMillis()-l1;
    delay(delayTime);

    colorArray = fillArray(255);
    for (int a=0; a<6; a++) {
      //send 64 bytes out, update 8 bytes for each output
      srl.sendFrame(colorArray); 
      
      //send 8 bytes 
      srl.sendFrame(colorArray);
      
      //send 8 bytes 
      srl.sendFrame(colorArray);
      
      // -> we send 24 bytes - one color
    }
    delay(delayTime); 
   
    println("needed time: "+l2);
    //Data is latched by holding clock pin low for 1 millisecond 
}


int cnt=0;

/////////////
void draw() {
  if (this.initialized) {
    
//    fxStroboBW(100);
//    fxStroboCol(50);
//    fxChaos(50);
    fxWheel(250);
  }

}
