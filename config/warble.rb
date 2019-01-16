Warbler::Config.new do |config|
  config.dirs = %w(app bin config db lib log public script vendor versions tmp)
  config.init_contents << StringIO.new("\nGem.clear_paths\nGem.path\n")
  config.jrubyc_options = "--javac"
  config.war_name = "calcentral"
end
