/*
 * Arduino Theft Protection, Copyright (C) 2013 michael vogt <michu@neophob.com>
 *
 * sleep code from http://donalmorrissey.blogspot.com/2010/04/sleeping-arduino-part-5-wake-up-via.html
 * 
 * ------------------------------------------------------------------------
 *
 * This is the SPI version, unlike software SPI which is configurable, hardware 
 * SPI works only on very specific pins. 
 *
 * On the Arduino Uno, Duemilanove, etc., clock = pin 13 and data = pin 11. 
 * For the Arduino Mega, clock = pin 52, data = pin 51. 
 * For the ATmega32u4 Breakout Board and Teensy, clock = pin B1, data = B2. 
 *
 * ------------------------------------------------------------------------
 */

#include <FastSPI_LED.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/sleep.h>
#include <avr/io.h>


#define NUM_LEDS 2

// Sometimes chipsets wire in a backwards sort of way
struct CRGB { 
  unsigned char b; 
  unsigned char r; 
  unsigned char g; 
};
// struct CRGB { unsigned char r; unsigned char g; unsigned char b; };
struct CRGB *leds;

byte gamma[256];
volatile int f_wdt=1;

byte cnt=0;
byte sleepCycles=0;


void setup() {
  
  /*** Setup the WDT ***/
  
  /* Clear the reset flag. */
  MCUSR &= ~(1<<WDRF);
  
  /* In order to change WDE or the prescaler, we need to
   * set WDCE (This will allow updates for 4 clock cycles).
   */
  WDTCSR |= (1<<WDCE) | (1<<WDE);

  /* set new watchdog timeout prescaler value */
//  WDTCSR = 1<<WDP0 | 1<<WDP3; /* 8.0 seconds */
//  WDTCSR = 1<<WDP2; /* 0.25 seconds */
//  WDTCSR = 1<<WDP0 | 1<<WDP1; /* 0.125 seconds */
  WDTCSR = 1<<WDP1; /* 64 mseconds */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);

  
  FastSPI_LED.setLeds(NUM_LEDS);
  FastSPI_LED.setChipset(CFastSPI_LED::SPI_WS2801);

  //select spi speed, 7 is very slow, 0 is blazing fast
  FastSPI_LED.setDataRate(1);
  FastSPI_LED.init();
  FastSPI_LED.start();
  leds = (struct CRGB*)FastSPI_LED.getRGBData(); 
  
  //create gamma table
  for(int i=0; i<256; i++) {
    gamma[i] = (byte)(pow(((float)i / 255.f), 2.7f) * 255.f + 0.5);
  }
}

byte getRandomColor() {
  return gamma[random(230)];
}

void doRandomColor(int offset) {
  leds[offset].r = getRandomColor();
  leds[offset].g = getRandomColor();
  leds[offset].b = getRandomColor();  
  FastSPI_LED.show();
}


void loop() {
  if(f_wdt == 1) {
    
    if (sleepCycles==0) {
      doRandomColor(cnt%2);  
      cnt++;

      sleepCycles = random(8); //wait between 64 and 8*64ms
    } else {
      sleepCycles--;
    }
    
    /* Don't forget to clear the flag. */
    f_wdt = 0;
    
    /* sleep and save battery */
    sleepNow();
  }
}


void sleepNow() {
    // Choose our preferred sleep mode:
    //set_sleep_mode(SLEEP_MODE_IDLE);
    //set_sleep_mode(SLEEP_MODE_PWR_SAVE);    
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
 
    // Set sleep enable (SE) bit:
    sleep_enable();
 
    // Put the device to sleep:
    sleep_mode();
 
    // Upon waking up, sketch continues from this point.
    sleep_disable();
}



/***************************************************
 *  Name:        ISR(WDT_vect)
 *
 *  Returns:     Nothing.
 *
 *  Parameters:  None.
 *
 *  Description: Watchdog Interrupt Service. This
 *               is executed when watchdog timed out.
 *
 ***************************************************/
ISR(WDT_vect) {
  if(f_wdt == 0) {
    f_wdt=1;
  }
/*  else
  {
    Serial.println("WDT Overrun!!!");
  }*/
}
