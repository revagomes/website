# Countdown to KO #14: Deploying Your Node.js App to Linode

*This is the 14th in a series of posts leading up [Node.js Knockout][1], and
covers deploying your Node.js app to a [Linode][2] VPS.*

[1]: http://nodeknockout.com
[2]: http://www.linode.com/index.cfm

A Linode VPS means freedom. You get everything from the Linux kernel and root
access on up. All managed by a simple yet very powerful control panel.

This post will get you going with a Node.js/[Socket.IO][3] app on Linode.

[3]: http://socket.io/

# Do I need to sign up with Linode?

Short answer: no. Linode will be providing VPSs during the competition and judging period for teams as a deploy option. More details before the competition.

# Pick your Linux distro

Linode has a [choice of Linux distribution][4]. This blog post will be using
__Ubuntu 11.04__. The same instructions definitely apply to Ubuntu 10.04 (32-bit
or 64-bit) and are easily adaptable to Debian.

## 32-bit or 64-bit?

If you're going to be installing something like [mongodb][5], 64-bit is [highly
recommended][6]. If you're going to be using [redis][7] heavily, [maybe you
want 32-bit][8]. The choice is up to you and it's possible to wipe the VPS
later and pick a different option, but that could take time you don't have.

[4]: http://www.linode.com/faq.cfm#which-distributions-do-you-offer
[5]: http://www.mongodb.org/
[6]: http://blog.mongodb.org/post/137788967/32-bit-limitations
[7]: http://redis.io/
[8]: http://redis.io/topics/faq

# TL;DR StackScripts

Setting up your own server from scratch is not for the faint of heart. If you
know what you're doing, then this guide should be full of good directions to
take: read on. If you don't want to muck around with apt-get, upstart, sudoers,
and more, [use the StackScript][19]:

![Deploy using StackScripts](http://f.cl.ly/items/1j1W210A0b430d2N2E3H/Deploy%20using%20StackScripts.png)<br/>
![Search for knockout](http://f.cl.ly/items/052Q020a192s0N1V2N37/Search%20for%20knockout.png)

After your linode is booted up from that, skip to the [deploy
script](#deploy-script) section.

[19]: https://gist.github.com/1165971

# Boot and SSH in

Boot your Linode from the [Linode dashboard][9]. When creating your Linode, you
picked a root password. SSH in as root to complete the next steps. Your
linode's IP address can be found on the Remote Access tab from the control
panel.

**All of the commands below prefixed with `#` should be run as `root`. Any
prefixed with `$` are run as the `deploy` user (set up later).**

[9]: https://manager.linode.com/

# Install `git` and other tools

We'll definitely need `git` and most likely a C compiler (for compiling node
modules with C-bindings):

    # apt-get install -y build-essential curl
    # apt-get install -y git || apt-get install -y git-core

# Install node.js

The easiest way to install node.js is via [apt][10]:

    # apt-get install -y python-software-properties
    # add-apt-repository ppa:chris-lea/node.js
    # apt-get update
    # apt-get install -y nodejs

If you'd really rather compile from source:

    # apt-get install -y build-essential python libssl-dev
    # curl -O http://nodejs.org/dist/node-v0.4.11.tar.gz
    # tar xzf node-v0.4.11.tar.gz
    # cd node-v0.4.11
    # ./configure
    # make install

[10]: http://en.wikipedia.org/wiki/Advanced_Packaging_Tool

# Install npm

    # curl http://npmjs.org/install.sh | clean=no sh

By default, this will install `npm` in `/usr/bin` when using the apt-get method
above. When you install modules with `npm` later, they'll get installed to your
local working directory. If you use npm to install modules globally, you'll
need to be root or use `sudo`: `sudo npm install -g coffee-script`.

# Deploying

Now that we have `node` and `npm` installed on our linode, we want to get our
app out there and running. The rest of this guide uses a version of the
[Knocking out Socket.IO example app][11] to deploy with.

[11]: https://github.com/visnup/knocking-out-socket.io

## Setting up a deploy user

No one wants their own code running as root, right? Create a `deploy` user to
own where your app code lives and switch to it:

    # useradd -U -m -s /bin/bash deploy
    # su - deploy

### Set `NODE_ENV` to production

Setting `NODE_ENV` will tell frameworks such as [Express][12] to turn on its
caching features. It's also important for telling [our knockout check-in
module][13] to notify us of a deploy from your server.

    $ echo 'export NODE_ENV="production"' >> ~/.profile

[12]: http://expressjs.com/
[13]: https://github.com/nko2/website/tree/master/module#readme

### Add github.com to `known_hosts`

    $ ssh git@github.com
    The authenticity of host 'github.com (207.97.227.239)' can't be established.
    RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added 'github.com,207.97.227.239' (RSA) to the list of known hosts.
    Permission denied (publickey).

You can safely ignore the "Permission denied (publickey)" part for now.

### SSH keys

Drop your SSH public keys into `/home/deploy/.ssh/authorized_keys` to make
deploying and SSHing in much easier later. <b style="color:firebrick">While you're at it, you should add
the [Knockout organizers' public ssh key][14] for auditing at the end of the
competition.</b> SSH access for organizers is a required step in deploys to Linode.

    $ curl http://nodeknockout.com/id_nko2.pub >> ~/.ssh/authorized_keys
    $ chmod 600 ~/.ssh/authorized_keys

[14]: http://nodeknockout.com/id_nko2.pub

### Upstart script

We're going to use [upstart][15] to make sure our node app is running on server
start along with restarting it if it should die. As `root`:

    # cat <<'EOF' > /etc/init/node.conf 
    description "node server"

    start on filesystem or runlevel [2345]
    stop on runlevel [!2345]

    respawn
    respawn limit 10 5
    umask 022

    script
      HOME=/home/deploy
      . $HOME/.profile
      exec /usr/bin/node $HOME/app/current/app.js >> $HOME/app/shared/logs/node.log 2>&1
    end script

    post-start script
      HOME=/home/deploy
      PID=`status node | awk '/post-start/ { print $4 }'`
      echo $PID > $HOME/app/shared/pids/node.pid
    end script

    post-stop script
      HOME=/home/deploy
      rm -f $HOME/app/shared/pids/node.pid
    end script
    EOF

To use upstart as the `deploy` user, we'll have to give it `sudo` permission
for stopping and starting the node process:

    # cat <<EOF > /etc/sudoers.d/node
    deploy     ALL=NOPASSWD: /sbin/restart node
    deploy     ALL=NOPASSWD: /sbin/stop node
    deploy     ALL=NOPASSWD: /sbin/start node
    EOF
    # chmod 0440 /etc/sudoers.d/node

[15]: http://upstart.ubuntu.com/

<h2 id="deploy-script">Deploy script</h2>

Ok! The server's ready. Now onto our local development machine setup.

We're going to use [TJ][16]'s [deploy shell script][17] to make deploying our
code repeatable and easy for everyone on the team. On your local machine, in
your project's root directory:

    $ curl -O https://raw.github.com/visionmedia/deploy/master/bin/deploy
    $ chmod +x ./deploy
    $ cat <<EOF > deploy.conf
    [linode]
    user deploy
    host __96.126.102.14__
    repo __git@github.com:visnup/knocking-out-socket.io.git__
    ref origin/master
    path /home/deploy/app
    post-deploy npm install && [ -e ../shared/pids/node.pid ] && sudo restart node || sudo start node
    test sleep 1 && curl localhost >/dev/null
    EOF

Make sure to change the __IP address__ and __GitHub repo__ to ones for your
team.

Now run `./deploy linode setup` to get things setup:

    $ ./deploy linode setup
      ○ running setup
      ○ cloning git@github.com:visnup/knocking-out-socket.io.git
    Cloning into /home/deploy/app/source...
      ○ setup complete

And finally `./deploy linode` to deploy:

    $ ./deploy linode
      ○ deploying
      ○ hook pre-deploy
      ○ fetching updates
    Fetching origin
      ○ resetting HEAD to origin/master
    HEAD is now at bfadb51 bind to port 80 and downgrade
      ○ executing post-deploy `npm install && [ -e ../shared/pids/node.pid ] && sudo restart node || sudo start node`

    node start/running, process 13623
      ○ executing test `sleep 1 && curl localhost >/dev/null`
      ○ successfully deployed origin/master

You should commit both `./deploy` and `./deploy.conf` to your git repo. That
way, anyone on your team can just run `./deploy linode` later to push a new
deploy out. Make sure to add everyone's SSH keys to the `deploy` user too.

[16]: https://github.com/visionmedia
[17]: https://github.com/visionmedia/deploy

## Binding to port 80

Take note of the `listen` call in [our `app.js`][18]:

    app.listen(process.env.NODE_ENV === 'production' ? 80 : 8000, function() {
      console.log('Ready');

      // if run as root, downgrade to the owner of this file
      if (process.getuid() === 0)
        require('fs').stat(__filename, function(err, stats) {
          if (err) return console.log(err)
          process.setuid(stats.uid);
        });
    });

It specifically binds to port 80 when run in production mode and otherwise to
port 8000. Because we're running node under upstart (and therefore as root
initially), node has the chance to bind to the privileged port 80. Once it's
bound though, it downgrades its uid to the owner of the `app.js` file, namely
our `deploy` user. This is much more secure than running your app as the root
user.

[18]: https://github.com/visnup/knocking-out-socket.io/blob/master/app.js#L29

# Try it out

You should now be able to hit your linode directly and see your app running!

# Problems?

If you run into any problems, we're here to help. Email <all@nodeknockout.com>
or try us on [Twitter][20].

[20]: http://twitter.com/node_knockout
