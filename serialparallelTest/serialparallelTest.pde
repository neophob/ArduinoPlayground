SerialSend srl;

//buffer
byte[] colorArray;  

boolean initialized = false;

void setup() {
  frameRate(1850);

  colorArray = new byte[64];

  try {
    srl = new SerialSend(this, "/dev/tty.usbmodem12341", 50);          
    this.initialized=true;
    println("Ping result: "+ this.initialized);    
  } catch (Exception e) {
    println("failed");
    e.printStackTrace();
  }
  
}

void fillArray(int val) {
  for (int i=0; i<64; i++) {
    colorArray[i] = (byte)val;
  }
}


int cnt=0;

void draw() {
  if (this.initialized) {
    
    
    //send 64 bytes: 8 bytes for each 8 output streams, one color needs 3 bytes    
    // -> example to fill 48 pixels
    
    long l1=System.currentTimeMillis();
    for (int a=0; a<7; a++) {
      fillArray(0);
      srl.sendFrame(colorArray);
      fillArray(0);
      srl.sendFrame(colorArray);
      fillArray(0);
      srl.sendFrame(colorArray);
    }
    long l2=System.currentTimeMillis()-l1;
    delay(300);

    for (int a=0; a<6*3; a++) {
      fillArray(255);
      srl.sendFrame(colorArray);
      fillArray(255);
      srl.sendFrame(colorArray);
      fillArray(255);
      srl.sendFrame(colorArray);
    }
    delay(300);


    println("needed time: "+l2);
    //Data is latched by holding clock pin low for 1 millisecond
  }

}
