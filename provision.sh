#!/bin/bash

# Add the hab user and group
groupadd hab || 'Group hab already exists.'
useradd -g hab hab  || 'User hab already exists.'

# Download and install the latest hab package
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | bash

# Make a Systemd unit for the Supervisor
echo "[Unit]
Description=The Habitat Supervisor

[Service]
ExecStart=/bin/hab sup run

[Install]
WantedBy=default.target
" > /etc/systemd/system/hab-sup.service

# Start the Supervisor service
systemctl start hab-sup
