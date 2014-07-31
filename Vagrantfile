Vagrant.configure('2') do |config|
  config.vm.box      = 'mks4'
  config.vm.box_url  = 'https://s3.amazonaws.com/makersquare-environment/mks4.box'
  config.vm.hostname = 'student-dev-box'

  config.vm.provider "virtualbox" do |v|
    v.memory = "1024"
  end

  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 4567, host: 4567
  config.vm.synced_folder ".", "/home/vagrant/code/mks", type: "nfs"
end
