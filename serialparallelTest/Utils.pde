
/*
24 bytes contain 3 pixels

Color Buffer Example, Input:
 RRRRRRRR 00000000 00000000
 00000000 GGGGGGGG 00000000
 00000000 00000000 BBBBBBBB
 00000000 00000000 00000000
 00000000 00000000 00000000
 00000000 00000000 00000000
 00000000 00000000 00000000
 00000000 00000000 00000000
 
Output Buffer:
 R0000000 R0000000 R0000000 R0000000 R0000000 R0000000 R0000000 R0000000
 0G000000 0G000000 0G000000 0G000000 0G000000 0G000000 0G000000 0G000000
 00B00000 00B00000 00B00000 00B00000 00B00000 00B00000 00B00000 00B00000
 
Output Hardware:
 D0: RRRRRRRR 00000000 00000000
 D1: 00000000 GGGGGGGG 00000000
 D2: 00000000 00000000 BBBBBBBB
 D3: 00000000 00000000 00000000
 D4: 00000000 00000000 00000000
 D5: 00000000 00000000 00000000
 D6: 00000000 00000000 00000000
 D7: 00000000 00000000 00000000
 
*/
byte[] convert24bytes(byte[] inputData) {
  byte[] outputData = new byte[24];
  
  for (int bitIndex = 8; bitIndex > 0; bitIndex--) {
    for (int pixelIndex = 0; pixelIndex < 8; pixelIndex++) {
      outputData[0 +8-bitIndex] |= ((inputData[0 + 3*pixelIndex] >> (bitIndex-1)) & 1) << pixelIndex;
      outputData[8 +8-bitIndex] |= ((inputData[1 + 3*pixelIndex] >> (bitIndex-1)) & 1) << pixelIndex;
      outputData[16+8-bitIndex] |= ((inputData[2 + 3*pixelIndex] >> (bitIndex-1)) & 1) << pixelIndex;
    }
  }
  
  //TODO maybe reverse bits?
  
  return outputData;
}



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
int clr(int r, int g, int b) {
  return (r << 16) | (g << 8) | (b);
}
int wheel(int WheelPos) {
  WheelPos%=0xff;
  if (WheelPos < 85) {
    return clr(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else if (WheelPos < 170) {
    WheelPos -= 85;
    return clr(255 - WheelPos * 3, 0, WheelPos * 3);
  } 
  else {
    WheelPos -= 170; 
    return clr(0, WheelPos * 3, 255 - WheelPos * 3);
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

