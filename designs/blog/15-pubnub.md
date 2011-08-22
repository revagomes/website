# Countdown to KO #15: Publish/Subscribe with PubNub

*This is the 15th in series of posts leading up [Node.js Knockout][1],
and covers using [PubNub][] in your node app.*

[1]: http://nodeknockout.com
[PubNub]: http://www.pubnub.com

[PubNub][] lets you connect mobile phones, tablets, web browsers and more
with a 2 Function Publish/Subscribe API (send/receive).

## HTML Interface

If you are building HTML5 Web Apps, start by copying and pasting the
code snippet below. If not, skip to [Other Languages][].

    <div pub-key="demo" sub-key="demo" id="pubnub"></div>
    <script src="http://cdn.pubnub.com/pubnub-3.1.min.js"></script>
    <script>(function(){

        // Listen For Events
        PUBNUB.subscribe({
            channel  : "hello_world",      // Channel
            error    : function() {        // Lost Connection (auto reconnects)
                alert("Connection Lost. Will auto-reconnect when Online.")
            },
            callback : function(message) { // Received An Event.
                alert(message.anything)
            },
            connect  : function() {        // Connection Established.

                // Send Message
                PUBNUB.publish({
                    channel : "hello_world",
                    message : { anything : "Hi from PubNub." }
                })

            }
        })

    })();</script>

<h2 id="pubnub-other-languages">Other Languages</h2>

Follow the instructions linked below to use PubNub APIs from other
programming languages: **[Node][]**, [Ruby][], [PHP][], [Python][],
[Perl][], [Erlang][] and [more programming languages on GitHub][].

[Other Languages]: #pubnub-other-languages
[Node]: https://github.com/pubnub/pubnub-api/tree/master/nodejs
[Ruby]: https://github.com/pubnub/pubnub-api/tree/master/ruby
[PHP]: https://github.com/pubnub/pubnub-api/tree/master/php
[Python]: https://github.com/pubnub/pubnub-api/tree/master/python
[Perl]: https://github.com/pubnub/pubnub-api/tree/master/perl5
[Erlang]: https://github.com/pubnub/pubnub-api/tree/master/erlang
[more programming languages on GitHub]: https://github.com/pubnub/pubnub-api
