# Countdown to KO #13: Build Phone and SMS Apps with Tropo and Node.js

*This is the 13th in series of posts leading up [Node.js Knockout][1],
and covers using [Tropo][] in your node app.*

[1]: http://nodeknockout.com
[Tropo]: http://www.tropo.com

[Tropo][] is a multi-channel communication platform that lets you build
Phone, SMS and IM apps - all using the same Node.js codebase.

On the phone side, Tropo integrates with SIP (the industry standard for
VoIP telephony) and Skype. On the SMS side, Tropo supports sending
inbound and outbound text messages from both U.S. and Canadian numbers.
(It's also possible to send to [a host of international destinations][]
from U.S. numbers.)

[a host of international destinations]: https://www.tropo.com/docs/webapi/international_dialing_sms.htm

Tropo is 100% free for development use - no upfront commitments and no
strings attached.  [Signing up for an account][] is free, and you can
deploy phone and SMS numbers for free in development (we have tons in
both the US and Canada).  We won't ask you for payment information until
you're ready to deploy your application to production.

[Signing up for an account]: https://www.tropo.com/account/register.jsp

For Node.js developers, getting started using Tropo to build powerful
communication apps is as simple as installing the Tropo Node.js module.

    npm install tropo-webapi

Your Node.js application will interact with the Tropo platform by
consuming and generating JSON that is delivered over HTTP.  It's simple
to use a Node-based web server for this:

    var TropoWebApi = require('tropo-webapi').TropoWebAPI;
    var http = require('http');

    var server = http.createServer(function (request, response) {

      var tropo = new TropoWebAPI();
      tropo.say("Hello, World!");
      response.writeHead(200, {'Content-Type': 'application/json'});
      response.end(TropoJSON(tropo));

    }).listen(8000);

This simple web server listening on port 8000 will respond to incoming
HTTP requests (Tropo uses the POST method to to connect to your app)
with the following JSON:

    {"tropo":[{ "say":{"value":"Hello, World!" }}]}

When a user makes a phone call to this app, Tropo to output the phrase
"Hello, World" via Text-to-Speech (TTS) with the standard TTS engine.
One of the really nice features is that we support TTS in [multiple
languages][] - 24 in all - so if your app has an international audience,
Tropo is a logical fit.

[multiple languages]: https://www.tropo.com/docs/webapi/international_speaking_other_languages.htm

Now lets look at a slightly more advanced example:

    var TropoWebApi = require('tropo-webapi').TropoWebAPI;
    var express = require('express');

    var port = process.ARGV[2] || 8000;
    var app = express.createServer();

    // Required to process the body of HTTP responses from Tropo.
    app.configure(function(){
      app.use(express.bodyParser());
    });

    // Base route, plays welcome message.
    app.post('/', function(req, res){
      var tropo = new TropoWebAPI();

      tropo.say("Welcome to the Tropo Web API node demo.");
      tropo.on("continue", null, "/start", true);
      res.send(TropoJSON(tropo));

    });

    // Route to start asking caller for selection.
    app.post('/start', function(req, res){

      var tropo = new TropoWebAPI();

      // Set up options for question to ask caller.
      var choices = new Choices("Node JS, PHP, Ruby, Python, Scala");
      var attempts = 3;
      var bargein = false;
      var minConfidence = null; // Use the platform default.
      var name = "test";
      var recognizer = "en-us";
      var required = true;
      var say = new Say("What is your favorite programming language?");
      var timeout = 5;
      var voice = "Allison";
      tropo.ask(choices, attempts, bargein, minConfidence, name, recognizer, required, say, timeout, voice);

      tropo.on("continue", null, "/answer", true);
      tropo.on("error", null, "/error", true);
      res.send(TropoJSON(tropo));

    });

    // Route to handle valid answers.
    app.post('/answer', function(req, res){

      var tropo = new TropoWebAPI();
      var selection = req.body['result']['actions']['value'];
      tropo.say('You chose, ' + selection + '. Thanks for playing.');
      tropo.hangup();
      res.send(TropoJSON(tropo));

    });

    // Route to handle errors or invalid responses.
    app.post('/error', function(req, res){

      var tropo = new TropoWebAPI();
      tropo.say("Whoops, something bad happened. Please try again later.");
      res.send(TropoJSON(tropo));

    });

    app.listen(port);
    console.log('Tropo demo running on port: ' + port);

Since interaction with the Tropo platform occurs via HTTP, Tropo apps
are a great fit for the Express Framework.  When you [create your Tropo
application][], simply set the URL to this app - wherever it happens to be
running - as the application start URL.

[create your Tropo application]: https://www.tropo.com/docs/webapi/creating_first_app.htm

This sample application has 4 basic steps:

* A welcome message.
* An input collection segment, where the caller is asked to name their
  favorite programming language.
* An input inspection segment, where the value of the caller's input is
  simply read back to them.
* An error handler to tell the user if an error occurs (always a good
  idea in phone applications).

At the end of each segment, JSON is rendered in the HTTP response and
sent to Tropo.  This rendered JSON is used to interact with the user on
whatever channel they have chosen to connect to your application with.

You may notice the following code in the input collection segment:

    var choices = new Choices("Node JS, PHP, Ruby, Python, Scala");

This is the list of choices that the user may select from - if the user
calls your application, they will make their selection using their
voice.  One of the unique features of Tropo is the ability to support
speech recognition.  This functionality is available to all applications
that need it at no additional cost.

When the user makes their selection, it is sent via HTTP POST to the
input inspection segment, and read back to the caller.  If the user
happens to connect to your application via SMS or IM, the result will be
delivered on those channels.  That's it! No additional code needed -
Tropo apps are born to work on multiple channels.

Tropo's unique features are perfect for simply building powerful,
multi-channel applications that are fully interoperable with the latest
telephony and communication standards.

Together, Tropo and Node.js are a knockout.
