/*
|| @author         Brett Hagman <bhagman@wiring.org.co>
|| @url            http://wiring.org.co/
|| @url            http://roguerobotics.com/
||
|| @description
|| |
|| | Basic Serial Message Protocol
|| |
|| | Written by Brett Hagman
|| | http://www.roguerobotics.com/
|| | bhagman@roguerobotics.com, bhagman@wiring.org.co
|| |
|| | A very basic serial message protocol handler.
|| |
|| #
||
|| @license Please see the accompanying LICENSE.txt file for this project.
||
|| @name Serial Message Protocol Handler
|| @type Support Sketch
|| @target Target Independent
||
|| @version 1.0.0
||
*/

#define SERIALMESSAGE_VERSION 10000

#define SerialIn Serial

#define MAX_BUFFER 128

#define SOM 0xaa
#define EOM 0x55

#define ST_START       0
#define ST_GET_LENGTH  1
#define ST_GET_LENGTH2 2
#define ST_GET_DATA    3
#define ST_GET_EOM     4
#define ST_COMPLETE    5
#define ST_MSG_ERROR   6

#define DEBUG 0

//uint16_t errorCountMissedSOM = 0;
uint8_t msgBuffer[MAX_BUFFER];

bool getByte(uint8_t *c)
{
  uint32_t start = millis();

  while (!SerialIn.available())
  {
    if ((millis() - start) > 200)
      return false;
  }
  *c = SerialIn.read();
  return true;
}

inline void putByte(uint8_t c)
{
  SerialIn.write(c);
}

int16_t getMessage(void)
{
  uint8_t msgParseState;
  uint16_t msgLength = 0;
  uint16_t i = 0;
  uint8_t c;

  msgParseState = ST_START;
//  errorCountMissedSOM = 0;

  while ((msgParseState != ST_COMPLETE) && (msgParseState != ST_MSG_ERROR))
  {
    if (!getByte(&c))
    {
#if DEBUG
      Serial.println(Constant("Timeout waiting"));
#endif
      continue;
    }

#if DEBUG
//Serial.print(c, HEX);
//Serial.print(' ');
#endif

    switch (msgParseState)
    {
      case ST_START:
        if (c == SOM)
          msgParseState = ST_GET_LENGTH;
//        else
//          errorCountMissedSOM++;
        break;

      case ST_GET_LENGTH:
        msgLength = (uint16_t)c << 8;
        msgParseState = ST_GET_LENGTH2;
        break;

      case ST_GET_LENGTH2:
        msgLength += c;
        if (msgLength == 0)
          msgParseState = ST_GET_EOM;
        else
          msgParseState = ST_GET_DATA;
        break;

      case ST_GET_DATA:
        // kluge - stuff directly into strand buffer

        if (i == 0) // we need to have our first byte so we can test the msgLength
        {
          msgBuffer[i] = c;

          // kluge to check msgLength AFTER we get the first char
          if (c == 'R')
          {
            if (msgLength - 1 > numLEDs * 3)
              msgParseState = ST_MSG_ERROR;
          }
          else
          {
            if (c == 'r')
            {
              if (msgLength - 1 > numLEDs)
                msgParseState = ST_MSG_ERROR;
            }
            else
            {
              if (msgLength > (MAX_BUFFER - 4))
                msgParseState = ST_MSG_ERROR;
            }
          }
        }
        else
        {
          // now we have the first byte
          if (msgBuffer[0] == 'R' || msgBuffer[0] == 'r')
            strandData[i - 1] = c;
          else
            msgBuffer[i] = c;
        }

        i++;

        if (i == msgLength)
          msgParseState = ST_GET_EOM;

        break;

      case ST_GET_EOM:
        if (c == EOM)
          msgParseState = ST_COMPLETE;
        else
          msgParseState = ST_MSG_ERROR;
#if DEBUG
        Serial.println();
#endif
        break;

    } // switch
  } // while (msgParseState)

  if (msgParseState == ST_COMPLETE)
    return msgLength;
  else
    return -1;
}


void putMessage(uint8_t data[], uint16_t length)
{
  uint8_t i;

  if (length > 256)
    length = 256;
  putByte(SOM);
  putByte(length);
  i = 0;
  while (i < length)
    putByte(data[i++]);
  putByte(EOM);
}

