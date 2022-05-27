# README
I am following this tutorial from [GoRails](https://gorails.com/deploy/ubuntu/20.04) and used a digitalocean droplet.

Things you may want to cover:

* Ruby version 3.0.2

* Configuration rails 7.0.0.rc1 -j esbuild --css bootstrap | with devise

* Deployment instructions

* Unsorted

```
ssh root@1.2.3.4
adduser deploy
adduser deploy sudo
nano /etc/ssh/sshd_config (change PasswordAuthentication to yes)
systemctl reload sshd
```

local:
```
ssh-copy-id deploy@1.2.3.4
ssh deploy@1.2.3.4
```

root:
```
nano /etc/ssh/sshd_config (change PasswordAuthentication to no)
systemctl reload sshd
```

deploy:
```
# Adding Node.js repository
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

# Adding Yarn repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo add-apt-repository ppa:chris-lea/redis-server


# Refresh our packages list with the new repositories
sudo apt-get update

# Install our dependencies for compiiling Ruby along with Node.js and Yarn
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn

# install ruby (takes some time)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
exec $SHELL
rbenv install 3.1.2
rbenv global 3.1.2
ruby -v
# ruby 3.1.2

# This installs the latest Bundler, currently 2.x.
gem install bundler
# Test and make sure bundler is installed correctly, you should see a version number.
bundle -v
# Bundler version 2.3.14

# Installing NGINX & Passenger
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras libnginx-mod-http-passenger
if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
sudo ls /etc/nginx/conf.d/mod-http-passenger.conf

sudo nano /etc/nginx/conf.d/mod-http-passenger.conf
(change passenger_ruby /home/deploy/.rbenv/shims/ruby;)
	
sudo service nginx start
http://1.2.3.4

# nginx
sudo rm /etc/nginx/sites-enabled/default
sudo nano /etc/nginx/sites-enabled/myapp

server {
  listen 80;
  listen [::]:80;

  server_name _;
  root /home/deploy/myapp/current/public;

  passenger_enabled on;
  passenger_app_env production;

  location /cable {
    passenger_app_group_name myapp_websocket;
    passenger_force_max_concurrent_requests_per_process 0;
  }

  # Allow uploads up to 100MB in size
  client_max_body_size 100m;

  location ~ ^/(assets|packs) {
    expires max;
    gzip_static on;
  }
}

# Creating a MySQL Database
sudo apt-get install mysql-server mysql-client libmysqlclient-dev

# Open the MySQL CLI to change root passwort from blank to something
sudo mysql -u root -p

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'YourSecretMySQLPassword';\q

sudo mysql_secure_installation

# Open the MySQL CLI to create the user and database
sudo mysql -u root -p

CREATE DATABASE IF NOT EXISTS myapp_production;
CREATE USER IF NOT EXISTS 'deploy'@'localhost' IDENTIFIED BY 'SomeFancyPassword123';
CREATE USER IF NOT EXISTS 'deploy'@'%' IDENTIFIED BY 'SomeFancyPassword123';
GRANT ALL PRIVILEGES ON myapp_production.* TO 'deploy'@'localhost';
GRANT ALL PRIVILEGES ON myapp_production.* TO 'deploy'@'%';
FLUSH PRIVILEGES;
\q

mkdir -p /home/deploy/myapp/shared/config
nano /home/deploy/myapp/shared/config/master.key (insert your key)
nano /home/deploy/myapp/shared/config/database.yml (copy your .yml)
# to check if this is needed...
nano /home/deploy/myapp/.rbenv-vars
  SERVER_IP=1.2.3.4
```

local:
```
# Setting Up Capistrano
## Gemfile (group :development)
gem "capistrano", "~> 3.10", require: false
gem "capistrano-rails", "~> 1.6", require: false
gem "capistrano-passenger"
gem "capistrano-rbenv", "~> 2.2"

bundle
cap install STAGES=production

## Capfile
require 'capistrano/rails'
require 'capistrano/passenger'
require 'capistrano/rbenv'

set :rbenv_type, :user
set :rbenv_ruby, '3.1.2'

## config/deploy.rb
set :application, "myapp"
set :repo_url, "git@github.com:i-Captain/rails_7_devise_starter.git"

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

# Only keep the last 5 releases to save disk space
set :keep_releases, 5

set :branch, ENV['BRANCH'] if ENV['BRANCH']

append :linked_files, "config/master.key", "config/database.yml"


## config/deploy/production.rb
server ENV['SERVER_IP'], user: 'deploy', roles: %w{app db web}

# Used https://github.com/rbenv/rbenv-vars @local becaused i created a lot of droplets ;)
## .rbenv-vars
SERVER_IP=1.2.3.4

# The mysql_url is used in database.yml
EDITOR="code --wait" bin/rails credentials:edit
mysql_url: mysql2://deploy:SomeFancyPassword123@localhost/myapp_production

bundle lock --add-platform x86_64-linux
git push
cap production deploy BRANCH=main
```

The bundle install --jobs 4 --quiet (frooze... on a $6 Droplet - not on $48)
...

I killed the froozen bundle with htop and called 'bundle install' as user deploy on the droplet.

After the first deploy ```sudo service nginx restart``` is needed. In some cases a classic ```reboot``` 

## Unsorted commands
```
RAILS_ENV=production bundle install

EDITOR=nano bundle exec rake credentials:edit
EDITOR=nano bin/rails credentials:edit

RAILS_ENV=production bin/rails db:rollback STEP=1
RAILS_ENV=production bin/rails db:migrate 

bin/rails c -e production
RAILS_ENV=production bundle exec rails c
RAILS_ENV=production bin/rails c

RAILS_ENV=production bundle exec rake db:reset db:migrate

EDITOR="code --wait" bin/rails credentials:edit

cat /var/log/nginx/error.log
cat /home/deploy/myapp/current/log/production.log

```

Another setup ended with
SSHKit::Runner::ExecuteError: Exception while executing as deploy@1.2.3.4: passenger-config exit status: 1
passenger-config stdout: Nothing written
passenger-config stderr: *** ERROR: Phusion Passenger(R) doesn't seem to be running. If you are sure that it
is running, then the causes of this problem could be one of....
```
sudo passenger-config validate-install
sudo passenger-memory-stats
sudo service nginx restart
sudo service nginx status
sudo nginx -t
```


## Unsorted links
- https://stackoverflow.com/questions/1274057/how-can-i-make-git-forget-about-a-file-that-was-tracked-but-is-now-in-gitign
- https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04


## Todos
* Use user-data @droplet creation https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04
* Check what steps can be used in a script after creation