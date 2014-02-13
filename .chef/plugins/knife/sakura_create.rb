class Chef
  class Knife
    class SakuraCreate < Knife
      banner "sakura create (options)"

      deps do
        require 'fog'
        Chef::Knife::Bootstrap.load_deps
      end

      option :sakuracloud_api_token,
        :short => "-K TOKEN",
        :long => "--sakuracloud-api-token TOKEN",
        :description => "Your SakuraCloud API TOKEN",
        :proc => Proc.new { |token| Chef::Config[:knife][:sakuracloud_api_token] = token },
        :default => Chef::Config[:knife][:sakuracloud_api_token]

      option :sakuracloud_api_token_secret,
        :long => "--sakuracloud-api-token-secret SECRET",
        :description => "Your SakuraCloud API TOKEN SECRET",
        :proc => Proc.new { |secret| Chef::Config[:knife][:sakuracloud_api_token_secret] = secret },
        :default => Chef::Config[:knife][:sakuracloud_api_token_secret]

      option :sakuracloud_ssh_key,
        :long => "--sakuracloud-ssh-key",
        :description => "Your SakuraCloud SSH Key",
        :proc => Proc.new { |key| Chef::Config[:knife][:sakuracloud_ssh_key] = key },
        :default => Chef::Config[:knife][:sakuracloud_ssh_key]

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'chef-full'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "chef-full"

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      def run
        ::Fog.credentials[:sakuracloud_api_token] =  Chef::Config[:knife][:sakuracloud_api_token]
        ::Fog.credentials[:sakuracloud_api_token_secret] =  Chef::Config[:knife][:sakuracloud_api_token_secret]

        compute = ::Fog::Compute[:sakuracloud]
        server = compute.servers.create({
          :sshkey => '112600032208',        # Your SSH Key id
          :serverplan => '2001',            # Server Type
          :volume => {
            :diskplan => 4,                   # Type SSD
            :sourcearchive => '112500463685'  # Ubuntu12.04
          },
          :boot => true
        })

        bootstrap_ip_address = server.interfaces.first['IPAddress']
        Chef::Log.debug(server.attributes)
        bootstrap_node(server, bootstrap_ip_address).run
      end

      def bootstrap_node(server, bootstrap_ip_address)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [bootstrap_ip_address]
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:first_boot_attributes] = config[:first_boot_attributes]
        bootstrap.config[:ssh_user] = config[:ssh_user] || "ubuntu"
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        bootstrap.config[:chef_node_name] = config[:chef_node_name] || server.name
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        # bootstrap will run as root...sudo (by default) also messes up Ohai on CentOS boxes
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        # bootstrap.config[:template_file] = 'chef-full.erb'
        bootstrap.config[:environment] = config[:environment]
        bootstrap
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end
    end
  end
end
