# Countdown to KO #18: Load Testing with blitz.io

*This is the 18th in series of posts leading up [Node.js Knockout][1],
and covers using [blitz.io][] to load test your node app.*

[1]: http://nodeknockout.com
[blitz.io]: http://blitz.io

## What's [blitz.io][]?

![blitz.io](http://blitz.io/images/logo2.png)

[blitz.io][], powered by Mu Dynamics, is a self-service load and
performance testing platform. Built for API, cloud, web and mobile
application developers, [blitz.io][] quickly and inexpensively helps you
ensure performance and scalabilty. And we make this super fun.

## Why Load Test?

Node.js is purdy fast, but if you are not careful in the way you invoke
backend services like CouchDB or MongoDB, you can easily cause pipeline
stall making your app not scale to a large number of users. Typically
you will end up with each concurrent request taking longer and longer
resulting in timeouts and fail whales. Load testing shows you what kind
of concurrency you can achieve with your app and how it's actually
scaling out.

## Signing up

Go to our [login page](https://secure.blitz.io/login) and use your
Facebook or Google accounts to login in with just 2 clicks. As simple as
that. You will immediately be able to run load test against your app
from the blitz bar.

## Running a Load Test (rush)

If your app is at `http://my.cool.app`, the following blitz line will
generate concurrent hits against your app:

    --pattern 1-250:60 --region virginia http://my.cool.app

As simple as that. If your `express` and `connect` routes have
parameters in them that you use for looking up in your favorite
database, you can [read up on variables](http://docs.blitz.io/variables)
to parameterize query arguments and route paths so you can simulate
production workloads on your app.

## During the Node.js Knockout

We are super excited about sponsoring [Node.js Knockout][1] and have
[something fun planned](http://blitz.io/events/nodeknockout).

At the start of the event, we are providing all contestants with enough
blitz-power so you can generate lots of hits against your cool node.js
app for 48 hours. We are also working on a scoreboard so you get
bragging rights on the app with the most number of hits. Watch this page
at the start of the event and you'll know what to do.

**[Check it out!](http://blitz.io/events/nodeknockout)**

## Command-Line Testing

For those developers that don't like UI and prefer command line, here's
the simplest way to run iterative load tests right after you `git push`
your changes to the app:

    $ gem install blitz
    $ blitz api:init
    $ blitz curl --pattern 1-250:60 --region virginia http://my.cool.app

To build cool node.js apps is awesome, to watch it scale out? priceless!
