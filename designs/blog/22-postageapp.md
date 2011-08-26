# Countdown to KO #22: PostageApp

*This is the 22nd in series of posts leading up [Node.js Knockout][1],
and covers using [PostageApp][] to send email in your node app.*

[1]: http://nodeknockout.com
[PostageApp]: http://postageapp.com/

Given the time crunch for Node.js Knockout, there’s barely enough time
for anything. Getting your app configured to send email is one of those
things that can prove to be far more time-consuming than you expect,
especially if you’re not prepared.

Here’s a quick-start guide for getting your Node application set up and
ready to roll in just a few minutes.

## 1. Install the Module ##

With Node, there are two really easy ways to bring a module into your
app: using the Node Package Manager (NPM) or a manual download.

### Using the Node Package Manager (NPM) ###

Using the Node Package Manager is by far the easiest and quickest way to
get a module installed into your Node app. All you have to do is run
this command in the root of your application:

    npm install postageapp

### Manual Install ###

Manually installing is just slightly more tedious than installing via
NPM, but it's just as simple!

* Download the module files from our [GitHub
  account](https://github.com/postageapp/postageapp-nodejs/tarball/master)
* Unzip the file you just downloaded, and copy the contents over to your
  app's `node_module` folder
* Rename the folder from `postageapp-nodejs` to `postageapp`

## 2. Get a PostageApp API Key ##

Log in to your PostageApp account and make sure you create at least one
project. Once you have a project associated with your account, you
should be able to see an API key specific to that project. Once you have
the API key, you can include the PostageApp plugin into your Node.JS app
by using the following code:

    var postageapp = require('postageapp')('YOUR API KEY GOES HERE');

## 3. Creating a Parent Template ##

It's not hard to send great looking email messages if you have the right
tools. Email clients are notoriously particular about what kind of HTML
they accept, and even support for CSS is extremely limited. One big
feature of PostageApp is that you're able to create a nice HTML
template, add in a CSS file, and the two will be combined in an
email-friendly markup format that you can preview before sending to
ensure it's working properly.

Every new project comes with a sample layout you can customize with your
own logo, CSS theme, and of course content. A parent template can be
used to establish common headers and footers without having to cut and
paste these to every type of message you'll be making. These are
available under the **Message Templates** tab of any project page.

To explain how this works, let's create a very simple parent template by
going to the **Message Templates** tab and clicking on the **Create a
New Template** link just above the list of templates. You'll get an
empty editor screen you can use to create it.

Add a simple layout that looks something like this in the **HTML** tab
edit area:

    <h2>Awesome Web App</h2>

    <hr>

    <div>
        {{ * }}
    </div>

    <hr>

    <a href="http://yoururl.com">Awesome Web App Page</a>

The mysterious double-curly symbol-with-a-star-in-it **{{ * }}** in the
middle is the location where the template content will go.

You can preview the template at any time and see how it should look in a
regular email client. Warnings about your HTML and CSS are reported
here, so if you're making use of exotic, cutting-edge features like
background images that some ornery email clients like Outlook don't
support, you'll get a heads up here. You can always use the **Send test
email** button located just below the editor to see how the email looks
in your own client, or through an email previewing service if you use
one.

Without some CSS this is going to look really plain. As you design your
app, it's easy to snip key styles and paste them into the CSS tab of the
template editor.

Before you can save this template, you have to give it a **template
slug**. For layouts, this is really just a descriptive name you can use
to remember what layout it is. In this case call it something like
**default_layout** so it's easily identified later.

The Subject and From fields generally only apply to child templates
themselves, not parent templates.

Save your template and you should be ready for the next step.

## 4. Create a Child Template ##

Having a parent template is great, but without something to go into it,
you won't get much use out of it. A message template can be created as
you usually would, within your Node application, but it's usually far
easier to have the templates within PostageApp so you can edit them
without having to redeploy your application. Think of this as **CMS for
your email messages** where you can make changes at any time and see the
results immediately.

A typical application sends out dozens of different messages to its
users. When you sign up, when you confirm your registration, when you
forget your password, when you haven't been active in a while, when you
invite someone, when you receive a message from someone, or even for
general announcements or special offers. It can be difficult to maintain
these if you have to check in and deploy your application to make even
the smallest change.

A good example is an invitation email sent by one user to someone else.
Create a **New Message Template** again. This time we'll use the parent
template created in the last step to give an otherwise boring email some
style.

Here's a sample invitation that can be pasted into the **HTML** tab edit
area:

    <p>You've been invited to join {{ app_name }}!</p>

    <p><a href="{{ signup_link }}">Sign up</a> now and receive five free invites you can share with your friends!</p>

There are two variables here you can customize with user data when
sending the message, **{{ app_name }}** and **{{ signup_link }}**.
Through the API you can set some of these the same for everyone, or
customize each field individually for each recipient.

Set the **parent layout** to be the parent template created in the
earlier step.

You can set the default **From** address here, or assign it later when
making the API call. The same goes for the **Subject**. You can also use
template variables in the subject to personalize it. In this case, set
the subject to:

    {{app_name}} - Invitation from {{user_name}}

If you preview the message now, you should see the template wrapped
neatly inside the layout.

Set the **Template Slug** to be **invitation** and save the message.

You're now ready to set up something to trigger this message.

## 5. Sending an Email with Node ##

To send emails through PostageApp using the Node plugin, you have to
create a hash with all of the arguments that you need, and then make the
API call using the payload which we assembled. Here's an example of what
assembling a payload looks like:

    var options = {
        recipients: 'email@address.com',

        subject: 'Subject Line',
        from: 'sender@example.org',

        content: {
            'text/html': '<strong>Sample bold content.</strong>',
            'text/plain': 'Plain text goes here'
        }

        template: 'sample_template_slug',

        variables: {
            'global_variable_1': 'First Name',
            'global_variable_2': 'Username'
        }
    };

For a better idea of how to use the arguments, take a look at the
Node.JS plugin's [GitHub
page](https://github.com/postageapp/postageapp-nodejs) for further
examples and elaboration.

Once you have your arguments set up, all you have to do is make an API
call.

    postageapp.sendMessage(options);

## Recap! ##

From here you can go and customize this as required, add other
notifications, and create new templates.

Hopefully this saves you a bunch of time so you can make an even better
application this weekend.

More detailed documentation is available on our [knowledge
base](http://help.postageapp.com/kb).

**Good luck with Node Knockout!**
