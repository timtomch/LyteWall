/*
|| LyteWall Controller Input Agent
*/

const html = @"
<!doctype html>
<html>
<head>
<title> Site 3 Pixel Wall | Tetris </title>
<style type='text/css'>
html, body, #wrapper {
  height:100%;
  margin: 0;
  padding: 0;
  border: none;
  text-align: center;
}
#wrapper {
  background-color: #ffffff;
  margin: 0 auto;
  text-align: center;
  color: #ffffff;
  vertical-align: middle;
  width: 100%;
}
.butt {
  background-color:#00ff00;
  color: #000000;
}
</style>
<script>
  function sendToImpAgent(value)
  {
    var url = ""http://agent.electricimp.com/ArIBV6u53ILd"";
    url = url + ""?key="" + encodeURIComponent(value);

    if (window.XMLHttpRequest)
    {
      devInfoReq = new XMLHttpRequest();
    }
    else
    {
      devInfoReq = new ActiveXObject(""Microsoft.XMLHTTP"");
    }
    try
    {
      devInfoReq.open('GET', url, true);
      devInfoReq.send();
    }
    catch (err)
    {
      console.log('Error parsing device info from imp');
    }
  }
</script>
</head>
<body>
  <table border=""0"" id=""wrapper"">
    <tr>
      <td>0</td>
      <td class=""butt"" onclick=""sendToImpAgent('Up')"">U</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <td class=""butt"" onclick=""sendToImpAgent('Left')"">L</td>
      <td>0</td>
      <td class=""butt"" onclick=""sendToImpAgent('Right')"">R</td>
      <td>0</td>
      <td class=""butt"" onclick=""sendToImpAgent('Start')"">O</td>
      <td>0</td>
      <td class=""butt"" onclick=""sendToImpAgent('Start')"">X</td>
    </tr>
    <tr>
      <td>0</td>
      <td class=""butt"" onclick=""sendToImpAgent('Down')"">D</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
  </table>
</body>
</html>
";

function requestHandler(request, response)
{
  try
  {
    if ("key" in request.query)
    {
      local message = request.query.key;
      
      if (message.len() > 40)
      {
        server.log("Trimming message.");
        message = message.slice(0, 40);
      }

      switch (message)
      {
        case "Up":
        case "Down":
        case "Left":
        case "Right":
        case "Start":
          server.log("Got: " + message);
          device.send("SendKey", message)
          break;
        default:
          // ignore
          server.log("WTF: " + message);
          break;
      }

      // send a response back saying everything was OK.
      response.send(200, "OK");
    }
    else
    {
      response.send(200, html);
    }
  }
  catch (ex)
  {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
// register the HTTP handler
http.onrequest(requestHandler);
