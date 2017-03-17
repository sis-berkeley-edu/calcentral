require "rvm/capistrano"
require "bundler/capistrano"
require "config/settings/server_config"

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
    run "cd #{project_root}; ./script/init.d/calcentral stop"
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        # update source
        run "cd #{project_root}; ./script/update-build.sh", :hosts => server

        # Run db migrate on the first app server ONLY
        if index == 0
          logger.debug "---- Server: #{server.host} running migrate in transaction on offline app servers"
          run "cd #{project_root}; ./script/migrate.sh", :hosts => server
        end

        # start it up
        run "cd #{project_root}; ./script/init.d/calcentral start", :hosts => server

        if index < (servers.length - 1)
          # Allow time for Torquebox to quiesce before adding a node to the cluster. This appears to
          # be needed to ensure that message processing is properly spread across the cluster, although
          # that constraint is undocumented. See CLC-4318.
          sleep 120
        end
      end
    end
  end
end
