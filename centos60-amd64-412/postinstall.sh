#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
enabled=1
gpgcheck=0
EOM

yum -y install ruby-devel rubygems git
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all
rm /etc/yum.repos.d/{puppetlabs,epel}.repo


# Install envpuppet
cd /usr/local/src
git clone git://github.com/puppetlabs/puppet.git
git clone git://github.com/puppetlabs/facter.git
cd puppet
git checkout tags/2.6.9
cd ../facter
git checkout tags/1.5.8
export ENVPUPPET_BASEDIR=/usr/local/src
cd /usr/local/bin

#cp $ENVPUPPET_BASEDIR/puppet/ext/envpuppet .
wget https://raw.github.com/jeffmccune/puppet/feature/2.6.x/6395/ext/envpuppet

cat > /usr/local/bin/puppet << EOF
#! /bin/bash
export ENVPUPPET_BASEDIR=/usr/local/src
eval \$(envpuppet)
exec "\${ENVPUPPET_BASEDIR}"/puppet/bin/puppet \$@
EOF

cat > /usr/local/bin/facter << EOF
#! /bin/bash
export ENVPUPPET_BASEDIR=/usr/local/src
eval \$(envpuppet)
exec "\${ENVPUPPET_BASEDIR}"/facter/bin/facter \$@
EOF

chmod +x /usr/local/bin/puppet
chmod +x /usr/local/bin/facter
chmod +x /usr/local/bin/envpuppet
echo "export ENVPUPPET_BASEDIR=/usr/local/src" >> /etc/bashrc


# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://192.168.0.195/~eric/isos/VBoxGuestAdditions_4.1.2.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

exit
