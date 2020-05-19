require "rvm/capistrano"
require "bundler/capistrano"
require_relative "settings/server_config"

settings = ServerConfig.get_settings(Dir.home + "/.calcentral_config/server_config.yml")

set :application, "Calcentral"

role(:calcentral_dev_host) { settings.dev.servers }
set :user, settings.common.user
set :branch, settings.common.branch
set :project_root, settings.common.root

# Calcentral_dev is the IST configured server setup we have for calcentral-dev.berkeley.edu. It
# currently consists of 3 app servers (which also run memcached), a shared postgres instance,
# and 1 elasticsearch server.
namespace :calcentral_dev do
  desc "Update and restart the calcentral_dev machine"
  task :colddeploy, :roles => :calcentral_dev_host do
    # This task is used for BCS cutovers when we will put the system in maintenance mode
    # without restarting apache
    # This deployment produces an outage to the user
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; ./script/run_deploy_main.sh -w online", :hosts => server
      end
    end
  end

  desc "Update CalCentral warfile w/o resting tomcat server"
  task :hotdeploy, :roles => :calcentral_dev_host do
    # This task will be used for rolling deploy/restarts for multiple nodes
    # It takes the node out of the load balancer by shutting down apache
    # This deployment is perceived as a ZERO DOWNTIME deployment - Default
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; ./script/run_deploy_main.sh", :hosts => server
      end
    end
  end
end
