# NKO Quick Start

_Here's a quick overview of how to get your [Node.js Knockout][1] app up
and running correctly. <b style="color:firebrick">Please review the
overview section of this post, as it contains essential information for
the contest.</b>_

[1]: http://nodeknockout.com

# Overview

1. Set up a server with [the NKO npm module](#nko).
2. Push to your team's [GitHub repo](#github).
3. [Deploy](#deploy) to [Joyent](#joyent), [Heroku](#heroku) or
   [Linode](#linode).
   * If you deploy to Linode: `curl http://nodeknockout.com/id_nko2.pub >> ~/.ssh/authorized_keys` to grant NKO organizers access.
4. Verify your app is [marked as deployed](#deployed).

# Instructions

For these instructions you will need two keys, both available on [your
team page][]:

![Slug and secret](http://f.cl.ly/items/2v0e2D1C1H1m3t2w090c/Screen%20Shot%202011-08-26%20at%201.04.37%20PM.png)

1. **your team slug** - in this example, `your-team-slug`
2. **your team secret** - in this exmaple, `yourteamsecret`

[your team page]: http://nodeknockout.com/teams/mine

## Step 1. Set up a Server

### Create Project Folder

You want to make sure you have a folder for everything before you get
started.

    $ mkdir your-team-slug
    $ cd your-team-slug

### Set up Dependencies

[Install npm][].

    $ curl http://npmjs.org/install.sh | sh

Then set up your package.json and dependencies:

    $ npm init
    $ npm install --save nko

[Install npm]: http://blog.nodeknockout.com/post/8796073313/countdown-to-ko-2-how-to-install-npm

### Create `server.js`

    // server.js
    var http = require('http')
    , nko = require('nko')('yourteamsecret');

    var app = http.createServer(function (req, res) {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('Hello, World');
    });

    app.listen(parseInt(process.env.PORT) || 7777);
    console.log('Listening on ' + app.address().port);

<h3 id="#nko">Require the `nko` Module</h3>

Make sure you require the [nko module][] <b style="color:firebrick">or
else your site will not be voted on</b>:

    require('nko')('yourteamsecret')

_We use the `nko` module to determine where your site has been deployed,
so we can send judges to the right url to evaluate it._

[nko module]:https://github.com/nko2/website/tree/master/module#readme

<h2 id='github'>Step 2. Push to GitHub</h2>

Instruct git to ignore your npm dependencies.

    $ echo node_modules > .gitignore

Then create a git repository and add everything to it.

    $ git init .
    $ git add .
    $ git commit -m 'first commit'

Finally, set GitHub as the origin for the repository.

    $ git remote add origin git@github.com:nko2/your-team-slug.git
    $ git push -u origin master

<h2 id="deploy">Step 3. Deploy Your Server</h2>

[Joyent](#joyent), [Heroku](#heroku), and [Linode](#linode) are
providing free, private instances for you to deploy your code during
the competition.

The choice of service for your submission is up to you (kinda like Pokémon):

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

<h3 id="joyent">Joyent (no.de)</h3>

Detailed instructions for deploying to no.de are available [here](http://blog.nodeknockout.com/post/9393790204/coundown-to-ko-20-no-de-getting-started-guide).

The no.de hosting service has just launched!  **Please send support inquiries to [node@joyent.com](mailto:node@joyent.com).**

1. Create an account at [no.de](http://no.de) (or login).

1. Click "Order a Machine" button in the upper right hand corner.
   - In the following instructions, we will assume you name your smart machine `your-team-slug`.

1. Click on the smart machine you ordered.

1. Follow the instructions on the smart machine page to add the host to
   your `~/.ssh/config` file.

1. Add joyent as a remote on your git repo:

    <code><pre>$ git remote add joyent your-team-slug.no.de:repo</pre></code>

1. Now you should be able to deploy with a git push:

    <code><pre>$ git push joyent master</pre></code>

1. Load your app in a browser to verify that it works.

    <code><pre>http://your-team-slug.no.de/</pre></code>

1. Check your app is marked as [deployed correctly](#deployed) on your
   team page.

<h3 id="heroku">Heroku</h3>

1. Follow the invitation link in the invitation email you received from
   Heroku.  Create a password in the invitation page.

1. Install the heroku gem on your development machine.

    <code><pre>gem install heroku</pre></code>

1. Configure your heroku login credentials, using the same email and
   password you supplied in step 1.  Answer yes when prompted to use
   your existing ssh key.

    <code><pre>$ heroku login
    Enter your Heroku credentials.
    Email: user@domain.com
    Password:
    Found existing public key: /Users/user/.ssh/id_rsa.pub
    Would you like to associate it with your Heroku account? [Yn] y
    Uploading ssh public key /Users/user/.ssh/id_rsa.pub
    </pre></code>

1. Configure a Procfile, to instruct Heroku how to serve your app.

    <code><pre>$ echo 'web: node web.js' > Procfile</pre></code>

1. Install Foreman and test your app locally (on port 5000 in this
   example).

    <code><pre>$ gem install foreman
    $ foreman start
    13:52:16 web.1     | started with pid 83853
    13:52:16 web.1     | Listening on 5000
    </pre></code>

1. Configure your remote Heroku repository.

    <code><pre>$ git remote add heroku git@heroku.com:nko2-your-team-slug.git</pre></code>

1. Deploy to Heroku.

    <code><pre>$ git push heroku master</pre></code>

1. Load your app in a browser to verify that it works.

    <code><pre>http://nko2-your-team-slug.herokuapp.com/</pre></code>

1. Check your app is marked as [deployed correctly](#deployed) on your
   team page.

<h3 id="linode">Linode</h3>

1. Login to the [Linode Manager][].

2. Enter the credentials from [your team page][].

3. Follow the [Deploying to Linode][] blog post.

4. Deploy your app.

    <code><pre>./deploy linode</pre></code>

5. Check your app is marked as [deployed correctly](#deployed) on [your
   team page][].

[Linode Manager]: https://manager.linode.com/
[Deploying to Linode]: http://blog.nodeknockout.com/post/9300619913/countdown-to-ko-14-deploying-your-node-js-app-to

<h2 id="deployed">Verify Your App is Marked Deployed</h2>

Once you deploy, you should visit your [node knockout team page][your
team page] and verify that your app is correctly marked as deployed.

If your app is deployed correctly, you should see a nice green checkbox.

![Deployed Correctly](http://f.cl.ly/items/1a1v1e1z0e3w1H2h340a/Screen%20Shot%202011-08-26%20at%201.04.37%20PM.png)

# Additional Notes

All entries will be hosted at least until the competition winners are
announced. During judging, we will require remote access to your instance via
an SSH key to make sure there is no cheating. We will compare your deployed
code with the code in your git repo.

After the 48-hour competition deadline, you will still be allowed to
restart processes, free up disk space, and perform other general
sysadmin tasks (including playing lots of StarCraft 2).
