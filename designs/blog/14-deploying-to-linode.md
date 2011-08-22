# Countdown to KO #14: Deploying Your Node.js App to Linode

*This is the 14th in a series of posts leading up [Node.js Knockout][1],
and covers deploying your Node.js app to a [Linode][2] VPS.*

[1]: http://nodeknockout.com
[2]: http://www.linode.com/index.cfm

A Linode VPS means freedom. You get everything from the Linux kernel and root
access on up. All managed by a simple yet very powerful control panel.

This post will get you going with a Node.js/[Express][3] app on Linode.

[3]: http://expressjs.com/

# Pick Your Linux Distro

Linode has a [choice of Linux distribution][4]. This blog post will be using
Ubuntu 11.04 64-bit.

## 32-bit or 64-bit?

If you're going to be installing something like
[mongodb][5], [64-bit is highly recommended][6]. If you're going to be using
[redis][7] heavily, [maybe you want 32-bit][8]. It's possible to wipe the VPS
later and pick a different option, but that means setting everything up again.

[4]: http://www.linode.com/faq.cfm#which-distributions-do-you-offer
[5]: http://www.mongodb.org/
[6]: http://blog.mongodb.org/post/137788967/32-bit-limitations
[7]: http://redis.io/
[8]: http://redis.io/topics/faq

# Boot and SSH in

Boot your Linode from the [Linode dashboard][9]. When creating your Linode,
you picked a root password. SSH in as root to complete the next steps. Your
linode's IP address can be found on the Remote Access tab from the control
panel.

[9]: https://manager.linode.com/

# Install node.js

The easiest way to install node.js is via [apt][10]:

    apt-get install -y python-software-properties
    add-apt-repository ppa:chris-lea/node.js
    apt-get update
    apt-get install -y nodejs

If you'd really rather compile from source:

    apt-get install -y build-essential python libssl-dev
    curl -O http://nodejs.org/dist/node-v0.4.11.tar.gz
    tar xzf node-v0.4.11.tar.gz
    cd node-v0.4.11
    ./configure
    make install

[10]: http://en.wikipedia.org/wiki/Advanced_Packaging_Tool

# Install npm

    curl http://npmjs.org/install.sh | clean=no sh

By default, this will install `npm` in `/usr/bin`. When you install modules
with `npm` later, they'll get installed to your local working directory. If you
use npm to install modules globally, you'll need to be root or use `sudo`.

# Deploying

Now that we have node and npm installed on our linode, we want to get our app
out there and running. The rest of this guide uses the [Knocking out Socket.IO
example app][11] to deploy with.

[11]: https://github.com/nko2/knocking-out-socket.io

## Setting up a `deploy` user

## Setting NODE_ENV

## Binding to port 80

# StackScripts
