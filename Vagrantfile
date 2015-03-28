Vagrant.configure("2") do |config|

  config.vm.define "ca" do |machine|
    machine.vm.network "private_network", ip: "192.168.50.10"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/ca/ca-init.sh"
    machine.vm.provision :shell, :inline => "/vagrant/ca/ca-init.sh"
    machine.vm.box = "trusty64"
    machine.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    machine.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "package-precise" do |machine|
    machine.vm.network "private_network", ip: "192.168.50.11"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/box-prepare.sh"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/erlang-release.sh"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/package-deb.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/box-prepare.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/erlang-release.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/package-deb.sh"
    machine.vm.box = "precise64"
    machine.vm.box_url = "http://files.vagrantup.com/precise64.box"
    machine.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "package-trusty" do |machine|
    machine.vm.network "private_network", ip: "192.168.50.11"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/box-prepare.sh"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/erlang-release.sh"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/package/package-deb.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/box-prepare.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/erlang-release.sh"
    machine.vm.provision :shell, :inline => "/vagrant/package/package-deb.sh"
    machine.vm.box = "trusty64"
    machine.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    machine.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "build-test" do |machine|
    machine.vm.network "private_network", ip: "192.168.50.12"
    machine.vm.provision :shell, :inline => "chmod +x /vagrant/build-test/build-test.sh"
    machine.vm.provision :shell, :inline => "/vagrant/build-test/build-test.sh"
    machine.vm.box = "precise64"
    machine.vm.box_url = "http://files.vagrantup.com/precise64.box"
    machine.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--memory", "512"]
    end
  end

end
