#!/bin/bash -e

# Generate default site if not present
if [ ! -d /usr/local/moin/config ] || [ -z $(ls -A /usr/local/moin/config) ]
then
    cp -r /usr/local/share/moin/config/* /usr/local/moin/config/
    sed -i "s/instance_dir = wikiconfig_dir/instance_dir = os.path.join(wikiconfig_dir, os.pardir)/" /usr/local/moin/config/wikiconfig.py
	sed -i 's/#superuser = \[u"YourName", \]/superuser = \[u"Admin", \]/' /usr/local/moin/config/wikiconfig.py
    sed -i 's/logfile=\/tmp\/moin.log/logfile=\/usr\/local\/moin\/log\/moin.log/' /usr/local/moin/config/logging/logfile
fi
if [ ! -d /usr/local/moin/data ] || [ -z $(ls -A /usr/local/moin/data) ]
then
    cp -r /usr/local/share/moin/data/* /usr/local/moin/data/
fi
if [ ! -d /usr/local/moin/underlay ] || [ -z $(ls -A /usr/local/moin/underlay) ]
then
    cp -r /usr/local/share/moin/underlay/* /usr/local/moin/underlay/
fi

# Correct permissions
chown -R moin:moin /usr/local/moin
chmod -R ug+rwX /usr/local/moin

# Run command
exec "$@"
