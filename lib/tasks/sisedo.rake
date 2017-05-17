namespace :sisedo do
  desc 'Performs checks on SISEDO views'
  task :check => :environment do
    report = EdoOracle::ViewChecker.new.perform_checks
    puts ''
    puts '--- SISEDO Checkup ----------'
    puts ''
    puts 'Successes:'
    report[:successes].each do |success|
      puts "- \e[32m#{success}\e[0m"
    end
    puts ''
    puts 'Errors:'
    report[:errors].each do |error|
      puts "- \e[31m#{error}\e[0m"
    end
    puts ''
    puts '-----------------------------'
    puts ''
  end
end
