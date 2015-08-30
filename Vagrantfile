# -*- mode: ruby -*-
# vi: set ft=ruby :

Dotenv.load

# change default provider to digital_ocean
ENV['VAGRANT_DEFAULT_PROVIDER'] = "aws"

# Vagrantfile API/syntax version. 
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define :restyaboard, primary: true do |restyaboard|
    restyaboard.vm.provider :aws do |provider, override|
      override.vm.hostname          = "restyaboard"
      override.vm.box_url           = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
      override.vm.box               = "aws"
      override.ssh.username         = ENV['AWS_SSH_USERNAME']
      override.ssh.private_key_path = ENV['AWS_SSH_KEY']
      override.ssh.pty              = true

      provider.access_key_id        = ENV['AWS_ACCESS_KEY_ID']
      provider.secret_access_key    = ENV['AWS_SECRET_ACCESS_KEY']
      provider.keypair_name         = ENV['AWS_KEYPAIR_NAME']
      provider.region               = "ap-northeast-1"  # Tokyo
      provider.availability_zone    = "ap-northeast-1c" # Tokyo
      provider.ami                  = "ami-cbf90ecb"    # Tokyo Amazon Linux AMI 2015.03 (64-bit)
      provider.instance_type        = "t2.micro"
      provider.instance_ready_timeout = 120
      provider.terminate_on_shutdown  = false
      provider.security_groups      = [ENV['AWS_SECURITY_GROUP']]
      provider.tags                 = {"Name" => "restyaboard"}

      # synced folder
      override.vm.synced_folder ".", "/vagrant", disabled: true

    end
  end

end
