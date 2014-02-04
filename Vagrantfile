Vagrant.configure('2') do |config|
  config.vm.box      = 'mks'
  config.vm.box_url  = 'http://192.168.1.5/mks.box'
  config.vm.hostname = 'student-dev-box'

  config.vm.provider "virtualbox" do |v|
    v.memory = "1024"
  end

  config.vm.network "private_network", ip: "10.10.10.10"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
