#Install Ruby 1.8.7
cd /etc/yum.repos.d
wget http://centos.karan.org/el5/ruby187/kbs-el5-ruby187.repo
yum clean all
yum -y install ruby rubygems
