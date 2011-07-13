# What's the problem again?

If you are working with [Paypal's Instant Payment Notifications] (https://www.paypal.com/ipn), you will need a way for Paypal to send POST requests to your app. However, this means that your app must be exposed on the internet for Paypal to send the request to you.

If you have a staging server for your web app, you will have Paypal send requests there, but it still leaves developer machines stranded since they work locally. Developers may be able to use dynamic DNS services, but since each Paypal account can only specify one notification URL, only one can be set up at a time.

While your team might get away with setting up each developer with an individual Paypal Sandbox account, you're gonna have trouble keeping them in sync when you want to make changes to the account's configuration.

One other way is to set the notify_url variable in each Paypal command, test your site on a dynamic hostname that forwards requests to your local machine. That works fine if you are hosting your web app on port 80.

# How does Fast Forward work?

Fast Forward runs as a simple rack app that forwards IPNs to a target hostname retrieved from the custom variable that is passed via Paypal commands. If you are already using the custom field for some other purpose, Fast Forward will likely not work for you at the moment.

## Step 1: Configure Paypal to send IPN to Fast Forward

To get started, log in to your Paypal account, navigate to profile and change your IPN notification URL to where you would like to run Fast Forward. I have already set up a public instance of Fast Forward on Heroku, so you can enter this URL if you haven't decided you want to set up Fast Forward:

    http://fast-forward.heroku.com

Any POST request sent to Fast Forward is replicated at the full path of the request, so if you aren't accepting IPNs on your home page, you can do something like this:

    http://fast-forward.heroku.com/payment_notifications

Thus, any IPN sent to Fast Forward will also be sent to /payment_notifications on your local set up.

## Step 2: Set up your local machine with a dynamic DNS service

The instructions for doing so are beyond the scope of this readme, but do take a look at these services:

* http://www.dyndns.com/
* http://www.no-ip.com/
* http://showoff.io/

I have only tested Fast Forward with Dyndns and Showoff, but it should work with similar services fine. Make sure you have your dynamic hostname on hand for the next step.

## Step 3: Configure your app to send your machine's dynamic hostname

I assume that you are using http://fast-forward.heroku.com for this step. To get Fast Forward to forward requests to your local app, pass in a hostname (port is optional) as a name-value pair in your custom field format like so:

    values = {
      # ...
      :custom => "host:http%3A%2F%2Fexample.com, port:80" # data is URL encoded
      # ...
    }

This example is in [Ruby] (http://www.ruby-lang.org/en/), and follows [Ryan Bate's screencast on Instant Payment Notification] (http://railscasts.com/episodes/142-paypal-notifications). However, Fast Forward will work with any system capable of receiving POST data.

And you're set; now whenever Paypal receives a command that triggers an IPN, it will first be sent to the Fast Forward rack app, then forwarded to the host specified in your app.

Alternatively, you may want to set up Fast Forward locally, configure Paypal to send IPNs to your local machine (on the dynamic hostname), and specify local host/port in the custom field.

# Future

* This app is a result of a spike (I didn't know it would even work) and thus there are no specs.
* alternative methods of specifying host/port
* cache IPN requests for inspection (using GET requests) in a developer console
* add support for basic authentication

Feel free to submit any suggestions to the [issue tracker] (https://github.com/tinkerbox/fast-forward/issues).