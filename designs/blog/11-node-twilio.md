# Countdown to KO #11: Node Twilio

*This is the 11th in series of posts leading up [Node.js Knockout][1],
and covers using [Twilio][] in your node app.*

[1]: http://nodeknockout.com
[Twilio]: http://www.twilio.com

For this example we'll be using the node-twilio helper library by
[Stephen Walters][] to get you started with the basics of initiating a
call and then answering it.

[Stephen Walters]: https://github.com/sjwalter

Start off by installing node-twilio using npm:

    $ npm install twilio

Parts of node-twilio depend on the [express][] framework so you should
install express now too if you haven't already:

[express]: http://expressjs.com/

    $ npm install express

Once you've gotten your environment setup for node development, you'll
need to sign up for a [Twilio][] account if you don't already have one.
This will give you a Twilio Account Sid and an Auth Token which you'll
need to develop your application.

## Creating the call object

First, require:

    var TwilioClient = require('twilio').Client,
          Twiml = require('twilio').Twiml,
          sys = require('sys');

Next, instantiate a TwilioClient object:

    var client = new TwilioClient('MY_ACCOUNT_SID', 'MY_AUTH_TOKEN', 'MY_HOSTNAME');

Pretty easy, right? Let's use this client to create a PhoneNumber
object:

    var phone = client.getPhoneNumber('+1###########');

The ########### will be your Twilio number that you have purchased and
own. Now that you've gotten a phone number with the client, let's have
it make a call.

To do that, you use the `setup()` method to make a request to Twilio's
REST API. Once it's done with all that, it calls a callback function
with no parameters. After that, you're ready to make a phone call with
the `PhoneNumber` object's `makeCall` method.

    phone.setup(function() { phone.makeCall('+15555555555', null, function(call) {});

The `makeCall` method accepts three paremeters:

* The phone number to dial</li>
* a map of options</li>
* a callback function.</li>

The argument to the callback is an `OutgoingCall` object. This object
emits two events:

* `'answered'`
* `'ended'`

So you can listen for those events, and then respond to them
appropriately.

Here's an example of how you can listen for the `'answered'` event and
then use `'response'` to tell your buddy to meet you for drinks later.

    phone.setup(function() {
        phone.makeCall('+15555555555', null, function(call) {
            call.on('answered', function(callParams, response) {
                response.append(new Twiml.Say('Hey buddy. Let's meet for drinks later tonight.'));
                response.send();
            });
        });
    });

The `'answered'` event handler accepts two arguments

* `callParams`
* `response.callParams`

For outgoing calls, Twilio requests your handler URI which contains
information like CallSid, CallStatus, and more. [Twilio's Request
documentation][2] has more more details on this. The response argument
of the `'answered'` event is a `Twiml.Response` object. See [The TwiML
Interface][3] for more details on valid responses that can be sent on
Twilio.

[2]: http://www.twilio.com/docs/api/2010-04-01/twiml/twilio_request
[3]: https://github.com/sjwalter/node-twilio/wiki/The-twiml-interface
