/*
|| LyteWall Controller Input Agent
*/

function requestHandler(request, response)
{
  try
  {
    if ("key" in request.query)
    {
      switch (request.query.key)
      {
        case "Up":
        case "Down":
        case "Left":
        case "Right":
        case "Start":
          server.log("Got: " + request.query.key);
          device.send("SendKey", request.query.key)
          break;
        default:
          // ignore
          server.log("WTF: " + request.query.key);
          break;
      }
    }
    // send a response back saying everything was OK.
    response.send(200, "OK");
  }
  catch (ex)
  {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
// register the HTTP handler
http.onrequest(requestHandler);

