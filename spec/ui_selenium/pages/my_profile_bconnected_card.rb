module CalCentralPages

  class MyProfileBconnectedCard < MyProfilePage

    include PageObject
    include CalCentralPages
    include ClassLogger

    # bConnected
    div(:bconnected_section, :class => 'cc-profile-bconnected')
    div(:connected_as, :xpath => '//div[@data-ng-if="api.user.profile.googleEmail && api.user.profile.hasGoogleAccessToken"]')
    button(:disconnect_button, :xpath => '//button[contains(.,"Disconnect")]')
    button(:disconnect_yes_button, :xpath => '//button[@data-ng-click="api.user.removeOAuth(service)"]')
    button(:disconnect_no_button, :xpath => '//button[@data-ng-click="showValidation = false"]')
    button(:connect_button, :xpath => '//button[@data-ng-click="api.user.enableOAuth(service)"]')

    def load_page
      logger.debug 'Loading bConnected page'
      navigate_to "#{WebDriverUtils.base_url}/profile/bconnected"
    end

    def disconnect_bconnected
      logger.debug 'Checking if user is connected to Google'
      bconnected_section_element.when_visible WebDriverUtils.page_load_timeout
      if disconnect_button_element.visible?
        logger.debug 'User is connected, so disconnecting from Google'
        disconnect_button
        WebDriverUtils.wait_for_element_and_click disconnect_yes_button_element
        disconnect_yes_button_element.when_not_present timeout=WebDriverUtils.page_event_timeout
        connect_button_element.when_visible timeout
        logger.info('Pausing so that OAuth token is revoked')
        sleep timeout
      else
        logger.debug 'User not connected'
      end
    end

  end
end
