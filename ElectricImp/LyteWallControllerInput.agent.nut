/*
|| LyteWall Controller Input Agent
*/

const html = @"
<!doctype html>
<html>
<head>
<title> Site 3 Pixel Wall | Tetris </title>
<link href='http://fonts.googleapis.com/css?family=Audiowide' rel='stylesheet' type='text/css'>
<style type='text/css'>
<!--
article,aside,details,figcaption,figure,footer,header,hgroup,main,nav,section,summary{display:block;}
audio,canvas,video{display:inline;zoom:1;}
audio:not([controls]){display:none;height:0;}
[hidden]{display:none;}
html{font-size:100%;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;}
html,button,input,select,textarea{font-family:sans-serif;}
a:focus{outline:thin dotted;}
a:active,a:hover{outline:0;}
h1{font-size:2em;margin:.67em 0;}
h2{font-size:1.5em;margin:.83em 0;}
h3{font-size:1.17em;margin:1em 0;}
h4{font-size:1em;margin:1.33em 0;}
h5{font-size:.83em;margin:1.67em 0;}
h6{font-size:.67em;margin:2.33em 0;}
abbr[title]{border-bottom:1px dotted;}
b,strong{font-weight:bold;}
blockquote{margin:1em 40px;}
dfn{font-style:italic;}
hr{-moz-box-sizing:content-box;box-sizing:content-box;height:0;}
mark{background:#ff0;color:#000;}
code,kbd,pre,samp{font-family:monospace, serif;_font-family:'courier new', monospace;font-size:1em;}
pre{white-space:pre-wrap;word-wrap:break-word;}
q{quotes:none;}
q:before,q:after{content:none;}
small{font-size:80%;}
sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline;}
sup{top:-.5em;}
sub{bottom:-.25em;}
dd{margin:0 0 0 40px;}
menu,ol,ul{padding:0 0 0 40px;}
nav ul,nav ol{list-style:none;list-style-image:none;}
img{border:0;-ms-interpolation-mode:bicubic;}
svg:not(:root){overflow:hidden;}
fieldset{border:1px solid #c0c0c0;margin:0 2px;padding:.35em .625em .75em;}
legend{border:0;white-space:normal;margin-left:-7px;padding:0;}
button,input,select,textarea{font-size:100%;vertical-align:middle;margin:0;}
button,input{line-height:normal;}
button,select{text-transform:none;}
button,html input[type=button],/* 1 */
input[type=reset],input[type=submit]{-webkit-appearance:button;cursor:pointer;overflow:visible;}
button[disabled],html input[disabled]{cursor:default;}
input[type=checkbox],input[type=radio]{box-sizing:border-box;height:13px;width:13px;padding:0;}
input[type=search]{-webkit-appearance:textfield;-moz-box-sizing:content-box;-webkit-box-sizing:content-box;box-sizing:content-box;}
input[type=search]::-webkit-search-cancel-button,input[type=search]::-webkit-search-decoration{-webkit-appearance:none;}
button::-moz-focus-inner,input::-moz-focus-inner{border:0;padding:0;}
textarea{overflow:auto;vertical-align:top;}
table{border-collapse:collapse;border-spacing:0;}
body,figure,form{margin:0;}
p,pre,dl,menu,ol,ul{margin:1em 0;}
-->
</style>
<style type='text/css'>
<!--
#gameboy{width:320px;height:480px;margin-left:auto;margin-right:auto;margin-top:1%;border:1px white solid;border-radius:10px;border-bottom-right-radius:4em;background-image:url(http://oi60.tinypic.com/rjdw7q.jpg);background-color:#C7C4BD;background-size:320px 480px;background-position:center;}
#screen{width:250px;height:200px;border:solid 1px black;border-radius:5%;background-image:url(http://oi61.tinypic.com/w7fzgh.jpg);background-size:250px 200px;background-position:center;margin:40px auto;}
#cross{float:left;height:100px;width:92px;display:inline-block;text-align:center;margin-left:40px;}
.updown,.updown:active{border-radius:0;width:29px;height:31px;color:#555;background-color:black;border:black 1px solid;}
.updown:hover,.leftright:hover{background-color:#222;}
.leftright,.leftright:active{border-radius:0;width:46px;height:28px;color:#555;background-color:black;border:black 1px solid;box-shadow:2px 2px 0 #444;}
#left{float:left;border-top-left-radius:15%;border-bottom-left-radius:15%;text-align:left;background-image:url(http://oi62.tinypic.com/k4grhf.jpg);background-size:16px 16px;background-position:left center;background-repeat:no-repeat;}
#right{border-bottom-right-radius:15%;border-top-right-radius:15%;text-align:right;background-image:url(http://oi60.tinypic.com/9fp4ko.jpg);background-size:16px 16px;background-position:right center;background-repeat:no-repeat;}
#up{border-top-left-radius:15%;border-top-right-radius:15%;box-shadow:2px 0 #444;background-image:url(http://oi61.tinypic.com/2lt6fyq.jpg);background-size:16px 16px;background-position:top center;background-repeat:no-repeat;}
#down{border-bottom-left-radius:15%;border-bottom-right-radius:15%;box-shadow:2px 2px #444;background-image:url(http://oi61.tinypic.com/30a55cg.jpg);background-size:16px 16px;background-position:bottom center;background-repeat:no-repeat;}
#ab{float:right;text-align:center;margin-right:50px;margin-top:0;transform:rotate(-20deg);-ms-transform:rotate(-20deg);-webkit-transform:rotate(-20deg);padding:15px 0;}
.ab,.ab:active{border-radius:100%;width:38px;height:38px;color:#ccc;background-color:#F21339;border:#AF1330 1px solid;box-shadow:2px 2px #888888;font-family:Audiowide, sans-serif;font-size:12px;}
.ab:hover{background-color:#D61334;}
#a{margin-left:10px;}
#start{margin-left:auto;margin-right:130px;clear:both;text-align:center;float:right;}
#select{margin-left:110px;margin-right:auto;clear:left;text-align:center;float:left;}
.start,.start:active{border-radius:35%;width:30px;height:10px;color:#777;background-color:#777;border:#444 1px solid;box-shadow:2px 2px #888888;transform:rotate(-20deg);-ms-transform:rotate(-20deg);-webkit-transform:rotate(-20deg);margin:10px 0 0 5px;}
.start:hover{background-color:#888;}
.label{font-family:Audiowide, sans-serif;font-size:10px;transform:rotate(-20deg);-ms-transform:rotate(-20deg);-webkit-transform:rotate(-20deg);}
-->
</style>
<script>
  function sendToImpAgent(value)
  {
    var url = document.URL;
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
<section>
<div id = ""gameboy"">
<div id = ""screen"">
</div>
<div id = ""cross"">
<div><input type=""button"" id = ""up"" class = ""updown"" value="" "" onclick=""sendToImpAgent('Up')"" /></div>
<div><input type=""button"" id = ""left"" class = ""leftright"" value="" "" onclick=""sendToImpAgent('Left')"" />
<input type=""button"" id = ""right"" class = ""leftright"" value="" "" onclick=""sendToImpAgent('Right')"" /></div>
<span><input type=""button"" id = ""down"" class = ""updown"" value="" "" onclick=""sendToImpAgent('Down')"" />
</div>
<div id = ""ab"">
<input type=""button"" class = ""ab"" id = ""b"" value=""B"" onclick=""sendToImpAgent('Up')"" />
<input type=""button"" class = ""ab"" id = ""a"" value=""A"" onclick=""sendToImpAgent('Up')"" />
</div>
<div id = ""start"">
<input type=""button"" class = ""start"" value=""Start"" onclick=""sendToImpAgent('Start')"" />
<div class = ""label"">Start</div> </div>
<div id = ""select"">
<input type=""button"" class = ""start"" value=""Select"" onclick=""sendToImpAgent('Start')"" />
<div class = ""label"">Select</div></div>
</div>
</div>
</section>
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
