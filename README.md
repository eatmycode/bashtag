`stweet` (aka. `ShellTweet`)
---

A simple shell script to post tweets to your timeline using Twitter's v1.1 API.

* Do you live in your CLI?
* Rather not switch to a browser or other device to broadcast to the world?
* Wanna automate tweets of whatever gibberish via cron?

If yes to any of the above, then `stweet`!

So, this is just the beginning! `ShellTweet` suggestions and pull requests are welcome and encouraged.

## Requirements...

Linux Based OS/Virtual Environment

`AND`

PHP >= 5.3.x

`OR`

OpenSSL 

* Defaults to PHP if both installed.

* On a production webserver, typically both would already be installed (see your host if you are unsure).

* If using on your local box and you dont have a l/a/n/mp stack or stand-alone PHP install or OpenSSL, then get one.

* A quick check:

		# Open up a linux terminal and type:

		~$ which php openssl

		# If you have 1 or both installed, you should see something similar to:

		~$ which php openssl
		/usr/local/bin/php
		/usr/bin/openssl

		# If you get nothing in return or see somthing like /usr/bin/which: no {SOFTWARE_NAME} in (/usr/local/bin:.....
		# for both php AND openssl, then you dont have either installed.
  
  
---

Why PHP or OpenSSL?

Well, the signature for authorizing and posting the status update is calculated by passing the signature base string and signing key to the HMAC-SHA1 hashing algorithm. The details of the algorithm are explained in depth [HERE](http://en.wikipedia.org/wiki/HMAC), but thankfully there are implementations of HMAC-SHA1 available for every popular language. For example, PHP has the [hash_hmac function](http://php.net/manual/en/function.hash-hmac.php) and HMAC-SHA1 hashing can easily be generated on almost any modern Unix-like system using [OpenSSL](http://www.openssl.org/docs/apps/dgst.html).

## Prep...

The goal of `stweet` is simplicity `PAUSE` You do however need to make yourself a twitter app!

So basically, you need to:

1. [Go create yourself a twitter app on the twitter developer site](https://dev.twitter.com/apps/).
2. After creation, click the `Settings` tab, scroll down and enable read/write access for your twitter app. (This will take a min.)
3. Now, click the `Details` tab, scroll down and click `Create my access token` (This will also take a min.)
4. Lastly, click the `OAuth tool` tab and grab your consumer key/secret and access token/secret:

	![twitter/developers](http://api.marquelmedia.net/ss/OAuth_tool.png)

Ok, got all that?

Now, open up `stweet` in your preferred editor and add your app access tokens (lines 127-130).

		   120
		   121	#############
		   122	# TWITTER API
		   123	    #
		   124	    # Your application's OAuth settings.
		   125	    ##### [EDIT THIS TO YOUR APPLICATION'S VALUES]
		   126	
		   127	        app_key="YOUR_CONSUMER_KEY"
		   128	        app_secret="YOUR_CONSUMER_SECRET"
		   129	        access_token="YOUR_ACCESS_TOKEN"
		   130	        access_secret="YOUR_ACCESS_SECRET"
		   131


All that's left is to just place `stweet` in your scripts, bin, or executable dir:

    ~$ cd /place/to/where/you/downloaded/stweet
	~$ mv stweet /path/to/your/executable/scripts/

...or create a symlink to `stweet` in your scripts, bin, or executable dir:

    ~$ cd /path/to/your/executable/scripts/
	~$ ln -s /place/to/where/you/downloaded/stweet ./stweet

**Done!**

## Use...

1. Tweet It. (A tweet oneliner)

	    ~$ stweet this is pretty dope!

		#           NOTE: ONLY if using this option (Option 1. - Direct tweet), 
		#                 all "hastags" must be escaped with a '\'

	    ~$ stweet \#money is on my \#mind.

		#            WHY: Linux will see it as a comment and ignore everything after the first "#"


2. Prompt It. (Prompts you for your message)

		~$ stweet
		   What You Tweetin' [140 pls]: yep this is stupid simple #bashery


3. Pipe It. (Feed stweet the stdout from another command or series of commands)

		~$ cat somefile | stweet


4. Cron It. (Automate your tweets)

		*/5 * * * * PATH=PATH:/path/to/your/executable/scripts/; curl -s http://something.from/somewhere | stweet > /dev/null 2>&1


Yep. Pretty `stweet` right?

If successful, you will see something like:

	~$ stweet Yayyy. I can do this. \#osohappy

	   Tweeted It!


If an error occurs, it will be displayed in un-pretty (sorry) JSON: o_o

	~$ stweet This is some text that is really long and not less than 140 characters. But it is something I really want to get off of my chest because it is important for me to say it!

	   Error: [ {"errors":[{"code":186,"message":"Status is over 140 characters."}]} ]

## Limitations...

This is a simple CLI tool. Nothing real extravagant here.

It's primarily for text only tweets <= 140 characters and nothing more (at least currently).

However, it's use can be expanded upon as you wish... ([Check the Twitter API docs](https://dev.twitter.com/docs/api/1.1/)).

I'd love to see/merge what other `stweet` things you do with it.

## OS/Env...

Tested and confirmed working on:

* Mac OSX 10.9.1
* CentOS 6.4
* CentOS 5.10
* More to come...

If working for you (or not) and your OS is not mentioned, please drop me a line with your OS/Environment.

## License...

[MIT License](http://api.marquelmedia.net/lic/LICENSE.md)


