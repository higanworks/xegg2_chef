class Chef
  class Knife
    class SakuraCreate < Knife
      banner "sakura create (options)"

      option :sakuracloud_api_token,
        :short => "-K TOKEN",
        :long => "--sakuracloud-api-token TOKEN",
        :description => "Your SakuraCloud API TOKEN",
        :proc => Proc.new { |token| Chef::Config[:knife][:sakuracloud_api_token] = token }

      option :sakuracloud_api_token_secret,
        :long => "--sakuracloud-api-token-secret SECRET",
        :description => "Your SakuraCloud API TOKEN SECRET",
        :proc => Proc.new { |secret| Chef::Config[:knife][:sakuracloud_api_token_secret] = secret }


      def run
        puts 'Hello'
      end
    end
  end
end
