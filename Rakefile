require 'ridley'
  $stdout.sync

@ridley = Ridley.new(
  server_url: ENV['CHEF_SERVER_URL'],
  client_name: ENV['CHEF_USER_NAME'],
  client_key: ENV['CHEF_USER_KEY_PATH'],
  ssl: { verify: false }
)

## initialze fog
require 'fog'
Fog.credentials[:sakuracloud_api_token] = ENV['SAKURACLOUD_API_TOKEN']
Fog.credentials[:sakuracloud_api_token_secret] = ENV['SAKURACLOUD_API_TOKEN_SECRET']
@compute = Fog::Compute[:sakuracloud]
@volume  = Fog::Volume[:sakuracloud]

desc 'create single'
task :single, :name
task :single do |x, args|
  Rake::Task[:env].invoke args.name
  Rake::Task[:role_single].invoke args.name
  Rake::Task[:boot].invoke args.name, 1
end

desc 'create replica set'
task :replica, :name
task :replica do |x, args|
  Rake::Task[:env].invoke args.name
  Rake::Task[:role_repl1].invoke args.name
  Rake::Task[:boot].invoke args.name, 3
#  Rake::Task[:role_repl2].invoke args.name
#  Rake::Task[:update].invoke args.name
end

desc 'create environment'
task :env, :name
task :env do |x, args|
  e = @ridley.environment.create(name: args.name)
  e.save
end

desc 'create role for single'
task :role_single, :name
task :role_single do |x, args|
  r = @ridley.role.new
  r.name = args.name
  r.run_list = []
  r.run_list << 'recipe[mongodb::10gen_repo]'
  r.run_list << 'recipe[mongodb::default]'
  r.save
end

desc 'create role for replicaset'
task :role_repl1, :name
task :role_repl1 do |x, args|
  r = @ridley.role.new
  r.name = args.name
  r.default_attributes[:mongodb] = {}
  r.default_attributes[:mongodb][:cluster_name] = args.name
  r.default_attributes[:mongodb][:is_replicaset] = true
  r.run_list = []
  r.run_list << 'recipe[mongodb::10gen_repo]'
  r.run_list << 'recipe[mongodb::replicaset]'
  r.save
end

desc 'create role for replicaset'
task :role_repl2, :name
task :role_repl2 do |x, args|
  r = @ridley.role.find(args.name)
  r.run_list << 'recipe[mongodb::replicaset]'
  r.run_list.uniq!
  r.save
end

desc 'create node'
task :boot, :name, :nodes
task :boot do |x, args|
  args.nodes.to_i.times do
    system("knife sakura create -E '#{args.name}' -r 'role[#{args.name}]'")
  end
end

desc 'update node'
task :update, :name
task :update do |x, args|
  system("knife ssh 'chef_environment:#{args.name}' --attribute ipaddress -x ubuntu 'sudo chef-client'")
end

desc 'cleanup chef-server'
task :cleanup do
  system("knife delete environments/*")
  system("knife delete roles/*")
  system("knife delete nodes/*")
end

namespace :sakura do
  desc 'delete all servers and disks'
  task :destroy_all do
    @compute.servers.each { |s| s.stop(true) }
    @compute.servers.each { |s| s.destroy }
    @volume.disks.each { |d| d.destroy }
  end
end
