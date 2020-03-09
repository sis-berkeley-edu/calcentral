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
  task :update, :roles => :calcentral_dev_host do
    # Take everything offline first.
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; ./script/update-build-tomcat.sh", :hosts => server
      end
    end
  end

  desc "Update and restart the calcentral_dev machine"
  task :colddeploy, :roles => :calcentral_dev_host do
    # Take everything offline first.
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; ./script/update-build-tomcat-test.sh -o offline", :hosts => server
      end
    end
  end

  desc "Update CalCentral warfile w/o resting tomcat server"
  task :hotdeploy, :roles => :calcentral_dev_host do
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; ./script/update-build-tomcat-test.sh", :hosts => server
      end
    end
  end
end
