module CalCentralPages

  include PageObject
  include ClassLogger

  PageObject.javascript_framework = (:angularjs)

  # Header
  link(:my_dashboard_link, :text => 'My Dashboard')
  link(:my_academics_link, :text => 'My Academics')
  link(:my_campus_link, :text => 'My Campus')
  link(:my_finances_link, :text => 'My Finances')
  link(:my_toolbox_link, :text => 'My Toolbox')

  # Email Badge
  button(:email_badge, :xpath => '//button[@title="bMail"]')
  div(:email_count, :xpath => '//button[@title="bMail"]/div[@data-ng-bind="badge.count"]')
  h4(:unread_email_heading, :xpath => '//h4[text()="Unread bMail Messages"]')
  h4(:email_not_connected_heading, :xpath => '//h4[text()="bMail (Not connected)"]')
  link(:email_one_link, :xpath => '//button[@title="bMail"]/following-sibling::div//a[@data-ng-href="http://bmail.berkeley.edu/"]')
  div(:email_one_sender, :xpath => '//button[@title="bMail"]/following-sibling::div//div[@data-ng-bind="item.editor"]')
  span(:email_one_subject, :xpath => '//button[@title="bMail"]/following-sibling::div//span[@data-ng-bind="item.title"]')
  span(:email_one_summary, :xpath => '//button[@title="bMail"]/following-sibling::div//span[@data-ng-bind="item.summary"]')

  # Calendar Badge
  button(:calendar_badge, :xpath => '//button[@title="bCal"]')

  # Drive Badge
  button(:drive_badge, :xpath => '//button[@title="bDrive"]')

  # Popover: Profile, Status, Log Out
  list_item(:status_loading, :xpath => '//li[@data-ng-show="statusLoading"]')
  button(:profile_icon, :xpath => '//button[@title="Settings"]')
  span(:popover_first_name, :class => 'cc-popover-gear-first-name')
  span(:status_alert_count, :xpath => '//span[@data-ng-if="hasAlerts"]/span[@data-ng-bind="count"]')
  h4(:status_popover_heading, :xpath => '//div[@class="cc-popover-title"]/h4')
  div(:no_status_alert, :xpath => '//div[@class="cc-popover-noitems ng-scope"]')
  image(:no_status_alert_icon, :xpath => '//div[@class="cc-popover-noitems ng-scope"]/i[@class="cc-left fa fa-check-circle cc-icon-green"]')

  div(:reg_status_alert, :xpath => '//li[contains(@data-ng-if,"regStatus")]//div')
  link(:reg_status_alert_link, :xpath => '//li[contains(@data-ng-if,"regStatus")]/a')
  image(:reg_status_alert_icon, :xpath => '//li[contains(@data-ng-if,"regStatus")]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')

  div(:hold_status_alert, :xpath => '//li[contains(@data-ng-if, "csHolds")]//div')
  span(:hold_status_alert_number, :xpath => '//li[contains(@data-ng-if, "csHolds")]//span')
  link(:hold_status_alert_link, :xpath => '//li[contains(@data-ng-if, "csHolds")]/a')
  image(:hold_status_alert_icon, :xpath => '//li[contains(@data-ng-if, "csHolds")]//i[@class="fa fa-exclamation-circle cc-icon-red"]')

  div(:amount_due_status_alert, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//div')
  span(:amount_due_amount, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//span[@data-ng-bind="minimumAmountDue | currency"]')
  link(:amount_due_status_alert_link, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//a')
  image(:amount_due_status_alert_icon, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//i[@class="cc-left fa fa-exclamation-triangle cc-icon-gold"]')
  image(:amount_overdue_status_alert_icon, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')

  div(:finaid_status_alert, :xpath => '//li[@data-ng-if="countUndatedFinaid > 0"]//div')
  link(:finaid_status_alert_link, :xpath => '//li[@data-ng-if="countUndatedFinaid > 0"]//a')
  image(:finaid_status_alert_icon, :xpath => '//li[@data-ng-if="countUndatedFinaid > 0"]//i[@class="fa fa-exclamation-circle cc-icon-red"]')
  span(:finaid_status_alert_count, :xpath => '//li[@data-ng-if="countUndatedFinaid > 0"]//span[@data-ng-bind="countUndatedFinaid"]')

  button(:profile_link, :xpath => '//button[contains(text(),"Profile")]')
  button(:logout_link, :xpath => '//button[contains(text(),"Log out")]')

  # Footer
  div(:toggle_footer_link, :xpath => '//div[@class="cc-footer-berkeley"]/div')
  text_field(:basic_auth_uid_input, :name => 'email')
  text_field(:basic_auth_password_input, :name => 'password')
  button(:basic_auth_login_button, :xpath => '//button[contains(text(),"Login")]')

  button(:stop_viewing_as, :xpath => '//button[@data-ng-click="admin.stopActAs()"]')
  button(:delegate_stop_viewing_as, :xpath => '//button[@data-ng-click="admin.stopDelegateActAs()"]')

  # 404
  h3(:not_found, :xpath => '//h3[text()="Cannot Find That Page"]')
  h1(:access_denied, :xpath => '//h1[text()="Access Denied"]')
  h1(:unexpected_error, :xpath => '//h1[text()="Unexpected Error"]')

  def click_my_dashboard_link
    logger.info('Clicking My Dashboard link')
    WebDriverUtils.wait_for_page_and_click my_dashboard_link_element
  end

  def click_my_academics_link
    logger.info('Clicking My Academics link')
    WebDriverUtils.wait_for_page_and_click my_academics_link_element
  end

  def click_my_campus_link
    logger.info('Clicking My Campus link')
    WebDriverUtils.wait_for_page_and_click my_campus_link_element
  end

  def click_my_finances_link
    logger.info('Clicking My Finances link')
    WebDriverUtils.wait_for_page_and_click my_finances_link_element
  end

  def click_my_toolbox_link
    logger.info 'Clicking My Toolbox link'
    WebDriverUtils.wait_for_page_and_click my_toolbox_link_element
  end

  def click_email_badge
    logger.info('Clicking email badge on Dashboard')
    WebDriverUtils.wait_for_page_and_click email_badge_element
  end

  def show_unread_email
    unless unread_email_heading_element.visible?
      email_badge
      unread_email_heading_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    end
  end

  def open_profile_popover
    WebDriverUtils.wait_for_page_and_click profile_icon_element unless logout_link_element.visible?
    logout_link_element.when_visible WebDriverUtils.page_event_timeout
  end

  def click_reg_status_alert
    WebDriverUtils.wait_for_page_and_click reg_status_alert_element
  end

  def click_hold_status_alert
    WebDriverUtils.wait_for_element_and_click hold_status_alert_element
  end

  def click_amt_due_alert
    WebDriverUtils.wait_for_page_and_click amount_due_status_alert_element
  end

  def alert_amt_due
    amount_due_amount.delete('$,')
  end

  def click_profile_link(driver)
    logger.info 'Clicking Profile link'
    open_profile_popover
    WebDriverUtils.wait_for_element_and_click profile_link_element
    CalCentralPages::MyProfilePage::MyProfileBasicInfoCard.new driver
  end

  def click_logout_link
    logger.info('Logging out of CalCentral')
    open_profile_popover
    WebDriverUtils.wait_for_element_and_click logout_link_element
  end

  def log_out(splash_page)
    navigate_to WebDriverUtils.base_url
    toggle_footer_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    if title.include? 'Dashboard'
      click_logout_link
      splash_page.sign_in_element.when_visible timeout
    end
  end

  def basic_auth(uid)
    logger.info('Logging in using basic auth')
    scroll_to_bottom
    WebDriverUtils.wait_for_page_and_click toggle_footer_link_element
    WebDriverUtils.wait_for_element_and_type(basic_auth_uid_input_element, uid)
    WebDriverUtils.wait_for_element_and_type(basic_auth_password_input_element, UserUtils.basic_auth_pass)
    login = basic_auth_login_button_element
    basic_auth_login_button
    login.when_not_present(timeout=WebDriverUtils.page_load_timeout)
    basic_auth_login_button_element.when_present(timeout)
    basic_auth_uid_input_element.when_not_visible(timeout)
  end

  def click_class_link_by_text(link_text)
    WebDriverUtils.wait_for_page_and_click link_element(:link_text => link_text)
  end

  def click_class_link_by_url(url)
    WebDriverUtils.wait_for_page_and_click link_element(:xpath => "//a[@href='#{url}']")
  end

  def stop_viewing_as
    WebDriverUtils.wait_for_element_and_click stop_viewing_as_element
    stop_viewing_as_element.when_not_present WebDriverUtils.page_event_timeout
  end

  def delegate_stop_viewing
    if delegate_stop_viewing_as?
      logger.debug 'Stopping delegate view-as'
      delegate_stop_viewing_as
      sleep 1
    end
  end

  def click_element_js(element)
    wait_until(WebDriverUtils.page_event_timeout) { element.exists?; element.visible? }
    execute_script('arguments[0].click();', element)
  end

  def scroll_to_bottom
    execute_script('window.scrollTo(0, document.body.scrollHeight);')
    sleep 1
  end
end
