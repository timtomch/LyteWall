/*
||
|| @author         Brett Hagman <bhagman@wiring.org.co>
|| @url            http://wiring.org.co/
|| @url            http://roguerobotics.com/
|| @contribution   Phil Burgess
|| @contribution   Paul Stoffregen
|| @contribution   Adafruit
||
|| @description
|| |
|| | This library provides an interface to a LyteWallController running
|| | on a separate controller.
|| |
|| #
||
|| @license Please see the accompanying License.txt file for this project.
||
|| @name Light Strip Remote
|| @type Sketch
|| @target Target Independent
||
|| @version 1.0.1
||
|| @dependencies
|| |
|| #
*/

#ifndef LYTESTRIPREMOTE_H
#define LYTESTRIPREMOTE_H

#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <Wiring.h>
#endif

class LyteStripRemote
{

  public:
  // Constructor: number of LEDs, Stream Comms
    LyteStripRemote(uint16_t n, Stream &comms, uint8_t *buffer);

    void begin(void);
    void show(void);
    void setPin(uint8_t p);
    void setPixelColor(uint16_t n, uint8_t r, uint8_t g, uint8_t b);
    void setPixelColor(uint16_t n, uint32_t c);
    void setAllPixels(uint8_t r, uint8_t g, uint8_t b);
    void setBrightness(uint8_t);
    uint8_t *getPixels() const;
    uint16_t numPixels() const;
    static uint32_t Color(uint8_t r, uint8_t g, uint8_t b);
    uint32_t getPixelColor(uint16_t n) const;

  private:
    const uint16_t numLEDs;  // Number of RGB LEDs in strip
    const uint16_t numBytes; // Size of 'pixels' buffer below

    Stream *_comms;
    uint8_t brightness;
    uint8_t *pixels;         // Holds LED color values (3 bytes each)
};

#endif // LYTESTRIPREMOTE_H
