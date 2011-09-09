# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common


# Install Ruby 1.8.7
apt-get -y  install ruby1.8 rubygems ruby git-core libopenssl-ruby

# Install envpuppet
cd /usr/local/src
git clone git://github.com/puppetlabs/puppet.git
git clone git://github.com/puppetlabs/facter.git
cd puppet
git checkout tags/2.6.9
cd ../facter
git checkout tags/1.5.8
export ENVPUPPET_BASEDIR=/usr/local/src
cd /usr/bin

#cp $ENVPUPPET_BASEDIR/puppet/ext/envpuppet .
wget https://raw.github.com/jeffmccune/puppet/feature/2.6.x/6395/ext/envpuppet

cat > /usr/bin/puppet << EOF
#! /bin/bash
export ENVPUPPET_BASEDIR=/usr/local/src
eval \$(envpuppet)
exec "\${ENVPUPPET_BASEDIR}"/puppet/bin/puppet \$@
EOF

cat > /usr/bin/facter << EOF
#! /bin/bash
export ENVPUPPET_BASEDIR=/usr/local/src
eval \$(envpuppet)
exec "\${ENVPUPPET_BASEDIR}"/facter/bin/facter \$@
EOF

chmod +x /usr/bin/puppet
chmod +x /usr/bin/facter
chmod +x /usr/bin/envpuppet
echo "export ENVPUPPET_BASEDIR=/usr/local/src" >> /etc/bashrc

## Install chef
#/opt/ruby/bin/gem install chef --no-ri --no-rdoc
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install chef

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
exit
