Vagrant.configure('2') do |config|
# Build Vagrantfile. Not for student consumption
  config.vm.box      = 'mks6'
  config.vm.box_url  = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box'
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

  config.vm.provider "virtualbox" do |v|
    v.memory = "1024"
  end

  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 4567, host: 4567
  config.vm.synced_folder ".", "/home/vagrant/code/mks", type: "nfs"
end
