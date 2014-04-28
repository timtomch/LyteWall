/*
||
|| @author         Brett Hagman <bhagman@wiring.org.co>
|| @url            http://wiring.org.co/
|| @url            http://roguerobotics.com/
|| @contribution   Klaas De Craemer
|| @url            https://sites.google.com/site/klaasdc/led-table
||
|| @description
|| |
|| | Master controller sketch for the Lyte Wall project.
|| | A good majority of the initial code comes from Klaas De Craemer's
|| | led-table project.
|| |
|| | All of the initial "functions" come from Klaas De Craemer's led-table
|| | project: Stars animation, Tetris clone, Snake game, and Rainbow animation.
|| | They have been included with little to no changes (just a small change for
|| | the variable size for holding colours).
|| #
||
|| @license Please see the accompanying License.txt file for this project.
||
|| @name Lyte Wall Master
|| @type Sketch
|| @target Target Independent
||
|| @version 1.0.1
||
|| @dependencies
|| | LyteStripRemote
|| | rainbowAnimation.pde
|| | snakeCommon.pde
|| | snakeGame.pde
|| | starsAnimation.pde
|| | tetrisCommon.pde
|| | testrisGame.pde
|| | menu.pde
|| | font.h
|| #
*/

//LED field size
#define  FIELD_WIDTH       12
#define  FIELD_HEIGHT      12
//#define  ORIENTATION_HORIZONTAL //Rotation of table, uncomment to rotate field 90 degrees

uint32_t const serialBitRate = 250000;

#include "LyteStripRemote.h"

const int numLEDs = FIELD_HEIGHT * FIELD_WIDTH;

uint8_t pixelBuffer[numLEDs * 3];
LyteStripRemote leds = LyteStripRemote(numLEDs, Serial1, pixelBuffer);


/* *** LED color table *** */
#define  GREEN  0x00FF00
#define  RED    0xFF0000
#define  BLUE   0x0000FF
#define  YELLOW 0xFFFF00
#define  LBLUE  0x00FFFF
#define  PURPLE 0xFF00FF
#define  WHITE  0XFFFFFF
uint32_t colorLib[6] = {RED, GREEN, BLUE, YELLOW, LBLUE, PURPLE};

/* *** Game commonly used defines ** */
#define  DIR_UP    1
#define  DIR_DOWN  2
#define  DIR_LEFT  3
#define  DIR_RIGHT 4

/* *** USB controller button defines and input method *** */
#define  BTN_NONE  0
#define  BTN_UP    0b00001
#define  BTN_DOWN  0b00010
#define  BTN_LEFT  0b00100
#define  BTN_RIGHT  0b01000
#define  BTN_START  0b10000

uint8_t curControl = BTN_NONE;

#include <Button.h>

Button buttonUp = Button(7, BUTTON_PULLDOWN);
Button buttonDown = Button(8, BUTTON_PULLDOWN);
Button buttonLeft = Button(9, BUTTON_PULLDOWN);
Button buttonRight = Button(10, BUTTON_PULLDOWN);
Button buttonStart = Button(11, BUTTON_PULLDOWN);


void readInput()
{
  curControl = BTN_NONE;

  buttonUp.scan();
  buttonDown.scan();
  buttonLeft.scan();
  buttonRight.scan();
  buttonStart.scan();


  if (buttonUp.uniquePress())
    curControl = BTN_UP;

  if (buttonDown.uniquePress())
    curControl = BTN_DOWN;

  if (buttonLeft.uniquePress())
    curControl = BTN_LEFT;

  if (buttonRight.uniquePress())
    curControl = BTN_RIGHT;

  if (buttonStart.uniquePress())
    curControl = BTN_START;


  if (curControl != BTN_NONE)
    return;

  if (Serial.available())
  {
    // read the incoming byte:
    uint8_t incomingByte = Serial.read();
    if (incomingByte == 27)
    {
      while (!Serial.available());
      incomingByte = Serial.read();//Should be 91 so that escape sequence is complete
      while (!Serial.available());
      incomingByte = Serial.read();//This character determines actual key press
      switch (incomingByte)
      {
        case 68:
          curControl = BTN_LEFT;
          break;
        case 67:
          curControl = BTN_RIGHT;
          break;
        case 65:
          curControl = BTN_UP;
          break;
        case 66:
          curControl = BTN_DOWN;
          break;
      }
    }
    else if (incomingByte == 32) //Space bar pressed, reset active brick
    {
      curControl = BTN_START;
    }
  }
}


void setTablePixel(uint8_t x, uint8_t y, uint32_t color)
{

#ifdef ORIENTATION_HORIZONTAL
  leds.setPixelColor(y * FIELD_WIDTH + x, color);
#else
  leds.setPixelColor(x * FIELD_WIDTH + y, color);
#endif
#ifdef USE_CONSOLE_OUTPUT
  setTablePixelConsole(x, y, color);
#endif
}

void clearTablePixels()
{
  leds.setAllPixels(0, 0, 0);
}

/* *** text helper methods *** */
#include "font.h"
uint8_t charBuffer[8][8];

void printText(char* text, unsigned int textLength, int xoffset, int yoffset, uint32_t color)
{
  uint8_t curLetterWidth = 0;
  int curX = xoffset;
  clearTablePixels();

  //Loop over all the letters in the string
  for (int i = 0; i < textLength; i++)
  {
    //Determine width of current letter and load its pixels in a buffer
    curLetterWidth = loadCharInBuffer(text[i]);
    //Loop until width of letter is reached
    for (int lx = 0; lx < curLetterWidth; lx++)
    {
      //Now copy column per column to field (as long as within the field
      if (curX >= FIELD_WIDTH)
      {
        //If we are to far to the right, stop loop entirely
        break;
      }
      else if (curX >= 0)
      {
        //Draw pixels as soon as we are "inside" the drawing area
        for (int ly = 0; ly < 8; ly++)
        {
          //Finally copy column
          setTablePixel(curX, yoffset + ly, charBuffer[lx][ly]*color);
        }
      }
      curX++;
    }
  }

  leds.show();
#ifdef USE_CONSOLE_OUTPUT
  outputTableToConsole();
#endif
}

//Load char in buffer and return width in pixels
uint8_t loadCharInBuffer(char letter)
{
  uint8_t* tmpCharPix;
  uint8_t tmpCharWidth;

  int letterIdx = (letter - 32) * 8;

  int x = 0;
  int y = 0;
  for (int idx = letterIdx; idx < letterIdx + 8; idx++)
  {
    for (int x = 0; x < 8; x++)
    {
      charBuffer[x][y] = ((font[idx]) & (1 << (7 - x))) > 0;
    }
    y++;
  }

  tmpCharWidth = 8;
  return tmpCharWidth;
}


/* *********************************** */

void fadeOut()
{
  //Select random fadeout animation
  int selection = random(3);

  switch (selection)
  {
    case 0:
    case 1:
      {
        //Fade out by dimming all pixels
        for (int i = 0; i < 100; i++)
        {
          dimLeds(0.97);
          leds.show();
          delay(10);
        }
        break;
      }
    case 2:
      {
        //Fade out by swiping from left to right with ruler
        const int ColumnDelay = 10;
        int curColumn = 0;
        for (int i = 0; i < FIELD_WIDTH * ColumnDelay; i++)
        {
          dimLeds(0.97);
          if (i % ColumnDelay == 0)
          {
            //Draw vertical line
            for (int y = 0; y < FIELD_HEIGHT; y++)
            {
              setTablePixel(curColumn, y, GREEN);
            }
            curColumn++;
          }
          leds.show();
//        delay(5);
        }
        //Sweep complete, keep dimming leds for short time
        for (int i = 0; i < 100; i++)
        {
          dimLeds(0.9);
          leds.show();
//        delay(5);
        }
        break;
      }
  }
}

void dimLeds(float factor)
{
  //Reduce brightness of all LEDs, typical factor is 0.97
  for (int n = 0; n < (FIELD_WIDTH * FIELD_HEIGHT); n++)
  {
    uint32_t curColor = leds.getPixelColor(n);
    //Derive the tree colors
    uint32_t r = ((curColor & 0xFF0000) >> 16);
    uint32_t g = ((curColor & 0x00FF00) >> 8);
    uint32_t b = (curColor & 0x0000FF);
    //Reduce brightness
    r = r * factor;
    g = g * factor;
    b = b * factor;
    //Pack into single variable again
    curColor = (r << 16) + (g << 8) + b;
    //Set led again
    leds.setPixelColor(n, curColor);
  }
}


void setup()
{
  Serial.begin(115200);
  Serial.println(Constant("Started"));
  Serial1.begin(serialBitRate);

  // For capacitive touch keys (rKeys)
  pinMode(12, OUTPUT);
  digitalWrite(12, HIGH);  // Turn on the switches

  pinMode(7, INPUT);
  pinMode(8, INPUT);
  pinMode(9, INPUT);
  pinMode(10, INPUT);
  pinMode(11, INPUT);

  leds.begin();
  leds.show();

  // Jump to menu.pde
  mainLoop();
}

void loop()
{
}

