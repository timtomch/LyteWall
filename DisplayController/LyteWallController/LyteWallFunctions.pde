/*
||
|| @author         Brett Hagman <bhagman@wiring.org.co>
|| @url            http://wiring.org.co/
|| @url            http://roguerobotics.com/
|| @contribution   Various - please contact for acknowledgement
||
|| @description
|| |
|| | Support functions for LyteWallController.
|| |
|| #
||
|| @license Please see the accompanying License.txt file for this project.
||
|| @name LED Wall Controller Functions
|| @type Support Sketch
|| @target Target Independent
||
|| @version 1.0.1
||
*/

/*
||
|| TODO list:
||
// TODO: Get a color with relative faded value:
//       ColorFaded(r, g, b, pct) - 100% full brightness, 0% = black
//
// TODO: Store intensity per strand
//       (calculate fade values when displaying, retaining existing color values
//       i.e. you /COULD/ load in an image and fade it up)
//
//
*/

#define LYTEWALLFUNCTIONS_VERSION 10001

#define SHOWFPS 0


void reversePixels(uint8_t *arr, uint16_t start, uint16_t len)
{
  // reverse the pixels in part of the pixel array.
  uint8_t temp[3];
  uint16_t arrlen = len * colorDepth;

//  uint8_t *p = strandData + (start * colorDepth);
  uint8_t *p = arr + (start * colorDepth);

  for (uint8_t i = 0; i < (len / 2); i++)
  {
    for (uint8_t j = 0; j < colorDepth; j++)
    {
//      Serial.print(p[i * colorDepth + j], DEC);
//      Serial.print("<=>");
//      Serial.println(p[arrlen - (i + 1) * colorDepth + j], DEC);
      temp[j] = p[i * colorDepth + j];
      p[i * colorDepth + j] = p[arrlen - (i + 1) * colorDepth + j];
      p[arrlen - (i + 1) * colorDepth + j] = temp[j];
    }
  }
}


// Reverse every other strand (for use with bitmaps).
void reverseRawStrands()
{
  for (uint8_t i = 1; i < numStrands; i += 2)
  {
    reversePixels(strandData, LEDsPerStrand * i, LEDsPerStrand);
  }
}


// Transfer data from strandData to strip
void xferPixels(void)
{
  uint16_t i;

  for (i = 0; i < (numStrands * LEDsPerStrand); i++)
  {
    strip.setPixelColor(i, strandData[i * 3], strandData[i * 3 + 1], strandData[i * 3 + 2]);
  }
}


// Write directly to the pixel array, reversing every second strand
// WARNING: This will become a pig for time, if the LEDsPerStrand is not
// a power of 2 (i.e. 2^n).  Oink oink!
void setPixel(uint16_t n, uint32_t color)
{
  setPixel(n / LEDsPerStrand, n % LEDsPerStrand, color);
}


// Write directly to the pixel array, reversing every second strand
void setPixel(uint8_t col, uint8_t row, uint32_t color)
{
  // Every second strand needs to have it's row position reversed
  if (col % 2) // "odd" strand
    row = (LEDsPerStrand - 1) - row;

  strip.setPixelColor(col * LEDsPerStrand + row, color);
}


void showPixels(void)
{
#if (SHOWFPS)
  static uint32_t timeTotal = 0;
  static uint32_t showTimeTotal = 0;
  static uint8_t frameCount = 0;
  static uint32_t t1 = 0;
  uint32_t showStartTime = 0;

  showStartTime = millis();
#endif
  strip.show();
#if (SHOWFPS)
  uint32_t t2 = millis();

//  Serial.print(Constant("Time: "));
//  Serial.print(t2 - t1, DEC);
//  Serial.println(Constant(" ms"));

  timeTotal += (t2 - t1);
  showTimeTotal += (t2 - showStartTime);
  frameCount++;

  if (frameCount >= 100)
  {
    float fpsAvg = 1000.0 / ((1.0 * timeTotal) / frameCount);
    float showfpsAvg = 1000.0 / ((1.0 * showTimeTotal) / frameCount);
    // fps = 1 / (timeTotal / frameCount)
    Serial.print(Constant("Avg FPS: "));
    Serial.println(fpsAvg);
    Serial.print(Constant("Avg FPS (Show): "));
    Serial.println(showfpsAvg);
    timeTotal = 0;
    showTimeTotal = 0;
    frameCount = 0;
  }

  t1 = t2;
#endif
}


void setBar(uint8_t n, uint8_t onLEDs, uint32_t color, uint8_t reverse)
{
  // Fills one bar
  uint8_t i;

  // if color is black (wtf?) let's make it transparent, and
  // keep what was already there!
  if (color != 0)
  {
    for (i = 0; i < onLEDs; i++)
    {
      if (reverse)
        setPixel(n, (LEDsPerStrand - 1) - i, color);
      else
        setPixel(n, i, color);
    }
  }

  // turn the rest off
  for (i = 0; i < (LEDsPerStrand - onLEDs); i++)
  {
    if (reverse)
      setPixel(n, (LEDsPerStrand - 1) - (onLEDs + i), 0);
    else
      setPixel(n, onLEDs + i, 0);
  }
}


void setAll(uint32_t color)
{
  uint16_t i;

  for (i = 0; i < (numStrands * LEDsPerStrand); i++)
  {
    strip.setPixelColor(i, color);
  }
}


void fillRainbowCycle(uint16_t offset)
{
  static uint16_t i = 0;
  uint8_t n;

  for (n = 0; n < numStrands; n++)
  {
    rainbowCycle(n * LEDsPerStrand, LEDsPerStrand, offset, i + n);
  }

  if (++i >= 384)
    i = 0;
}


void rainbow(uint16_t start, uint16_t len)
{
  static uint16_t j = 0;
  uint16_t i;

  for (i = 0; i < len; i++)
  {
    setPixel(start + i, Wheel((i + j) % 384));
  }

  if (++j >= 384)
    j = 0;
}


// Slightly different, this one makes the rainbow wheel equally distributed
// along the chain
void rainbowCycle(uint16_t start, uint16_t len, uint16_t fraction, int16_t seed)
{
  static uint16_t j;
  uint16_t i;

  if (seed >= 0)
    j = seed;

  if (fraction == 0 || fraction > 384)
    fraction = 384;

  for (i = 0; i < len; i++)
  {
    // tricky math! we use each pixel as a fraction of the full 384-color wheel
    // (thats the i / fraction part)
    // Then add in j which makes the colors go around per pixel
    // the % 384 is to make the wheel cycle around
    setPixel(start + i, Wheel(((i * 384 / fraction) + j) % 384));
  }

  if (++j >= 384)
    j = 0;
}

/*
// Fill the dots progressively along the strip.
void colorWipe(uint32_t c, uint8_t wait)
{
  int i;

  for (i = 0; i < workingLEDs; i++)
  {
      strip.setPixelColor(i, c);
timedShow();//      strip.show();
      delay(wait);
  }
}

// Chase one dot down the full strip.
void colorChase(uint32_t c, uint8_t wait)
{
  int i;

  // Start by turning all pixels off:
  for (i = 0; i < workingLEDs; i++)
    strip.setPixelColor(i, 0);

  // Then display one pixel at a time:
  for (i = 0; i < workingLEDs; i++)
  {
    strip.setPixelColor(i, c); // Set new pixel 'on'
timedShow();
//    strip.show();              // Refresh LED states
    strip.setPixelColor(i, 0); // Erase pixel, but don't refresh!
    delay(wait);
  }

  strip.show(); // Refresh to turn off last pixel
}

*/

//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g -b - back to r

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch (WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   // Red down
      g = WheelPos % 128;         // Green up
      b = 0;                      // Blue off
      break;
    case 1:
      g = 127 - WheelPos % 128;   // Green down
      b = WheelPos % 128;         // Blue up
      r = 0;                      // Red off
      break;
    case 2:
      b = 127 - WheelPos % 128;   // Blue down
      r = WheelPos % 128;         // Red up
      g = 0;                      // Green off
      break;
  }
  return (strip.Color(r << 1, g << 1, b << 1));
}

