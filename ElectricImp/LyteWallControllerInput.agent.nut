/*
|| LyteWall Controller Input Agent
*/

ipaddy <- "unknown";

function serverLog(s)
{
  server.log("[" + ipaddy + "]: " + s);
}

function requestHandler(request, response)
{
  //local ipaddy = "";
  if ("x-real-ip" in request.headers)
  {
    ipaddy = request.headers["x-real-ip"];
  }
  else
  {
    ipaddy = "unknown";
  }

  try
  {
    if ("key" in request.query)
    {
      local message = request.query.key;
      
      if (message.len() > 40)
      {
        //server.log("Trimming message.");
        serverLog("Trimming message.");
        message = message.slice(0, 40);
      }

      switch (message)
      {
        case "Up":
        case "Down":
        case "Left":
        case "Right":
        case "Start":
          serverLog("Got: " + message);
          device.send("SendKey", message)
          break;
        default:
          // ignore
          serverLog("WTF: " + message);
          break;
      }

      // send a response back saying everything was OK.
      response.send(200, "OK");
    }
    else
    {
      response.header("Location", "http://www.googledrive.com/host/0BxcFNQX9fJt9QWROTjhraWVDX2c");
      response.send(301, "");
      serverLog("Sending redirect");
    }
  }
  catch (ex)
  {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
// register the HTTP handler
http.onrequest(requestHandler);
