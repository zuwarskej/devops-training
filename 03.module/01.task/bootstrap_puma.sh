#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

# Update repository-keys
INFO "Update repository-keys for RVM"
for key in 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB; do
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys $key
done

# Compiling RVM & Ruby
INFO "Compiling RVM & Ruby"
\curl -sSL https://get.rvm.io | bash -s stable --ruby > /dev/null 2>&1
source /usr/local/rvm/scripts/rvm

# Install Puma, Bundle, Rails
INFO "Install Puma, Bundle, Rails"
gem install puma bundle rails > /dev/null 2>&1

# Create folders for Puma
INFO "Create folders for Puma"
mkdir -p /home/vagrant/app
mkdir -p /home/vagrant/app/config

# Copy puma.service
INFO "Copy config for puma.service"
FILE=/etc/systemd/system/puma.service
cat <<EOF > $FILE
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=vagrant
WatchdogSec=10
WorkingDirectory=/home/vagrant/app
Environment=RAILS_ENV=production

ExecStart=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/puma -C /home/vagrant/app/config/production.rb'
#ExecStop=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/pumapctl -F /home/vagrant/app/config/production.rb stop'
#ExecReload=/bin/bash -lc '/usr/local/rvm/gems/ruby-3.0.0/bin/pumactl -F /home/vagrant/app/config/production.rb phased-restart'

Restart=always
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# Copy production.rb
INFO "Copy config for production.rb"
FILE=/home/vagrant/app/config/production.rb
cat <<EOF > $FILE
rails_env = "production"
environment rails_env

app_dir = "/home/vagrant/app" # Update me with your root rails app path

bind  "unix://#{app_dir}/puma.sock"
pidfile "#{app_dir}/puma.pid"
state_path "#{app_dir}/puma.state"
directory "#{app_dir}/"

stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

workers 2
threads 1,2

activate_control_app "unix://#{app_dir}/pumactl.sock"

prune_bundler
EOF

# Start Puma
INFO "Start Puma"
systemctl daemon-reload
systemctl enable puma
systemctl start puma

# Check PID Puma
INFO "Check PID Puma"
ps aux | grep puma
