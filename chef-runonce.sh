#!/bin/bash

# this is created from knife bootstrap using chef-full.erb template
# updates should probably come from that, not manually written, other
# than 'run once' hacks

this_script=/etc/init.d/chef-runonce
log=/var/log/chef-runonce.log
exec > >(tee ${log}) 2>&1

# Check the host name.  If it starts with gene(ric), it hasn't customized yet
h=`hostname | sed 's/^\(....\).*$/\1/'` 
if [ "$h" == "gene" ] ; then
  exit 1
fi

# Make sure we have network access
ping -c 2 -W 1 10.70.0.1 > /dev/null 2>&1 || exit 1

#
# Begin parsed chef-full.erb
#

exists() {
  if command -v $1 &>/dev/null
  then
    return 0
  else
    return 1
  fi
}

install_sh="https://www.opscode.com/chef/install.sh"
version_string="-v 11.6.0"

if ! exists /usr/bin/chef-client; then
  if exists wget; then
    bash <(wget  ${install_sh} -O -) ${version_string}
  elif exists curl; then
    bash <(curl -L  ${install_sh}) ${version_string}
  else
    echo "Neither wget nor curl found. Please install one and try again." >&2
    exit 1
  fi
fi

mkdir -p /etc/chef

cat > /etc/chef/validation.pem <<EOP
### insert validation.pem here ###

EOP
chmod 0600 /etc/chef/validation.pem



cat > /etc/chef/client.rb <<EOP
log_level        :auto
log_location     STDOUT
chef_server_url  "https://chefserver.example.com:443"
validation_client_name "chef-validator"
# Using default node name (fqdn)

EOP

cat > /etc/chef/first-boot.json <<EOP
{"run_list":["role[base]","role[nagios-client]"]}
EOP

chef-client -j /etc/chef/first-boot.json -E _default

#
# End parsed chef-full.erb
#

/usr/sbin/update-rc.d -f chef-runonce remove
rm ${this_script}
