require 'digest/md5'
CURRENT_DIR       = File.dirname(__FILE__)
PRESEED_MD5       = "#{Digest::MD5.file("#{CURRENT_DIR}/preseed.cfg").hexdigest}"
#ISO_MD5           = "#{Digest::MD5.file("#{CURRENT_DIR}/../../iso/ubuntu-10.04.3-server-amd64.iso").hexdigest}"

Veewee::Session.declare( {
  :boot_cmd_sequence    => [
                           "<Esc><Esc><Enter>",
                           "/install/vmlinuz ",
                           "noapic ",
                           "auto-install/enable",
                           "console-setup/ask_detect=false ",
                           "console-setup/modelcode=pc105 ",
                           "console-setup/layoutcode=us ",
                           "debconf/priority=critical ",
                           "debconf/frontend=noninteractive ",
                           "debian-installer=en_US ",
                           "debian-installer/locale=en_US ",
                           "debian-installer/framebuffer=false ",
                           "initrd=/install/initrd.gz ",
                           "kbd-chooser/method=us ",
                           "netcfg/get_hostname=%NAME% ",
                           "netcfg/dhcp_timeout=60 ",
                           "netcfg/choose_interface=auto ",
                           "preseed/interactive=false ",
                           "preseed/url=http://%IP%:%PORT%/preseed.cfg ",
                           "preseed/url/checksum=#{PRESEED_MD5} ",
                           "interface=eth0",
                           "DEBCONF_DEBUG=5 ",
                           "-- <Enter>"
                           ],
  :boot_wait            => "10",
  :cpu_count            => '1',
  :disk_size            => '10140',
  :disk_format          => 'VMDK',
  :hostiocache          => 'on',
  :iso_download_timeout => "60",
  :iso_file             => "ubuntu-10.04.3-server-amd64.iso",
  :iso_src              => "http://releases.ubuntu.com/10.04.3/ubuntu-10.04.3-server-amd64.iso",
  :iso_md5              => "b446b36430a29f3dcf0c5eb797197cac",
  :kickstart_file       => "preseed.cfg",
  :kickstart_port       => "7122",
  :kickstart_timeout    => "60",
  :memory_size          => '384',
  :os_type_id           => 'Ubuntu_64',
  :postinstall_files    => [ "postinstall.sh" ],
  :postinstall_timeout  => "10000",
  :ssh_login_timeout    => "60",
  :ssh_user             => "vagrant",
  :ssh_password         => "vagrant",
  :ssh_key              => "",
  :ssh_host_port        => "7222",
  :ssh_guest_port       => "22",
  :sudo_cmd             => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd         => "shutdown -h now",
  :use_hw_virt_ext      => 'off',
  :use_pae              => 'on',
  :interfaces           => ["nat","hostonly"],
  :hostonly_network     => "vboxnet0"
})
