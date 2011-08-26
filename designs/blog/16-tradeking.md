# Countdown to KO #16: TradeKing

*This is the 16th in series of posts leading up [Node.js Knockout][1],
and covers using [TradeKing][] in your node app.*

[1]: http://nodeknockout.com
[TradeKing]: http://tradeking.com

At TradeKing, we've all been infatuated with Node.  From its inception
we've been touting its swift performance, reasonable learning curve, and
its particular ability to add a completely new dimension to web
applications.

While developing the API we were always thinking about the angles
developers might use to create riveting new experiences for traders, and
many of those angles have a very common intersection: real-time.
Whether it's streaming market data or interactive real-time charting,
the financial industry moves incredibly quick and requires web
technologies to match its pace.  Node combines perfectly with web
sockets allowing us to meet those needs in a very agile way.  The latest
of which was a quick mashup demo for an internal board meeting.

Here is a quick tutorial of how we got Node and Sockets working with our
API in a demo watchlist application.  The idea: a streaming watchlist
tool that integrates with Twitter.  What's a watchlist?  Think of it as
an interactive list of stocks you might hold or be interested in
holding.

![TradeKing Screenshot](https://s3.amazonaws.com/2011.nodeknockout.com/TradeKing_Watchlist_Mashup1.jpg)

## Installation

First things first, grab the project repository from
<http://github.com/tradeking/node-watchlist>.  Once you clone that
locally, hop in the new repository and run `npm install` to grab all the
projects dependencies.

## Configuration

Crack open the server.js file and fill in the configuration here:

    // Configuration!
    global.tradeking = {
      api_url: "https://api.tradeking.com/v1",
      consumer_key: "",
      consumer_secret: "",
      access_token: "",
      access_secret: ""
    }
    global.twitter_user = {
      consumer_key : '',
      consumer_secret : '',
      access_token_key : '',
      access_token_secret : ''
    }

You can get all of your TradeKing keys at
<https://developers.tradeking.com> by creating a developer application.
Create a Twitter application (<http://dev.twitter.com>) to get those keys
as well.

## Authentication

The TradeKing API uses OAuth authentication so it was a snap to start
talking to the API and there was no shortage of Twitter modules to snag
their stream.  Since we've supplied all of our keys, we don't need the
full flow so we'll just setup the consumer and bring our own access
tokens to the table (see the next step).

    global.tradeking_consumer = new oauth.OAuth(
      "https://developers.tradeking.com/oauth/request_token",
      "https://developers.tradeking.com/oauth/access_token",
      tradeking.consumer_key,
      tradeking.consumer_secret,
      "1.0",
      "http://localhost:3000/tradeking/callback",
      "HMAC-SHA1");

    global.twitter_consumer = new oauth.OAuth(
      "https://twitter.com/oauth/request_token",
      "https://twitter.com/oauth/access_token",
      twitter_user.consumer_key,
      twitter_user.consumer_secret,
      "1.0A",
      null,
      "HMAC-SHA1");

## Making Requests to TradeKing

Now that the consumer is set up, making requests is a breeze!

    tradeking_consumer.get(
      tradeking.api_url+'/market/quotes.json?watchlist=DEFAULT&delayed=false',
      tradeking.access_token,
      tradeking.access_secret,
      function(error, data, response) {
        quotes = JSON.parse(data);
        if(quotes.response.type != "Error") {
          client.emit('watchlist-quotes', quotes.response.quotes.instrumentquote);
        }
      }
    );

This bit of code makes a GET request to a specified URL and using our
access token/secret.  Once completed the callback is executed.  In this
particular instance we are parsing the returned JSON data, checking for
errors, and then sending a socket event to the client.

## Want to know more?

Since we've open sourced the whole application and slapped it up on
Github, pull it down, throw your keys in and check out how it all works
— maybe even make some upgrades and submit a pull request! Head over to
our forums to see what the rest of the devs are up to or to drop us a
note about your progress with the API.

**Online trading has inherent risk due to system response and access
times that may vary due to market conditions, system performance, and
other factors. An investor should understand these and additional risks
before trading.***

&copy; 2011 TradeKing. All rights reserved. Member <a
href="http://www.finra.org/">FINRA</a> and <a
href="http://www.sipc.org/">SIPC</a>
