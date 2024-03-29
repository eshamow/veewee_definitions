# Much of this was based on http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

#kernel source is needed for vbox additions
yum -y install gcc bzip2 make kernel-devel-`uname -r`
yum -y update
yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel git
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso


sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

#poweroff -h

exit
