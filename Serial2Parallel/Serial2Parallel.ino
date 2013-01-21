/* Maximum speed USB Serial to Parallel Output
 * http://www.pjrc.com/teensy/
 * Copyright (c) 2012 Paul Stoffregen, PJRC.COM, LLC (paul@pjrc.com)
 * 
 * This highly optimized example was inspired by Phillip Burgess's work at
 * (http://www.paintyourdragon.com) with Adafruit's LPD light strips.
 *
 * Development of this code was funded by PJRC, from sales of Teensy boards.
 * While you may use this code for any purpose, please consider buying Teensy,
 * to support more optimization work in the future.  :-)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// This example converts USB Serial to 8 bit parallel data.  The computer MUST
// transmit in multiples of 64 bytes.  The data bits are output on port D and
// clock signals are output in port B.

#include "usb_private.h"

void setup() {
	for (int i=0; i < NUM_DIGITAL_PINS; i++) {
		pinMode(i, OUTPUT);
	}
}

void loop() {
	moveDataReallyFast(0xFF, 0x00);
}

// these delays allow for more reliable transmission on long wires
//   6 total "nop" are recommended for best speed
//   9 total may still allow max speed, if you're lucky...
//   more than 9 will slow the speed

#define Setup() asm volatile("nop\nnop\nnop\n")	// setup time before rising edge
#define Hold()  asm volatile("nop\nnop\n")	// hold time after falling edge
#define Pulse() asm volatile("nop\n")		// lengthen clock pulse width


/*
This firmware is tested on LPD8806.

the difference between LPD8806 and WS2801.

LPD8806: 7bit
WS2801: 8bit

the LPD8806 latch the data if some special frames are sent out (multiple zero bytes)
the WS2801 latch the data after the clock line is low for 500us.
*/
void moveDataReallyFast(byte strobeOn, byte strobeOff)
{
	unsigned char c;

	if (!usb_configuration) return;
	UENUM = CDC_RX_ENDPOINT;
	while (1) {
		c = UEINTX;
		if (!(c & (1<<RWAL))) {
		  // no data in buffer
			if (c & (1<<RXOUTI)) {
                          UEINTX = 0x6B;
                        }
			return;
		}

		c = UEDATX;       // take one byte out of the buffer, eead byte 0
		PORTD = c;        //DATA
		Setup();
		PORTB = strobeOn; //CLK

		c = UEDATX; //1
		Pulse();
		PORTB = strobeOff; //Only change data when clock is low!
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn; //Data is latched when clock goes high

		c = UEDATX; //2
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //3
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //4
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //6
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //7
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //8
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //10
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //12
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //14
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //18
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //20
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //23
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //26
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //29
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //32
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //33
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //35
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //37
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //38
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //40
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //43
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //45
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //47
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //50
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //53
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //56
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //60
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX;
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

		c = UEDATX; //63
		Pulse();
		PORTB = strobeOff;
		Hold();
		PORTD = c;
		Setup();
		PORTB = strobeOn;

                // Release the USB buffer
		UEINTX = 0x6B;
		Pulse();
		PORTB = strobeOff;
	}
}

#if !defined (CORE_TEENSY_SERIAL)
#error "This program was designed for Teensy 2.0 using Tools > USB Type set to Serial.  Please set the Tools > Board to Teensy 2.0 and USB Type to Serial, or delete this error to try using a different board."
#endif
