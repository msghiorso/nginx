# Getting Started

As our production environment is moving from Apache to Nginx, it makes more sense for our development environments to closely mirror that environment. It's going to be a bit of a journey to get there, so let's get started.

(Most of the following assumes you already have Xcode installed on your system. If not, go grab it from [[http://developer.apple.com/]] or the Mac App Store, though the latter costs $4.99.)

## Step 1: Install [Homebrew](http://mxcl.github.com/homebrew/)

If you're system is not new and you already have a ```/usr/local```, your permissions may get in the way. Correct that by running:

	[[ ! -d /usr/local ]] && sudo mkdir /usr/local
	sudo chown -R $USER /usr/local

Install Homebrew:

	ruby -e "$(curl -fsSLk ruby -e "$(curl -fsSL https://raw.github.com/gist/323731/39fc1416e34b9f6db201b4a026181f4ceb7cfa74)")"

If you did have an existing ```/usr/local```, you can see if there are any problems from what you already have in there by running:

	brew doctor

## Step 2: Install [RVM](https://rvm.beginrescueend.com/)

	bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

Then add the following to your ~/.bash_profile:

	'[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

## Step 3: Install [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/) and [Passenger](http://www.modrails.com/)

	. $HOME/.rvm/scripts/rvm
	rvm install ree
	rvm use ree
	gem install passenger

## Step 4: Install [Nginx](http://wiki.nginx.org/)

	rvm use ree
	brew install nginx --with-passenger

Install the start-up plist:

	if [ ! -e ~/Library/LaunchAgents ]; then
		mkdir ~/Library/LaunchAgents
	fi

	cp /usr/local/Cellar/nginx/`ls -1 /usr/local/Cellar/nginx| tail -n 1`/org.nginx.nginx.plist ~/Library/LaunchAgents

## Step 5: Install [MongoDB](http://mongodb.org/)

If you previously had MongoDB installed you will need to unload mongodb and remove the launch daemon. Correct that by running:

	sudo launchctl unload /Library/LaunchDaemons/org.mongodb.mongod.plist
	sudo rm -r /Library/LaunchDaemons/org.mongodb.mongod.plist

Install MongoDB:

	brew install mongodb

Read the Caveats presented after installation about installing or upgrading the launch daemon.

Check that MongoDB is running:

	http://localhost:28017/

## Step 6: Install [MySQL](http://mysql.org/)

	brew install mysql

Note the instructions for copying the .plist file if you want to have MySQL automatically start when you log in.

## Step 7: Install [PHP](http://php.net/) (optionally, but recommended) and [spawn-fcgi](http://redmine.lighttpd.net/projects/spawn-fcgi)

	brew create http://ca2.php.net/distributions/php-5.2.17.tar.gz

When an editor is opened up with the "formula", replace it with the contents of [[https://gist.github.com/raw/945421/607ab7931525ba9447c0348c328439a584d97ac7/php.rb]].

Next, Install PHP

	brew install php --with-mysql

Then install spawn-fcgi:

	brew install spawn-fcgi

Download a launchctl plist file to ensure this PHP server is running:

	cd ~/Library/LaunchAgents
	curl -O https://gist.github.com/raw/945447/724201ab0d5e2834eafae0444aa9c2e5ee977f3e/net.lighttpd.spawn-fcgi.plist
	launchctl load -w ~/Library/LaunchAgents/net.lighttpd.spawn-fcgi.plist

## Step 8: Back to nginx

Let's now replace the stock config with what we've got in this repo:

	cd /usr/local/etc
	mv nginx nginx.orig
	# you might want to fork this repo so you can make your own changes...
	# if so, go here: [[https://github.com/coverall/nginx/fork]]
	git clone git@github.com:coverall/nginx.git
	
	# all configs are going to point to /usr/local/sites, so let's link this
	# up to your home...
	cd /usr/local
	ln -s ~/Sites sites

	
Now start it up with launchctl:

	launchctl load -w ~/Library/LaunchAgents/org.nginx.plist

Nginx runs under your own user, so it can't use a privileged port. Instead it runs on port 8080. You may want to have it run on port 80, and if so you can add a simple firewall script to forward the port. (This is totally optional.)

	cd /Library/LaunchDaemons
	sudo curl -O https://gist.github.com/raw/945906/d817356fb5db195c7c4c46fd39f5f5cac6db6e8f/com.coverallcrew.firewall.plist
	sudo launchctl load -w com.coverallcrew.firewall.plist

If you want an easy way to restart nginx, add the following to your ~/.bash_profile file:

	alias restart-nginx="kill \`cat /usr/local/var/run/nginx.pid\`"

# Upstreams

If you look in ```/usr/local/etc/nginx/upstreams```, you will see all of the "upstreams", or "proxies" we have defined. Note that the *attendease* API is set to run on port 4000, and so to start that up on that port, run:

	cd /usr/local/sites/attendease
	rails s -p 4000


