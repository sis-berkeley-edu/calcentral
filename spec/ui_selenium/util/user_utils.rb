class UserUtils

  include PageObject
  include CalCentralPages
  include ClassLogger

  def self.basic_auth_pass
    Settings.developer_auth.password
  end

  def self.test_password
    Settings.ui_selenium.test_user_password
  end

  def self.qa_username
    Settings.ui_selenium.ets_qa_ldap_username
  end

  def self.qa_password
    Settings.ui_selenium.ets_qa_ldap_password
  end

  def self.qa_gmail_username
    Settings.ui_selenium.ets_qa_gmail_username
  end

  def self.qa_gmail_password
    Settings.ui_selenium.ets_qa_gmail_password
  end

  def self.admin_uid
    Settings.ui_selenium.admin_uid
  end

  def self.initialize_output_csv(spec, column_headers)
    if Settings.ui_selenium.layer == 'local'
      output_dir = Rails.root.join('tmp', 'ui_selenium_ouput')
      output_file = "#{spec.inspect.sub('RSpec::ExampleGroups::', '')}.csv"
      logger.info "Initializing test output CSV named #{output_file}"
      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
      test_output = Rails.root.join(output_dir, output_file)
      CSV.open(test_output, 'wb') do |heading|
        heading << column_headers
      end
      test_output
    end
  end

  def self.add_csv_row(file, values)
    if Settings.ui_selenium.layer == 'local'
      CSV.open(file, 'a+') do |row|
        row << values
      end
    end
  end

  def self.load_test_users
    logger.info('Loading test UIDs')
    JSON.parse(File.read(WebDriverUtils.live_users))['users']
  end

  def self.load_profile_test_data
    test_data_file = File.join(CalcentralConfig.local_dir, "profile.json")
    JSON.parse(File.read(test_data_file))['users']
  end

  def self.clear_cache(driver, splash_page, my_dashboard_page)
    splash_page.load_page
    splash_page.basic_auth UserUtils.admin_uid
    driver.get "#{WebDriverUtils.base_url}/api/cache/clear"
    my_dashboard_page.load_page
    my_dashboard_page.click_logout_link
  end

end
