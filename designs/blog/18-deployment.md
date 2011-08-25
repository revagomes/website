# Countdown to KO #18: Deployment

*This is the 18th in series of posts leading up [Node.js Knockout][1],
and covers deployment.

[1]: http://nodeknockout.com

### Overview

[Joyent][Joyent], [Heroku][Heroku], and [Linode][Linode] will provide free, private instances where you may deploy your code during the competition. You will receive an invitation to each service via email before the competition starts.  The choice of service for your submission is up to you (kinda like Pokémon):

- Joyent provides a full VPS with root-level access combined with the ease of
git push deployment. But note that Joyent only provides Solaris (ZFS!).
- Heroku is crazy easy and fast to get up and running, but has some
limitations (non-writable disk; XHR long-polling, but no WebSockets).
- Linode is also a full VPS, with your choice of [Linux distro][Linux distro] and
root-level access. It offers flexibility, but requires the most configuration
and UNIX skillZ of the three hosting services.

You cannot deploy to your own private server no matter how face-meltingly
awesome it is.

[Joyent]: http://www.joyent.com/
[Heroku]: http://www.heroku.com/
[Linode]: http://www.linode.com/index.cfm
[Linux distro]: http://www.linode.com/faq.cfm#which-distributions-do-you-offer

### Setting up No.de

1. Log in to no.de (or create an account)

2. click "Order a Machine" button in the upper right hand corner

3. click on the smart machine you ordered

4. follow the instructions to add the host to your ssh config file

5. set up your dependencies

    <code><pre>
    npm init
    npm install --save nko
    </pre></code>

5. make sure that joyent knows about your ssh key (in your account
   settings, in the upper right hand corner)

6. make sure your app is listening on port 80:

    <code><pre>app.listen(parseInt(process.env.PORT) || 7777);</pre></code>

### Setting up Heroku

1. Follow the invitation link in the invitation email you received from Heroku.  Create a password in the invitation page.

1. Install the heroku gem on your development machine.

    <code><pre>gem install heroku</pre></code>
    
1. Configure your heroku login credentials, using the same email and password you supplied in step 1.  Answer yes when prompted to use your existing ssh key.

    <code><pre>
    $ heroku login
    Enter your Heroku credentials.
    Email: user@domain.com
    Password: 
    Found existing public key: /Users/user/.ssh/id_rsa.pub
    Would you like to associate it with your Heroku account? [Yn] y
    Uploading ssh public key /Users/user/.ssh/id_rsa.pub
    </pre></code>
    
1. Clone your node knockout github repository.

    <code><pre>
    $ git clone git@github.com:/nko2/teamname.git
    $ cd teamname
    </pre></code>

1. Go to your team page and find your team secret.  Your team secret is used to [authenticate](https://github.com/nko2/website/tree/master/module#readme) deployment notifications.

    1. `http://nodeknockout.com/teams/mine`
    1. Click 'show deploy instructions'
    1. Find the line that looks like this:
    
        <code><pre>`require('nko')('xxxxxxx');`</pre></code>

1. Start creating your app, by placing the following in a file named web.js.  Replace the require() line below with the require() line you found in the previous step.

    <code><pre>
    require('nko')('xxxxxxx');

    var express = require('express');

    var app = express.createServer(express.logger());

    app.get('/', function(request, response) {
            response.send('Hello World!');
        });

    var port = process.env.PORT || 3000;
    app.listen(port, function() {
            console.log("Listening on " + port);
        });
    </pre></code>
    
1. Declare your npm dependencies.

    <code><pre>
    $ echo '{ "name": "example", "version": "0.0.1", "dependencies": { "express": "2.2.0", "nko":"*" } }' > package.json
    </pre></code>
    
1. Install your dependencies locally.

    <code><pre>$ npm install</pre></code>
    
1. Configure git to ignore your npm dependencies.

    <code><pre>$ echo node_modules > .gitignore</pre></code>
    
1. Configure a Procfile, to instruct Heroku how to serve your app.

    <code><pre>$ echo 'web: node web.js' > Procfile</pre></code>
    
1. Install Foreman and test your app locally (on port 5000 in this example).

    <code><pre>
    $ gem install foreman
    $ foreman start
    13:52:16 web.1     | started with pid 83853
    13:52:16 web.1     | Listening on 5000
    </pre></code>
    
1. Commit the initial version of your project.

    <code><pre>
    $ git add .
    $ git commit -m "initial version"
    </pre></code>
    
1. Configure your remote Heroku repository.

    <code><pre>$ git remote add heroku git@heroku.com:nko2-teamname.git</pre></code>
    
1. Deploy to Heroku.

    <code><pre>$ git push heroku master</pre></code>
    
1. Load your app in a browser to verify that it works.

    <code><pre>http://nko2-teamname.herokuapp.com/</pre></code>

1. Visit your node knockout team page and verify that your app is marked as deployed.

    <code><pre>http://nodeknockout.com/teams/mine</pre></code>
    
1. Push your progress to github.

    <code><pre>$ git push origin master</pre></code>

### Additional Requirements

All entries will be hosted at least until the competition winners are announced. During judging, we will require remote access to your instance via an SSH key to make sure there is no cheating. We will compare your deployed code with the code in your git repo. After the 48-hour competition
deadline, you will still be allowed to restart processes, free up disk space,
and perform other general sysadmin tasks (including playing lots of StarCraft 2).
