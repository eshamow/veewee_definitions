#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

#kernel source is needed for vbox additions
yum -y install gcc bzip2 make kernel-devel-`uname -r`
#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel git
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

#Installing ruby
wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby --no-dev-docs --dont-install-useful-gems
echo 'PATH=$PATH:/opt/ruby/bin'> /etc/profile.d/rubyenterprise.sh
rm -rf ./ruby-enterprise-1.8.7-2010.02/
rm ruby-enterprise-1.8.7-2010.02.tar.gz

#Installing chef
echo "Installing chef"
/opt/ruby/bin/gem install chef --no-ri --no-rdoc || fail "Could not install chef"

# Install envpuppet
cd /usr/local/src
git clone git://github.com/puppetlabs/puppet.git
git clone git://github.com/puppetlabs/facter.git
pushd puppet
git checkout tags/2.6.6
popd
pushd facter
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

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://192.168.0.195/~eric/isos/VBoxGuestAdditions_4.1.2.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso


sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

#poweroff -h

exit
