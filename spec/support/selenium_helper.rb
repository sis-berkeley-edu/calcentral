if ENV["UI_TEST"]

  require 'selenium-webdriver'
  require 'page-object'
  require 'csv'
  require 'json'

  require_relative '../ui_selenium/pages/cal_central_pages'

  Dir[Rails.root.join('spec', 'ui_selenium', 'util', "**.rb")].each { |f| require f }

  require_relative '../ui_selenium/pages/api_my_academics_page'

  Dir[Rails.root.join('spec', 'ui_selenium', 'pages', "api**.rb")].each { |f| require f }

  require_relative '../ui_selenium/pages/splash_page'
  require_relative '../ui_selenium/pages/my_dashboard_page'
  require_relative '../ui_selenium/pages/my_academics_page'
  require_relative '../ui_selenium/pages/my_academics_class_page'
  require_relative '../ui_selenium/pages/my_academics_book_list_page'
  require_relative '../ui_selenium/pages/my_campus_page'
  require_relative '../ui_selenium/pages/my_finances_pages'
  require_relative '../ui_selenium/pages/my_finances_landing_page'
  require_relative '../ui_selenium/pages/my_finances_details_page'
  require_relative '../ui_selenium/pages/my_finances_billing_page'
  require_relative '../ui_selenium/pages/my_finances_financial_aid_page'
  require_relative '../ui_selenium/pages/my_profile_page'
  require_relative '../ui_selenium/pages/my_toolbox_page'

  require_relative '../ui_selenium/pages/cal_net_auth_page'
  require_relative '../ui_selenium/pages/google_page'

  Dir[Rails.root.join('spec', 'ui_selenium', 'pages', "**card.rb")].each { |f| require f }

end
