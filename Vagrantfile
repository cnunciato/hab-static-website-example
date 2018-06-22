Vagrant.configure 2 do |config|
  config.vm.box = 'bento/ubuntu-17.10'
  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.provision :shell, path: 'provision.sh', privileged: true

  config.vm.provider 'vmware_fusion' do |v|
    v.vmx["memsize"] = '4096'
    v.vmx["numvcpus"] = '2'
  end
end
