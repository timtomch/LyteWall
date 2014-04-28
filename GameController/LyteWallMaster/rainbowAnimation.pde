/* LedTable for Teensy3
 *
 * Written by: Klaas De Craemer, 2013
 * https://sites.google.com/site/klaasdc/led-table
 * 
 * Rainbow animation for the LED table. Code is based on the OctoWS2812 Rainbow example
 */

#define  RAINBOWSPEED  250
int rainbowColors[180];

boolean rainBowRunning = true;

void initRainbow()
{
  for (int i = 0; i < 180; i++)
  {
    int hue = i * 2;
    int saturation = 100;
    int lightness = 50;
    // pre-compute the 180 rainbow colors
    rainbowColors[i] = makeColor(hue, saturation, lightness);
Serial.print(rainbowColors[i], HEX);
Serial.print(' ');
  }
}

void runRainbow()
{
//  initRainbow();
  rainBowRunning = true;
  while (rainBowRunning)
  {
    rainbow();
  }
  
  fadeOut();
}

// phaseShift is the shift between each row.  phaseShift=0
// causes all rows to show the same colors moving together.
// phaseShift=180 causes each row to be the opposite colors
// as the previous.
//
// cycleTime is the number of milliseconds to shift through
// the entire 360 degrees of the color wheel:
// Red -> Orange -> Yellow -> Green -> Blue -> Violet -> Red
//
void rainbow()
{
  rainbowCycle(0, numLEDs, numLEDs, -1);

  leds.show();

  //Read buttons

  readInput();
  if (curControl == BTN_START)
  {
    Serial.println(Constant("Stopped"));
    rainBowRunning = false;
  }
  delay(20);
}

// Convert HSL (Hue, Saturation, Lightness) to RGB (Red, Green, Blue)
//
//   hue:        0 to 359 - position on the color wheel, 0=red, 60=orange,
//                            120=yellow, 180=green, 240=blue, 300=violet
//
//   saturation: 0 to 100 - how bright or dull the color, 100=full, 0=gray
//
//   lightness:  0 to 100 - how light the color is, 100=white, 50=color, 0=black
//
int makeColor(unsigned int hue, unsigned int saturation, unsigned int lightness)
{
  unsigned int red, green, blue;
  unsigned int var1, var2;

  if (hue > 359) hue = hue % 360;
  if (saturation > 100) saturation = 100;
  if (lightness > 100) lightness = 100;

  // algorithm from: http://www.easyrgb.com/index.php?X=MATH&H=19#text19
  if (saturation == 0)
  {
    red = green = blue = lightness * 255 / 100;
  } 
  else
  {
    if (lightness < 50)
    {
      var2 = lightness * (100 + saturation);
    } 
    else
    {
      var2 = ((lightness + saturation) * 100) - (saturation * lightness);
    }
    var1 = lightness * 200 - var2;
    red = h2rgb(var1, var2, (hue < 240) ? hue + 120 : hue - 240) * 255 / 600000;
    green = h2rgb(var1, var2, hue) * 255 / 600000;
    blue = h2rgb(var1, var2, (hue >= 120) ? hue - 120 : hue + 240) * 255 / 600000;
  }
  return (red << 16) | (green << 8) | blue;
}

unsigned int h2rgb(unsigned int v1, unsigned int v2, unsigned int hue)
{
  if (hue < 60) return v1 * 60 + (v2 - v1) * hue;
  if (hue < 180) return v2 * 60;
  if (hue < 240) return v1 * 60 + (v2 - v1) * (240 - hue);
  return v1 * 60;
}

// alternate code:
// http://forum.pjrc.com/threads/16469-looking-for-ideas-on-generating-RGB-colors-from-accelerometer-gyroscope?p=37170&viewfull=1#post37170


// Slightly different, this one makes the rainbow wheel equally distributed 
// along the chain
void rainbowCycle(uint16_t start, const uint16_t len, uint16_t fraction, int16_t seed)
{
  static uint16_t j;
  uint16_t i;
  uint32_t nextColor;

  if (seed >= 0)
    j = seed;

  if (fraction == 0 || fraction > 384)
    fraction = 384;

  for (i = 0; i < len; i++)
  {
    nextColor = Wheel(((384 / numLEDs) * i + j) % 384);
    leds.setPixelColor(start + i, nextColor);
  }  

  if (++j >= 384)
    j = 0;
}


uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   //Red down
      g = WheelPos % 128;      // Green up
      b = 0;                  //blue off
      break; 
    case 1:
      g = 127 - WheelPos % 128;  //green down
      b = WheelPos % 128;      //blue up
      r = 0;                  //red off
      break; 
    case 2:
      b = 127 - WheelPos % 128;  //blue down 
      r = WheelPos % 128;      //red up
      g = 0;                  //green off
      break; 
  }
  return(leds.Color(r << 1, g << 1, b << 1));
}

