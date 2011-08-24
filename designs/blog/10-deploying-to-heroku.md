# Countdown to KO #10: Deploying Your Node.js App to Heroku

*This is the 10th in series of posts leading up [Node.js Knockout][1],
and covers deploying your Node.js app to the [Heroku][2] platform.*

[1]: http://nodeknockout.com
[2]: http://heroku.com

Heroku is a platform that lets you deploy your Node.js app instantly,
without needing to deal with servers or systems administration.   The
recently-released [Celadon Cedar][3] stack supports Node.js (alongside
other languages such as Ruby and Clojure).  You can also use backing
services such as SQL or NoSQL databases, memcached, and [many others
available as add-ons][4].  Manage everything from the Heroku
command-line tool, and deploy your code using Git.

This post will get you going with a Node.js/[Express][5] app on Heroku
Cedar.

[3]: http://blog.heroku.com/archives/2011/5/31/celadon_cedar/
[4]: http://addons.heroku.com/
[5]: http://expressjs.com/

Sign Up for a Heroku Account
-------------------------

If you don't already have a Heroku account, visit [the signup page][6]
to create an account.  It's free and just takes a minute.  Once you sign
up, you'll receive an invitation email that will allow you to set your
password.

Even if you don't sign up for a heroku account, you'll get an invitation before the competition starts to join an app created by the Knockout organizers. __If using Heroku, this will be the app that you should deploy to for the competition.__

[6]: https://api.heroku.com/signup

Install the Heroku Command-line Client
--------------------------------------

If you have Rubygems on your system, you can install the Heroku client
with:

    $ gem install heroku

Otherwise, download [this tarball][7], extract it, and put the resulting
directory into your `$PATH`:

    $ wget http://assets.heroku.com/heroku-client/heroku-client.tgz
    Saving to: `heroku-client.tgz'
    100%[==================================================================>] 412,661      535K/s   in 0.8s

    $ tar xzf heroku-client.tgz && echo "Add $PWD/heroku-client to your \$PATH."
    Add /Users/adam/heroku-client to your $PATH.

You will need `ruby` in your path, which is available by default on Mac
OS X, can be installed on Ubuntu with `apt-get install ruby-dev`, or on
Windows with [RubyInstaller][8].

Run `heroku login` and enter your email address and password for your
Heroku account.  Answer yes when it prompts you whether to upload your
`ssh` public key.  Now you're all set to use Heroku from the command
line.

[7]: http://assets.heroku.com/heroku-client/heroku-client.tgz
[8]: http://rubyinstaller.org/

Write Your App
--------------

You may be starting from an existing app.  If not, here's a simple
"hello, world" sourcefile you can use:

### web.js

    var express = require('express');

    var app = express.createServer(express.logger());

    app.get('/', function(request, response) {
      response.send('Hello World!');
    });

    var port = process.env.PORT || 3000;
    app.listen(port, function() {
      console.log("Listening on " + port);
    });

Declare Dependencies With NPM
-----------------------------

Cedar recognizes an app as Node.js by the existence of a `package.json`.
Here's an example `package.json` for the Express app we created above:

### package.json

    {
      "name": "node-example",
      "version": "0.0.1",
      "dependencies": {
        "express": "2.2.0"
      }
    }

Run `npm install` to install your dependencies locally.

You'll also want to prevent NPM installed packages from going into
revision control with this file:

### .gitignore

    node_modules

Make sure that all of your app's dependencies are declared in
`package.json` and that you are not relying on any system-level
packages.

Declare Process Types With Foreman/Procfile
-------------------------------------------

To run your web process, you need to declare what command to use.  In
this case, we simply need to execute `web.js` with the Node runtime.
We'll use `Procfile` to declare how our web process type is run.

Here's a `Procfile` for the sample app we've been working on:

    web: node web.js

Optional, but highly recommended, is to test that the `Procfile` works
correctly using the [Foreman][9] tool, available as Ruby gem:

    $ gem install foreman
    $ foreman start
    14:39:04 web.1     | started with pid 24384
    14:39:04 web.1     | Listening on 5000

Your app will come up on port 5000.  Test that it's working with `curl`
or a web browser, then Ctrl-C to exit.

[9]: http://blog.daviddollar.org/2011/05/06/introducing-foreman.html

Deploy to Heroku/Cedar
----------------------

Store the app in Git:

    $ git init
    $ git add .
    $ git commit -m "init"

Add the Heroku remote that the Node.js Knockout organizers have created
for you:

    $ git remote add heroku git@heroku.com:nko2-my-team.git

Alternatively, if you were going to create a repository from scratch,
you would create the app on the Cedar stack (<b style="color:firebrick;">note: you should not do
this during Node.js Knockout, and should instead use the repository that
has been provisioned for your team</b>):

    $ heroku create --stack cedar # DON'T DO THIS FOR NODE KNOCKOUT
    Creating sharp-rain-871... done, stack is cedar
    http://sharp-rain-871.herokuapp.com/ | git@heroku.com:sharp-rain-871.git
    Git remote heroku added

Deploy your code:

    $ git push heroku master
    Counting objects: 9, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (7/7), done.
    Writing objects: 100% (9/9), 923 bytes, done.
    Total 9 (delta 2), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Updating alpha language packs... done
    -----> Node.js app detected
    -----> Vendoring node 0.4.7
    -----> Installing dependencies with npm 1.0.8
           express@2.1.0 ./node_modules/express
           ├── mime@1.2.2
           ├── qs@0.3.1
           └── connect@1.6.2
           Dependencies installed
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 3.2MB
    -----> Launching... done, v2
           http://nko2-my-team.herokuapp.com deployed to Heroku

    To git@heroku.com:nko2-my-team.git
     * [new branch]      master -> master

Before looking at the app on the web, we'll need to scale the web
process:

    $ heroku ps:scale web=1
    Scaling web processes... done, now running 1

Now, let's check the state of the app's processes:

    $ heroku ps
    Process       State               Command
    ------------  ------------------  --------------------------------------------
    web.1         up for 10s          node web.js

The web process is up.  Review [the logs][10] for more information:

    $ heroku logs
    2011-03-10T10:22:30-08:00 heroku[web.1]: State changed from created to starting
    2011-03-10T10:22:32-08:00 heroku[web.1]: Running process with command: `node web.js`
    2011-03-10T10:22:33-08:00 heroku[web.1]: Listening on 18320
    2011-03-10T10:22:34-08:00 heroku[web.1]: State changed from starting to up

Looks good.  You can now visit the app with `heroku open`.

Read more about Heroku's [introspection capabilites][11].

[10]: http://devcenter.heroku.com/articles/logging
[11]: http://blog.heroku.com/archives/2011/6/24/the_new_heroku_3_visibility_introspection/

Add Collaborators
-----------------

To add your Node Knockout team members to the app, use the `sharing:add`
command:

    $ heroku sharing:add jane@example.com
    jane@example.com added as a collaborator on nko2-my-team.

**Note: the app that has been provisioned for your team for Node.js
Knockout will already have your team members added as collaborators.
Contact [all@nodeknockout.com] if you need to change collaborators.**

Read more about [collaborators][12].

[12]: http://devcenter.heroku.com/articles/sharing
[all@nodeknockout.com]: mailto:all@nodeknockout.com

Setting NODE\_ENV
-----------------

The Express framework uses the `NODE_ENV` environment variable to
determine some behaviors related to caching.  If you're using Express,
set a config var with this value:

    $ heroku config:add NODE_ENV=production
    Adding config vars:
      NODE_ENV => production
    Restarting app... done, v3.

**Note: this will already have been done in the app that has been
provisioned for your team for Node.js Knockout.**

Console
-------

Cedar allows you to launch a REPL process attached to your local
terminal for experimenting in your app's environment:

    $ heroku run node
    Running `node` attached to terminal... up, ps.1
    >

This console has nothing loaded other than the Node.js standard library.
From here you can `require` some of your application files.

Read more about [one-off admin processes][13].

[13]: http://devcenter.heroku.com/articles/oneoff-admin-ps

Advanced HTTP Features
----------------------

The HTTP stack available to Cedar apps on the `herokuapp.com` subdomain
supports HTTP 1.1, long polling, and chunked responses.  [Ryan Dahl's
chat example][14] is deployed on Heroku [here][15] as a long-polling
example.

The WebSockets protocol is still in changing rapidly and is not yet
supported on the Cedar stack.

Read more about [the `herokuapp.com` HTTP stack][16].

[14]: https://github.com/ry/node_chat
[15]: http://nodejschat.herokuapp.com/
[16]: http://devcenter.heroku.com/articles/http-routing#the_herokuappcom_http_stack

Running a Worker
----------------

The `Procfile` format lets you run any number of different [process
types][17].  For example, let's say you wanted a worker process to
complement your web process:

#### Procfile

    web: node web.js
    worker: node worker.js

Push this change to Heroku, then launch a worker:

    $ heroku ps:scale worker=1
    Scaling worker processes... done, now running 1

All apps get 750 dyno-hours free per month.  This means you can run a
[process formation][18] of up to 750 dyno-hours / 48 hours = about 15
dynos for the duration of Node Knockout without incurring any charges,
as long as you scale back down to one or zero dynos at the end.  If your
app only uses one web process, then you don't need to worry about this
at all.

Read more about [dyno-hour accounting][19].

[17]: http://devcenter.heroku.com/articles/procfile
[18]: http://devcenter.heroku.com/articles/scaling
[19]: http://devcenter.heroku.com/articles/how-much-does-a-dyno-cost

Using a Postgres Database
-------------------------

To add a PostgreSQL database to your app, run this command:

    $ heroku addons:add shared-database

This sets the `DATABASE_URL` environment variable.  Add the `postgres`
NPM module to your dependencies:

    "dependencies": {
      ...
      "pg": "0.5.4"
    }

And use the module to connect to `DATABASE_URL` from somewhere in your
code:

    var pg = require('pg');

    pg.connect(process.env.DATABASE_URL, function(err, client) {
      var query = client.query('SELECT * FROM your_table');

      query.on('row', function(row) {
        console.log(JSON.stringify(row));
      });
    });

Read more about the Heroku [PostgreSQL database][20].

[20]: http://devcenter.heroku.com/articles/database

Using Redis
-----------

To add a Redis database to your app, run this command:

    $ heroku addons:add redistogo

This sets the `REDISTOGO_URL` environment variable.  Add the `redis-url`
NPM module to your dependencies:

    "dependencies": {
      ...
      "redis-url": "0.0.1"
    }

And use the module to connect to `REDISTOGO_URL` from somewhere in your
code:

    var redis = require('redis-url').connect(process.env.REDISTOGO_URL);

    redis.set('foo', 'bar');

    redis.get('foo', function(err, value) {
      console.log('foo is: ' + value);
    });

Other Backing Services
----------------------

Many other services are available in the Heroku [add-ons catalog][21]
for free, including [MongoDB][22], [CouchDB][23], [advanced full text
indexing][24], [Memcached][25], [realtime publishing][26], [Neo4j][27],
and [SMS publishing][28].

**Note: please contact [all@nodeknockout.com] if you need ownership of
your app to add addons.**

[21]: http://addons.heroku.com/
[22]: http://addons.heroku.com/mongohq
[23]: http://addons.heroku.com/cloudant
[24]: http://addons.heroku.com/indextank
[25]: http://addons.heroku.com/memcache
[26]: http://addons.heroku.com/pusher
[27]: http://addons.heroku.com/neo4j
[28]: http://addons.heroku.com/moonshadosms

Adding a Custom Domain
----------------------

Your app automatically gets a hostname like
`nko2-my-team.herokuapp.com`.  <b style="color:firebrick">Note: please
do not run `heroku rename` on your Node.js Knockout Heroku app.</b>

You can use [your own domain name][30].

[29]: http://devcenter.heroku.com/articles/renaming-apps
[30]: http://devcenter.heroku.com/articles/custom-domains
