/*
|| LyteWall controller receiver
*/

serial <- hardware.uart57;
led <- hardware.pin9;
const repeatTime = 5;

led.configure(DIGITAL_OUT);

function sendKey(data)
{
  server.log("Device got: " + data);
  switch (data)
  {
    case "Up":
      serial.write("\x1b\x5b\x41");
      break;
    case "Down":
      serial.write("\x1b\x5b\x42");
      break;
    case "Left":
      serial.write("\x1b\x5b\x44");
      break;
    case "Right":
      serial.write("\x1b\x5b\x43");
      break;
    case "Start":
      serial.write(" ");
      break;
    default:
      // nothing
      break;
  }
}

function blinkLED()
{
  LEDon();
  imp.wakeup(1.0, LEDoff);
  imp.wakeup(repeatTime, blinkLED);
}


function LEDon()
{
  setLED(1);
}

function LEDoff()
{
  setLED(0);
}

function setLED(ledState)
{
  //server.log("Set LED: " + ledState);
  led.write(ledState);
}


function readSerial()
{
  //local byte = serial.read();
  //while
}

function initUart()
{
  hardware.uart57.configure(115200, 8, PARITY_NONE, 1, NO_CTSRTS, readSerial);
}


//////////////////////////////////////////////////

initUart();
agent.on("SendKey", sendKey);
blinkLED();
