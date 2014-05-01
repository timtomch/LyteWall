/*
||
|| @author         Brett Hagman <bhagman@wiring.org.co>
|| @url            http://wiring.org.co/
|| @url            http://roguerobotics.com/
||
|| @description
|| |
|| | The following sketch accepts serial commands and alters pixels on
|| | a matrix of WS2812 LEDs (aka NeoPixels).
|| |
|| #
||
|| @license Please see the accompanying License.txt file for this project.
||
|| @name Lyte Wall Controller
|| @type Sketch
|| @target Target Independent
||
|| @version 1.0.1
||
|| @dependencies
|| | Adafruit_Neopixel <https://github.com/adafruit/Adafruit_NeoPixel/tree/bbd3887d99cc5d2ae40549446013b667475a92fc>
|| | SerialMessage.pde
|| | LyteWallFunctions.pde
|| #
*/

#define LYTEWALLCONTROLLER_VERSION 10001

#include <Adafruit_NeoPixel.h>

// This comes from SerialMessage.pde
extern uint8_t msgBuffer[];

// Number of RGB LEDs in strand:
int numStrands = 12;
int LEDsPerStrand = 12;
int numLEDs = numStrands * LEDsPerStrand;
int const colorDepth = 3;
int const pinStrand = 6;

#define debugSerialOut Serial
#define InputSerial Serial
uint32_t const debugSerialBitRate = 250000;
uint32_t const serialBitRate = 250000;

#ifdef ARDUINO
#define Constant(x) x
#endif

uint8_t strandData[144 * colorDepth];  // currently a max of 12x12
Adafruit_NeoPixel strip = Adafruit_NeoPixel(numLEDs, pinStrand, NEO_GRB + NEO_KHZ800);


void printA(uint8_t *a, uint8_t s)
{
  for (uint8_t i = 0; i < s; i++)
  {
    debugSerialOut.print(a[i], DEC);
    debugSerialOut.print(" ");
  }

  debugSerialOut.println();
}


void setup()
{
  debugSerialOut.begin(debugSerialBitRate);
  debugSerialOut.println(Constant("Started"));
  InputSerial.begin(serialBitRate);

  // This section is purely for my debug rig, which is only 5 x 5 LEDs.
  // If pin 8 is held low on startup, we switch to 5 x 5 mode.
  pinMode(8, INPUT);
  digitalWrite(8, HIGH);
  delay(5);
  if (digitalRead(8) == 0)
  {
    debugSerialOut.println(Constant("Setting 5x5"));
    numStrands = 5;
    LEDsPerStrand = 5;
    numLEDs = 25;
  }


  // Start up the LED strip
  strip.begin();

  // Update the strip, to start they are all 'off'
  strip.show();
}


// Chase one dot down the full strip.
/*
void chase2(uint32_t c, int n)
{
  int i;

  for (int x = 0; x < n; x++)
  {
    for (i = 0; i < strip.numPixels(); i++)
    {
      if (i == x)
        strip.setPixelColor(i, c); // Set new pixel 'on'
      else
        strip.setPixelColor(i, 0);
    }
timedShow();//    strip.show(); // Refresh to turn off last pixel
  }
}
*/

void tests()
{
  /*
    for (uint16_t i = 0; i < 384; i++)
    {
      rainbowCycle(0, 48, 96, i);
      rainbowCycle(48, 48, 96, i + 1);
      showPixels();
    }
  */
  /*
    for (uint8_t i = 0; i <= 100; i++)
    {
      fillRainbowCycle(192);
      setBar(0, i, 0);
      setBar(1, 100 - i, 0);
      showPixels();  // takes roughly 20 ms
    }
    for (uint8_t i = 0; i <= 100; i++)
    {
      fillRainbowCycle(192);
      setBar(0, 100 - i, 0);
      setBar(1, i, 0);
      showPixels();  // takes roughly 20 ms
    }
  */

//  uint32_t t1 = millis();
  fillRainbowCycle(96);  // The Wheel() function is entirely too slow!
//  Serial.println(millis() - t1, DEC);
  showPixels();
}


void test1(void)
{
  uint16_t i;

  for (i = 0; i < 96; i++)
  {
    setPixel(i, strip.Color(255, 0, 0));
    showPixels();
  }

  while (1);
}



void loop()
{
  // tests();
  // return;

  int16_t msgLength = 0;
  uint8_t col, row, val;
  uint8_t i, j;
  uint32_t color;

  // Serial Message Protocol
  // <SOM><LEN>CMD DATA<EOM>
  //
  // All pixel commands except 'D' update the pixel buffer.
  // To display the pixels on the display, send the 'D' command.
  //
  // Commands:
  //
  // Set display (raw) - 24 bit color (3 bytes per pixel)
  // 24 bit values are stored MSB first (e.g. b1 = upper 8, b2 = mid 8, b3 = lower 8)
  // WARNING: This will be stored directly in strand buffer.
  // <SOM><size> 'R' b1 b2 b3  b4 b5 b6  ... bsize <EOM>

  // Set column (raw) - 24 bit color (3 bytes per pixel)
  // <SOM><csize> 'V' col  b1 b2 b3  b4 b5 b6  ... bcsize <EOM>
  //
  // Set pixel (raw) - 24 bit color (3 bytes per pixel)
  // <SOM><6> 'P' col row colorR colorG colorB<EOM>
  //
  // Bar (progress bar) value - 32 bit color
  // <SOM><7> 'b' col value colorR colorG colorB reverse <EOM>
  // value = LEDs lit
  // reverse = flip bar (0 or 1)
  //
  // Bar (progress bar) percentage - 32 bit color
  // <SOM><7> 'B' col percent colorR colorG colorB reverse <EOM>
  // reverse = flip bar (0 or 1)
  //
  // Set entire display to Cycling Rainbow (iterates per call)
  // <SOM><3> 'N' offsetH offsetL <EOM>
  // offsetH/L = skews rainbow pattern (0 -> 384)
  //
  // Force display of pixels
  // <SOM><1> 'D' <EOM>
  //
  // TODO: Get Display Size
  // <SOM><1> 'Z' <EOM>
  // -- Returns:
  //    <SOM><2> /strands/ /pixelsPerStrand/ <EOM>
  //
  // Set Intensity
  // <SOM><2> 'I' percent <EOM>
  //
  // Set all pixels to color
  // <SOM><3> 'S' colorH colorL <EOM>
  //

  if ((msgLength = getMessage()) > 0)
  {
    // Set display (raw) - 24 bit color (3 bytes per pixel)
    // 24 bit values are stored MSB first (e.g. b1 = upper 8, b2 = mid 8, b3 = lower 8)
    // WARNING: This will be stored directly in strand buffer.
    // <SOM><size> 'R' b1 b2 b3  b4 b5 b6  ... bsize <EOM>

    if (msgBuffer[0] == 'R' && msgLength == (numStrands * LEDsPerStrand * colorDepth + 1))
    {
      // data is automatically loaded into strandData
      reverseRawStrands();
      xferPixels();
      // showPixels();  // must send 'D' to show pixels
    }

    // Set column (raw) - 24 bit color (3 bytes per pixel)
    // <SOM><csize+1> 'V' col  b1 b2 b3  b4 b5 b6  ... bcsize <EOM>
    else if (msgBuffer[0] == 'V' && msgLength == (LEDsPerStrand * colorDepth + 2))
    {
      // set the column directly
      col = msgBuffer[1];

      if (col < numStrands)
      {
        for (i = 0; i < LEDsPerStrand; i++)
        {
          color = strip.Color((uint8_t)msgBuffer[i * colorDepth + 2],
                              (uint8_t)msgBuffer[i * colorDepth + 3],
                              (uint8_t)msgBuffer[i * colorDepth + 4]);
          setPixel(col, i, color);
        }
        // showPixels();  // must send 'D' to show pixels
      }
      else
      {
        debugSerialOut.print(Constant("CMD V Error - Column # too big: "));
        debugSerialOut.println(col, DEC);
      }
    }

    // Set pixel (raw)
    // <SOM><6> 'P' col row colorR colorG colorB <EOM>
    else if (msgBuffer[0] == 'P' && msgLength == 6)
    {
      col = msgBuffer[1];
      row = msgBuffer[2];
      color = strip.Color((uint8_t)msgBuffer[3],
                          (uint8_t)msgBuffer[4],
                          (uint8_t)msgBuffer[5]);

      if (col < numStrands && row < LEDsPerStrand)
      {
        setPixel(col, row, color);
        // showPixels();  // must send 'D' to show pixels
      }
      else
      {
        debugSerialOut.print(Constant("CMD P Error - col/row out of bounds: C"));
        debugSerialOut.print(col, DEC);
        debugSerialOut.print(Constant("/R"));
        debugSerialOut.println(row, DEC);
      }
    }

    // Bar (progress bar) percentage - 16 bit color
    // <SOM><7> 'B' col percent colorR colorG colorB reverse <EOM>
    // Bar (progress bar) value - 16 bit color
    // <SOM><7> 'b' col value colorR colorG colorB reverse <EOM>
    else if ((msgBuffer[0] == 'B' || msgBuffer[0] == 'b') && msgLength == 7)
    {
      col = msgBuffer[1];
      val = msgBuffer[2];
      color = strip.Color((uint8_t)msgBuffer[3],
                          (uint8_t)msgBuffer[4],
                          (uint8_t)msgBuffer[5]);
      if (msgBuffer[0] == 'B')
        val = ((uint16_t)(val) * LEDsPerStrand) / 100;

      if (val > LEDsPerStrand)
        val = LEDsPerStrand;

      if (col < numStrands)
      {
        setBar(col, val, color, msgBuffer[6]);
        // showPixels();  // must send 'D' to show pixels
      }
      else
      {
        debugSerialOut.print(Constant("CMD B Error - Column # too big: "));
        debugSerialOut.println(col, DEC);
      }
    }

    // Set entire display to Cycling Rainbow
    // <SOM><3> 'N' offsetH offsetL <EOM>
    else if (msgBuffer[0] == 'N' && msgLength == 3)
    {
      val = (uint16_t)msgBuffer[1] << 8 | msgBuffer[2];
      fillRainbowCycle(val);  // The Wheel() function is entirely too slow!
    }

    // Set all pixels to color
    // <SOM><4> 'S' colorR colorG colorB<EOM>
    else if (msgBuffer[0] == 'S' && msgLength == 4)
    {
      color = strip.Color((uint8_t)msgBuffer[1],
                          (uint8_t)msgBuffer[2],
                          (uint8_t)msgBuffer[3]);
      setAll(color);
    }

    // Force display of pixels
    // <SOM><1> 'D' <EOM>
    else if (msgBuffer[0] == 'D' && msgLength == 1)
    {
      showPixels();
    }

    // Set Intensity
    // <SOM><2> 'I' percent <EOM>
    else if (msgBuffer[0] == 'I' && msgLength == 2)
    {
      strip.setBrightness(msgBuffer[1]);
    }

    else
    {
      debugSerialOut.print(Constant("Bad command. Got CMD: "));
      debugSerialOut.print((char)msgBuffer[0]);
      debugSerialOut.print(Constant(" and LEN: "));
      debugSerialOut.println(msgLength, DEC);
    }
  }
  else
  {
    debugSerialOut.println(Constant("Malformed message."));
  }
}

