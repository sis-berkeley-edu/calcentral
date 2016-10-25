module CalCentralPages

  class MyProfilePage

    include PageObject
    include CalCentralPages
    include ClassLogger

    div(:sidebar, :id => 'cc-local-navigation')

    # Profile
    link(:basic_info_link, :text => 'Basic Information')
    link(:contact_info_link, :text => 'Contact Information')
    link(:emergency_contact_link, :text => 'Emergency Contact')
    link(:demographic_info_link, :text => 'Demographic Information')

    # Privacy and Permissions
    link(:delegate_access_link, :text => 'Delegate Access')
    link(:information_disclosure_link, :text => 'Information Disclosure')
    link(:title_iv_release_link, :text => 'Title IV Release')

    # Credentials
    link(:languages_link, :text => 'Languages')
    link(:work_experience_link, :text => 'Work Experience')
    link(:honors_and_awards_link, :text => 'Academic Honors and Awards')

    # Alerts and Notifications
    link(:bconnected_link, :text => 'bConnected')

    def click_contact_info
      WebDriverUtils.wait_for_element_and_click contact_info_link_element
    end

    def click_delegate_access(driver)
      WebDriverUtils.wait_for_element_and_click delegate_access_link_element
      CalCentralPages::MyProfileDelegateAccessCard.new driver
    end

    def click_work_experience(driver)
      WebDriverUtils.wait_for_element_and_click work_experience_link_element
      work_experience_card = CalCentralPages::MyProfileWorkExperienceCard.new driver
      wait_until(WebDriverUtils.page_load_timeout) { work_experience_card.add_element.visible? }
      work_experience_card
    end

    def click_bconnected(driver)
      WebDriverUtils.wait_for_element_and_click bconnected_link_element
      CalCentralPages::MyProfileBconnectedCard.new driver
    end

    # TODO: remove this when WebDriver issue is fixed: https://github.com/SeleniumHQ/selenium/issues/1156
    def clear_and_type(element, text)
      click_element_js element
      element.clear
      element.send_keys text unless text.blank?
    end

  end
end
