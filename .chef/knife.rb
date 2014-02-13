## Basic Settings
chef_server_url ENV['CHEF_SERVER_URL']
node_name ENV['CHEF_USER_NAME']
client_key ENV['CHEF_USER_KEY_PATH']
validation_client_name 'chef-validator'
validation_key File.expand_path('../client/chef-validator.pem' ,__FILE__)

## Chef-Repo

cookbook_path [File.expand_path('../../cookbooks', __FILE__)]
cache_path [File.expand_path('../../tmp/cache', __FILE__)]



## Keys for SakuraCloud
knife[:sakuracloud_api_token] = ENV['SAKURACLOUD_API_TOKEN']
knife[:sakuracloud_api_token_secret] = ENV['SAKURACLOUD_API_TOKEN_SECRET']
knife[:sakuracloud_ssh_key] = ENV['SAKURACLOUD_USER_KEY_ID']



