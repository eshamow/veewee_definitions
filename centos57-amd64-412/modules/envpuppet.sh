# Note - modify PUPPETVERSION and FACTERVERSION as desired

PUPPETVERSION="2.6.9"
FACTERVERSION="1.5.8"

# Install envpuppet
cd /usr/local/src
git clone git://github.com/puppetlabs/puppet.git
git clone git://github.com/puppetlabs/facter.git
cd puppet
git checkout tags/$PUPPETVERSION
cd ../facter
git checkout tags/$FACTERVERSION
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
