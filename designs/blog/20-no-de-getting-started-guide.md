# Coundown to KO #20: no.de Getting Started Guide

_This is the 20th in series of posts leading up to [Node.js Knockout][1]
about how to use Joyent's [no.de][] service. This post was written by
[no.de][] architect and [Node.js Knockout judge][3] Isaac Schlueter._

[1]: http://nodeknockout.com
[no.de]: http://no.de
[3]: http://nodeknockout.com/people/4e2819db6fd024010000192e

These instructions will tell you how to deploy your code on Joyent's
no.de service.

## Create an Account

Go to [no.de](http://no.de/) and click "Sign up".

Then fill in the stuff.  You've done this before.

Now you're logged in.  If you're not logged in now, [email
support](mailto:node@joyent.com).

## Add an SSH Key

You need to add an SSH public key to your account to provision Node
SmartMachines.

If you're on a Windows computer, then use the `puttygen.exe` program
which comes along with PuTTY.  The key you want is the one marked
`Public key for pasting into OpenSSH authorized_keys file`.

If you're on any other kind of computer, then your SSH keys are probably
in `~/.ssh/*.pub`.  If you don't have one, then you can create it by
using the `ssh-keygen` program.

Paste the key into the big box.  You can also add a name for the key, if
you like labels.

Save it.  Now you've got a key.

## Order a Machine

Click the button on the right that says "Order a Machine".

Give it a name.

Click "Provision".

## Follow Instructions

On the machine details page, there are a bunch of instructions.

Follow them.

It won't work unless you follow the instructions.

If you forget, and need to follow them later, that's fine.  They'll
still be there.

It involves pasting some stuff into your `.ssh/config` file.  You can
achieve a similar effect on Windows by using [this
method](http://tartarus.org/~simon/putty-snapshots/htmldoc/Chapter4.html#config-file),
or using git and ssh from Cygwin.

## Bask in the Cool Glow of the Logo

On the machine details page is a hyperlink to your new zone.  Click it.

Enjoy the logo.

When you're done enjoying the logo, click the logo to return to the
machine details page.

Repeat until bored.

## Push Some Code

Use the power of the instructions!  Push code to your machine!  Be a winner!

Some tips:

* If you have npm dependencies you can add them to a `package.json` file
  in the root of your repository.
* The default start command is `node server.js`.  If you want to have it
  start up some other way, then you can put something like this in your
  package.json file:  `"scripts": { "start" : "my-custom-command" }`
* If you have a dependency that takes a long time to install, you can
  make deploys faster by ssh-ing into your zone, and `npm install
  <some-dependency> -g`.  The deploy script will reuse globally installed
  dependencies if they're suitable.

If you run into trouble, [email support](mailto:node@joyent.com).
