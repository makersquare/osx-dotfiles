Vagrant.configure('2') do |config|
  config.vm.box      = 'trusty32'
  config.vm.box_url  = '../trusty/trusty-server-cloudimg-i386-vagrant-disk1.box'
  config.vm.hostname = 'student-dev-box'

  config.vm.provider "virtualbox" do |v|
    v.memory = "1024"
  end

  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path    = 'puppet/modules'
    puppet.options        = '--verbose --debug'
  end
end
