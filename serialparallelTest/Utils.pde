byte[] fillBufferWithSolidColor(int col) {
  
  byte[] buffer = new byte[192];  //192 bytes, buffer to send 8x8 rgb pixels out
  
  int ofs=0;
  for (int j=0; j<8; j++) {
    for (int i=0; i<8; i++) {
      buffer[i+ofs   ] = (byte)( gammaTab[col&255]);
      buffer[i+ofs+8 ] = (byte)( gammaTab[(col>>8)&255]);
      buffer[i+ofs+16] = (byte)( gammaTab[(col>>16)&255]);
    }
    ofs += 24;
  }

  return buffer;
}


byte[] fillBufferWithRandomColor() {
  byte[] buffer = new byte[192];  //192 bytes, buffer to send 8x8 rgb pixels out
  
  int ofs=0;
  for (int j=0; j<8; j++) {
    for (int i=0; i<8; i++) {
      int col = (int)random(0xffffff);
      buffer[i+ofs   ] = (byte)( gammaTab[col&255]);
      buffer[i+ofs+8 ] = (byte)( gammaTab[(col>>8)&255]);
      buffer[i+ofs+16] = (byte)( gammaTab[(col>>16)&255]);
    }
    ofs += 24;
  }

  return buffer;
}

// Create a 24 bit color value from R,G,B
int col(int r, int g, int b) {
  int c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}

int wheel(int WheelPos) {
  WheelPos%=0xff;
  if (WheelPos < 85) {
    return col(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else if (WheelPos < 170) {
    WheelPos -= 85;
    return col(255 - WheelPos * 3, 0, WheelPos * 3);
  } 
  else {
    WheelPos -= 170; 
    return col(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

byte[] fillBufferWithWheel() {
  byte[] buffer = new byte[192];  //192 bytes, buffer to send 8x8 rgb pixels out
  
  int ofs=0;
  for (int j=0; j<8; j++) {
    int col = wheel(pos++);    
    //Set color on all 8 outputs
    for (int i=0; i<8; i++) {
      buffer[i+ofs   ] = (byte)( gammaTab[col&255]);
      buffer[i+ofs+8 ] = (byte)( gammaTab[(col>>8)&255]);
      buffer[i+ofs+16] = (byte)( gammaTab[(col>>16)&255]);
    }
    ofs += 24;
  }

  return buffer;
}


static int[] generateGammaTab(float gamma) {
		int[] ret = new int[256];

		for (int i=0; i<256; i++) {
			ret[i] = (int)(Math.pow ((float)(i)/255.0f, gamma)*255.0f+0.5f);
		}

		return ret;
}


byte[] fillArray(int val) {
  byte[] colorArray = new byte[64];
  for (int i=0; i<64; i++) {
    colorArray[i] = (byte)val;
  }
  return colorArray;
}

