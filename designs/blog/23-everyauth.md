# Countdown to KO #23: Login with Password, Facebook, Twitter, and more with everyauth

_This is the 23rd in series of posts leading up to [Node.js Knockout][1]
about how to use [everyauth][] to manage logins. This post was written by
[everyauth][] author and [Node.js Knockout contestant][3] Brian Noguchi._

[1]: http://nodeknockout.com
[everyauth]: https://github.com/bnoguchi/everyauth
[3]: http://nodeknockout.com/people/4e2e3e8a4dfe3d0100000f51

## Introduction

So you want to add logins to your web app? Assuming that you are using
[Connect](https://github.com/senchalabs/connect) or
[Express](https://github.com/visionmedia/express) (and who isn't these
days?), then [everyauth][] can get you up and running within minutes.

## 4 Steps to Get Up and Running

Setting up everyauth comes down to 3 steps with Connect and 4 steps with Express:

1. **Step 1 - Choose and configure what one or more logins you want**

   Currently, we support 19 different login types
   including password, Facebook, Twitter, GitHub, and more. For a full list, see
   the [everyauth github page](https://github.com/bnoguchi/everyauth).

2. **Step 2 - Specify a function for finding a user by id**

   The function configuration here will depend on how you are storing your data
   -- i.e., in memory or via a database. For in memory storage of users, this
   would look like:

       <pre><code>
       var usersById = {};

       everyauth.everymodule
         .findUserById( function (id, callback) {
           callback(null, usersById[id]);
         });
       </code></pre>

3. **Step 3 - Add your middleware to Connect/Express**

   This automatically will set up routes and views for your app. For example, if
   you chose to set up password authentication, then you can now navigate to
   http://localhost:3000/login, http://localhost:3000/register, and logout with
   http://localhost:3000/logout.

   In connect, this looks like:

       <pre><code>
       var everyauth = require('everyauth');
       // Step 1 code goes here

       // Step 2 code
       var connect = require('connect');
       var app = connect(
           connect.favicon()
         , connect.bodyParser()
         , connect.cookieParser()
         , connect.session({secret: 'mr ripley'})
         , everyauth.middleware()
         , connect.router(routes)
       );
       </code></pre>

   In express, this looks like:

       <pre><code>
       var everyauth = require('everyauth');
       // Step 1 code goes here

       // Step 2 code
       var express = require('express');
       var app = express.createServer(
           express.favicon()
         , express.bodyParser()
         , express.cookieParser()
         , express.session({secret: 'mr ripley'})
         , everyauth.middleware()
         , express.router(routes)
       );
       </code></pre>

4. **Step 4 (Express only) - Add view helpers to Express**

       <pre><code>
       // Step 1 code
       // ...
       // Step 2 code
       // ...

       // Step 3 code
       everyauth.helpExpress(app);

       app.listen(3000);
       </code></pre>

## Configuring Facebook Connect

This is how you would configure configure **Step 1** from above to
set up Facebook Connect.

First some boilerplate for creating and storing users in memory:

    var nextUserId = 0;
    var usersById = {};

    function addUser (source, sourceUser) {
      var user;
      if (arguments.length === 1) { // password-based
        user = sourceUser = source;
        user.id = ++nextUserId;
        return usersById[nextUserId] = user;
      } else { // non-password-based
        user = usersById[++nextUserId] = {id: nextUserId};
        user[source] = sourceUser;
      }
      return user;
    }

Now for the configuration (Step 1) that sets up Facebook Connect.

    var usersByFbId = {};

    everyauth
      .facebook
        .appId(YOUR_APP_ID)
        .appSecret(YOUR_APP_SECRET)
        .findOrCreateUser( function (session, accessToken, accessTokenExtra, fbUserMetadata) {
          return usersByFbId[fbUserMetadata.id] ||
            (usersByFbId[fbUserMetadata.id] = addUser('facebook', fbUserMetadata));
        })
        .redirectPath('/');

Get `YOUR_APP_ID` and `YOUR_APP_SECRET` by
[registering](http://developers.facebook.com/) a Facebook app.

`findOrCreateUser` takes an incoming `session` object and the data
returned from Facebook's OAuth2 process as `accessToken` and
`accessTokenExtra`, and `fbUserMetadata`. This function should find or
create a user object and then return it.

`redirectPath` tells you where to redirect your user after a successful
Facebook Connect login.

With this code, you can now include links to `/auth/facebook` in your
views.

For detailed instructions to set up any of the 19 login strategies,
please see the [README](https://github.com/bnoguchi/everyauth)

## Other Resources

- [github](https://github.com/bnoguchi/everyauth)

  For a full example, please see the `/example` directory in the github repo

- [NodeTuts vidcast tutorial with everyauth](http://nodetuts.com/tutorials/26-starting-with-everyauth.html#video)
