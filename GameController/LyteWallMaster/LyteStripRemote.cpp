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

#include "LyteStripRemote.h"

LyteStripRemote::LyteStripRemote(uint16_t n, Stream &comms, uint8_t *buffer)
: numLEDs(n),
  numBytes(n * 3),
  _comms(&comms),
  pixels(buffer)
{
}

void LyteStripRemote::begin(void)
{
}

void LyteStripRemote::show(void)
{
  if (!pixels) return;

  // Send the data to the remote display controller
  // Send all the data via a "R"aw command.

  uint16_t msgLen = numBytes + 1;
  _comms->write((uint8_t)0xaa);
  _comms->write((uint8_t)(msgLen >> 8));
  _comms->write((uint8_t)(msgLen));
  _comms->write((uint8_t)'R');

  for (int i = 0; i < numBytes; i++)
  {
    _comms->write((uint8_t)pixels[i]);
  }
  _comms->write((uint8_t)0x55);

  // The delays are to allow for processing at the Controller
  // We could eventually put in a sync message response to
  // marshall the data.
  delay(10);
  _comms->write((uint8_t)0xaa);
  _comms->write((uint8_t)0x00);
  _comms->write((uint8_t)0x01);
  _comms->write((uint8_t)'D');
  _comms->write((uint8_t)0x55);
  delay(10);
}

void LyteStripRemote::setAllPixels(uint8_t r,
                                   uint8_t g,
                                   uint8_t b)
{
  for (int n = 0; n < numLEDs; n++)
  {
    uint8_t *p = &pixels[n * 3];
    *p++ = r;
    *p++ = g;
    *p = b;
  }

  // _comms->write((uint8_t)0xaa);
  // _comms->write((uint8_t)0x00);
  // _comms->write((uint8_t)0x04);
  // _comms->write((uint8_t)'S');
  // _comms->write((uint8_t)r);
  // _comms->write((uint8_t)g);
  // _comms->write((uint8_t)b);
  // _comms->write((uint8_t)0x55);
}

// Set pixel color from separate R,G,B components:
void LyteStripRemote::setPixelColor(uint16_t n,
                                    uint8_t r,
                                    uint8_t g,
                                    uint8_t b)
{
  if (n < numLEDs)
  {
    if (brightness)
    { // See notes in setBrightness()
      r = (r * brightness) >> 8;
      g = (g * brightness) >> 8;
      b = (b * brightness) >> 8;
    }
    uint8_t *p = &pixels[n * 3];
    *p++ = r;
    *p++ = g;
    *p = b;
  }
}

// Set pixel color from 'packed' 32-bit RGB color:
void LyteStripRemote::setPixelColor(uint16_t n, uint32_t c)
{
  if (n < numLEDs)
  {
    uint8_t
      r = (uint8_t)(c >> 16),
      g = (uint8_t)(c >>  8),
      b = (uint8_t)c;

    if (brightness)
    { // See notes in setBrightness()
      r = (r * brightness) >> 8;
      g = (g * brightness) >> 8;
      b = (b * brightness) >> 8;
    }
    uint8_t *p = &pixels[n * 3];
    *p++ = r;
    *p++ = g;
    *p = b;
  }
}

// Convert separate R,G,B into packed 32-bit RGB color.
// Packed format is always RGB, regardless of LED strand color order.
uint32_t LyteStripRemote::Color(uint8_t r, uint8_t g, uint8_t b)
{
  return ((uint32_t)r << 16) | ((uint32_t)g <<  8) | b;
}

// Query color from previously-set pixel (returns packed 32-bit RGB value)
uint32_t LyteStripRemote::getPixelColor(uint16_t n) const
{
  if (n < numLEDs)
  {
    uint16_t ofs = n * 3;
    return
      ((uint32_t)(pixels[ofs    ]) << 16) |
      ((uint32_t)(pixels[ofs + 1]) << 8)  |
       (uint32_t)(pixels[ofs + 2]);
  }

  return 0; // Pixel # is out of bounds
}

uint8_t *LyteStripRemote::getPixels(void) const
{
  return pixels;
}

uint16_t LyteStripRemote::numPixels(void) const
{
  return numLEDs;
}

// Adjust output brightness; 0=darkest (off), 255=brightest.  This does
// NOT immediately affect what's currently displayed on the LEDs.  The
// next call to show() will refresh the LEDs at this level.  However,
// this process is potentially "lossy," especially when increasing
// brightness.  So we make a pass through the existing color data in RAM
// and scale it (subsequent graphics commands also work at this
// brightness level).  If there's a significant step up in brightness,
// the limited number of steps (quantization) in the old data will be
// quite visible in the re-scaled version.  For a non-destructive
// change, you'll need to re-render the full strip data.  C'est la vie.
void LyteStripRemote::setBrightness(uint8_t b)
{
  // Stored brightness value is different than what's passed.
  // This simplifies the actual scaling math later, allowing a fast
  // 8x8-bit multiply and taking the MSB.  'brightness' is a uint8_t,
  // adding 1 here may (intentionally) roll over...so 0 = max brightness
  // (color values are interpreted literally; no scaling), 1 = min
  // brightness (off), 255 = just below max brightness.

  uint8_t newBrightness = b + 1;

  if (newBrightness != brightness)  // Compare against prior value
  {
    // Brightness has changed -- re-scale existing data in RAM
    uint8_t  c,
            *ptr           = pixels,
             oldBrightness = brightness - 1; // De-wrap old brightness value

    uint16_t scale;

    if (oldBrightness == 0) scale = 0; // Avoid /0
    else if (b == 255) scale = 65535 / oldBrightness;
    else scale = (((uint16_t)newBrightness << 8) - 1) / oldBrightness;
    for (uint16_t i=0; i<numBytes; i++)
    {
      c      = *ptr;
      *ptr++ = (c * scale) >> 8;
    }
    brightness = newBrightness;
  }
}

