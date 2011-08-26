# Countdown to KO #24: Pusher Pipe

# Early access program for the Pusher Pipe

In case you haven't heard of Pusher before, we are a hosted service for adding realtime features quickly and easily to your web and mobile applications. Our main transport mechanism is WebSockets, and we think WebSockets are the bomb. 

We have specialised in building a scalable infrastructure that can handle tons of connections, and making it easily accessible to developers. Our aim is to allow people to focus on building awesome stuff, rather than figuring out how to build distributed asynchronous systems.

The traditional mechanism for interacting with our service has been through a REST API. However, we have recently been working on a new interface that allows much deeper integration with the service. The working name for it is the Pusher Pipe, and we are allowing some early access during Node Knockout for people who are interested in giving it a spin.

## What is this Pipe?

The Pusher Pipe allows you to create a single bi-directional connection to our service, which relays messages to and from your end users, as well as information about how and when they are connecting. You could think of our Pipe as a cloud-based WebSocket loadbalancer/multiplexer, but with an awesome Node.js library to go with it. 

Maybe you like deploying your Node.js code to Heroku, but their lack of WebSocket support makes you cry?

# Getting started

1. install the npm module:

		npm install pusher-wsapi

2. Make a file called test.js, put in the following code (with your api keys) and run it

		var Pusher = require('pusher-wsapi');

		var pusher = Pusher.createClient({
		  key: 'yourkeycbfc8e5c02e22',
		  secret: 'yoursecretc1d6a1b4b',
		  app_id: 4,
		  debug: true
		});

3. create an html page with this in it (substituting your keys)

		<html>
		<head>
			<script type="text/javascript" src="http://js.pusherapp.com/1.10.0-pre/pusher.min.js"></script> 
			<script type="text/javascript">
				Pusher.host = "ws.darling.pusher.com"
				Pusher.log = function(message) {
				  if (window.console && window.console.log) window.console.log(message);
				};
				var pusher = new Pusher('cbfc8e5c02e22cd6307a')
			</script>
		</head>
		</html>

4. Open up your html page in a browser and look at the output of your node process. You should see a new client connect!

5. Add the following to your node script and restart it:

		pusher.sockets.on('event:eventFromBrowser', function(socket_id, data){
			pusher.socket(socket_id).trigger('acknowledge', {message: 'Rodger'})
		})

6. Refresh your html page, and open up a javascript console. Type in the following and hit return:

		pusher.back_channel.trigger('eventFromBrowser', {some: 'data'})

## WTF just happened?

* The html page that you created established a connection to Pusher. 
* Pusher told your node process that there was a new connection (as shown in the debug output)
* The browser connection sent an event to Pusher that was relayed to the node process
* The node process responded to the event and sent it back to the browser via Pusher
A more detailed reference is also available in our [overview](http://pusher-static-staging.heroku.com/docs/pipe).

## How can I kick the tyres?

To get involved, you'll need to be invited by us, so get in touch with [support@pusher.com](mailto:support@pusher.com) if you want access. 

## This is alpha software

The Pipe is not deployed to our production cluster, and we are actively looking for feedback at this stage. You may find that it works awesomely -- some sample apps we built this week went swimmingly. However, it may blow up and kill your kitten. You can decide on the level of risk you prefer.