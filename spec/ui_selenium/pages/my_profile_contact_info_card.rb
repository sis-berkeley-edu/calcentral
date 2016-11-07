module CalCentralPages

  class MyProfileContactInfoCard < MyProfilePage

    include PageObject
    include ClassLogger

    div(:phone_section, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]')
    div(:phone_label, :xpath => '//div[text()="Phone Number"]')
    elements(:phone, :div, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//div[@data-ng-repeat="item in items.content"]')
    elements(:phone_type, :div, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//div[@data-ng-repeat="item in items.content"]//strong')
    elements(:phone_number, :span, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//div[@data-ng-repeat="item in items.content"]//span[@data-ng-bind="item.number"]')
    elements(:phone_extension, :span, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//div[@data-ng-repeat="item in items.content"]//span[@data-ng-if="item.extension"]')
    elements(:phone_edit_button, :button, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//div[@data-ng-repeat="item in items.content"]//button[contains(.,"Edit")]')

    button(:add_phone_button, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//button[@data-ng-click="showAdd()"]')
    button(:save_phone_button, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//button[contains(.,"Save")]')
    button(:cancel_phone_button, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//button[contains(.,"Cancel")]')
    button(:delete_phone_button, :xpath => '//div[@data-ng-controller="ProfilePhoneController"]//button[contains(.,"Delete phone number")]')

    form(:add_phone_form, :name => 'cc_page_widget_profile_phone')
    select_list(:phone_type_select, :id => 'cc-page-widget-profile-phone-type')
    text_area(:phone_number_input, :id => 'cc-page-widget-profile-phone-number')
    text_area(:phone_ext_input, :id => 'cc-page-widget-profile-phone-extension')
    checkbox(:phone_preferred_cbx, :id => 'cc-page-widget-profile-phone-preferred')
    span(:phone_validation_error, :xpath => '//span[@data-ng-bind="errorMessage"]')

    def load_page
      logger.debug 'Loading profile contact info page'
      navigate_to "#{WebDriverUtils.base_url}/profile/contact"
    end

    # PHONES

    def phone_types
      types = []
      phones = phone_type_elements
      phones.each { |type| types << type.text.sub(' Phone', '') }
      types
    end

    def phone_primary?(index)
      phone_elements[index].text.include? 'preferred'
    end

    def phone_numbers
      numbers = []
      phone_number_elements.each { |number| numbers << number.text }
      numbers
    end

    def phone_extensions
      # for each phone, try to find extension.  if none push nil
      extensions = []
      phone_elements.each do |phone|
        extension = span_element(:xpath => "//div[@data-ng-controller='ProfilePhoneController']//div[@data-ng-repeat='item in items.content'][#{(phone_elements.index(phone) + 1)}]//span[@data-ng-if='item.extension']")
        extension.exists? ? extensions << extension.text : extensions << nil
      end
      extensions
    end

    def phone_type_index(type)
      phone_types.index(type)
    end

    def click_add_phone
      click_element_js cancel_phone_button_element if cancel_phone_button_element.visible?
      click_element_js add_phone_button_element
    end

    def click_edit_phone(index)
      click_element_js cancel_phone_button_element if cancel_phone_button_element.visible?
      click_element_js phone_edit_button_elements[index]
    end

    def click_save_phone
      click_element_js save_phone_button_element
    end

    def click_cancel_phone
      click_element_js cancel_phone_button_element
    end

    def click_delete_phone
      click_element_js delete_phone_button_element
    end

    def enter_phone(type, number, ext, pref)
      logger.info "Entering phone of type #{type}, number #{number}, extension #{ext}"
      WebDriverUtils.wait_for_element_and_type(phone_number_input_element, number) unless number.nil?
      WebDriverUtils.wait_for_element_and_type(phone_ext_input_element, ext) unless ext.nil?
      WebDriverUtils.wait_for_element_and_select(phone_type_element, type) if (phone_type_select? && phone_type_select != type)
      if phone_preferred_cbx?
        pref ? check_phone_preferred_cbx : uncheck_phone_preferred_cbx
      end
    end

    def add_new_phone(phone, pref = false)
      click_add_phone
      enter_phone(phone['type'], phone['phoneNumberInput'], phone['phoneExt'], pref)
      click_save_phone
    end

    def edit_phone(index, phone, pref = false)
      click_edit_phone index
      enter_phone(phone['type'], phone['phoneNumberInput'], phone['phoneExt'], pref)
      click_save_phone
    end

    def delete_phone(index)
      phones = phone_elements.length
      logger.info "Deleting one of #{phones} phones"
      if cancel_phone_button_element.visible?
        click_cancel_phone
        cancel_phone_button_element.when_not_visible WebDriverUtils.page_event_timeout
      end
      click_edit_phone index
      click_delete_phone
      sleep WebDriverUtils.page_event_timeout
      wait_until(WebDriverUtils.page_event_timeout) { phone_elements.length == phones - 1 }
    end

    def delete_all_phones
      phone_count = phone_elements.length
      logger.debug "There are #{phone_count} phones to delete"
      (1..phone_count).each do
        phone_count = phone_elements.length
        # Delete the preferred phone last or it might trigger a CS validation error
        (phone_primary?(0) && phone_count > 1) ? index = 1 : index = 0
        delete_phone index
      end
    end

    # Preferred flag defaults to false
    def verify_phone(phone, pref = false)
      add_phone_form_element.when_not_present WebDriverUtils.page_event_timeout
      sleep 1
      wait_until(WebDriverUtils.page_load_timeout, "Phone type '#{phone['type']}' is not present") do
        phone_types.include? phone['type']
      end
      index = phone_type_index(phone['type'])
      wait_until(1, 'Phone preferred flag is not as expected') do
        phone_primary?(index) == pref
      end
      # Phone number is 24 characters max
      number = phone['phoneNumberDisplay'].slice(0..23)
      wait_until(1, "Phone number should be '#{number}' but instead it is '#{phone_numbers[index]}'") do
        phone_numbers[index] == number
      end
      # Phone extension is 6 characters max
      ext = phone['phoneExt']
      unless ext.nil?
        ext = ext.slice(0..5)
        wait_until(1, "Phone extension should be '#{ext}' but instead it is '#{phone_extensions[index]}'") do
          phone_extensions[index] == "ext. #{ext}"
        end
      end
    end

    # EMAIL ADDRESS

    div(:email_section, :xpath => '//div[@data-ng-controller="ProfileEmailController"]')
    div(:email_label, :xpath => '//div[text()="Email"]')
    elements(:email, :div, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//div[@data-ng-repeat="item in items.content"]')
    elements(:email_type, :div, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//div[@data-ng-repeat="item in items.content"]//strong')
    elements(:email_address, :span, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//div[@data-ng-repeat="item in items.content"]//div[@data-ng-bind="item.emailAddress"]')

    button(:add_email_button, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//button[@data-ng-click="showAdd()"]')
    button(:save_email_button, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//button[contains(.,"Save")]')
    button(:edit_email_button, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//button[@data-ng-click="showEdit(item)"]')
    button(:cancel_email_button, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//button[contains(.,"Cancel")]')
    button(:delete_email_button, :xpath => '//button[text()="Delete email"]')

    form(:email_form, :name => 'cc_page_widget_profile_email')
    select_list(:email_type_select, :id => 'cc-page-widget-profile-email-type')
    text_area(:email_input, :id => 'cc-page-widget-profile-email-address')
    checkbox(:email_preferred_cbx, :id => 'cc-page-widget-profile-email-preferred')
    span(:email_validation_error, :xpath => '//div[@data-ng-controller="ProfileEmailController"]//span[@data-ng-bind="errorMessage"]')

    def email_types
      sleep 3
      email_type_elements.map { |email| email.text.delete ' Email' }
    end

    def email_primary?(index)
      email_elements[index].text.include? 'preferred'
    end

    def email_addresses
      addresses = []
      sleep 3
      email_address_elements.each { |address| addresses << address.text }
      addresses
    end

    def email_type_index(type)
      email_types.index(type)
    end

    def click_add_email
      click_cancel_email if cancel_email_button_element.visible?
      click_element_js add_email_button_element
    end

    def click_edit_email
      cancel_email_button if cancel_email_button_element.visible?
      click_element_js edit_email_button_element
    end

    def click_save_email
      click_element_js save_email_button_element
    end

    def click_cancel_email
      click_element_js cancel_email_button_element
    end

    def enter_email(address, pref)
      logger.info "Entering email address '#{address}'"
      WebDriverUtils.wait_for_element_and_type(email_input_element, address) unless address.nil?
      if email_preferred_cbx?
        pref ? check_email_preferred_cbx : uncheck_email_preferred_cbx
      end
    end

    def add_email(address, pref = false)
      click_add_email
      enter_email(address, pref)
      click_save_email
    end

    def edit_email(address, pref = false)
      click_edit_email
      enter_email(address, pref)
      click_save_email
    end

    def delete_email
      if edit_email_button?
        click_edit_email
        click_element_js delete_email_button_element
        add_email_button_element.when_visible WebDriverUtils.page_load_timeout
      end
    end

    # ADDRESS

    div(:address_section, :xpath => '//div[@data-ng-controller="ProfileAddressController"]')
    div(:address_label, :xpath => '//div[text()="Address"]')
    elements(:address, :div, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//div[@data-ng-repeat="item in items.content"]')
    elements(:address_type, :div, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//div[@data-ng-repeat="item in items.content"]//strong')
    elements(:address_formatted, :div, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//div[@data-ng-repeat="item in items.content"]//div[@data-ng-bind="item.formattedAddress"]')
    elements(:address_edit_button, :button, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//div[@data-ng-repeat="item in items.content"]//button[contains(.,"Edit")]')

    button(:add_address_button, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//button[@data-ng-click="showAdd()"]')
    button(:save_address_button, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//button[contains(.,"Save")]')
    button(:cancel_address_button, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//button[contains(.,"Cancel")]')
    button(:delete_address_button, :xpath => '//button[text()="Delete address"]')

    select_list(:address_type_select, :id => 'cc-page-widget-profile-address-type')
    select_list(:country_select, :id => 'cc-page-widget-profile-address-country')
    span(:address_validation_error, :xpath => '//div[@data-ng-controller="ProfileAddressController"]//span[@data-ng-bind="errorMessage"]')

    def address_types
      types= []
      address_type_elements.each { |type| types << type.text.sub(' Address', '') }
      types
    end

    def unused_address_types
      address_type_select_element.options.map &:text
    end

    def all_formatted_addresses
      addresses = []
      address_formatted_elements.each { |address| addresses << address.text }
      addresses
    end

    def formatted_address(index)
      address_formatted_elements[index].text
    end

    def address_type_index(type)
      address_types.index(type)
    end

    def click_add_address
      click_cancel_address if cancel_address_button_element.visible?
      click_element_js add_address_button_element
    end

    def click_edit_address(index)
      click_cancel_address if cancel_address_button_element.visible?
      wait_until(WebDriverUtils.page_load_timeout) { address_edit_button_elements.any? }
      scroll_to_bottom
      click_element_js address_edit_button_elements[index]
    end

    def click_save_address
      scroll_to_bottom
      click_element_js save_address_button_element
    end

    def click_cancel_address
      scroll_to_bottom
      click_element_js cancel_address_button_element
      cancel_address_button_element.when_not_visible WebDriverUtils.page_event_timeout rescue Selenium::WebDriver::Error::StaleElementReferenceError
    end

    def wait_for_address_form(address)
      logger.info "Waiting for the #{address['country']} address form to appear"
      address['inputs'].each do |input|
        label = span_element(:xpath => "//label[@for='cc-page-widget-profile-field-#{input['index']}']/span")
        wait_until(1, "The label '#{input['label']}' is not present") do
          label.when_visible(1)
          label.text == input['label']
        end rescue Selenium::WebDriver::Error::StaleElementReferenceError
      end
      unless address['selects'].nil?
        address['selects'].each do |select|
          label = span_element(:xpath => "//label[@for='cc-page-widget-profile-field-#{select['index']}']/span")
          label.when_visible(1)
          wait_until(1, "The label '#{select['label']}' is not present") do
            label.text == select['label']
          end
        end
      end
      true
    end

    def load_country_form(address)
      WebDriverUtils.wait_for_element_and_select(country_select_element, address['country']) unless country_select == address['country']
      wait_for_address_form address
      scroll_to_bottom
    end

    def enter_address(address, inputs, selections)
      logger.info "Entering an address in #{address['country']}"
      load_country_form address
      inputs.each do |input|
        WebDriverUtils.wait_for_element_and_type(text_area_element(:id => "cc-page-widget-profile-field-#{input['index']}"), input['text'])
      end
      unless selections.nil?
        selections.each do |select|
          select_element = select_list_element(:id => "cc-page-widget-profile-field-#{select['index']}")
          WebDriverUtils.wait_for_element_and_select(select_element, select['option']) unless select_element.selected?(select['option'])
        end
      end
    end

    def clear_address_fields(address, inputs, selections)
      logger.info 'Removing inputs and selections'
      load_country_form address
      unless inputs.nil?
        inputs.each do |input|
          WebDriverUtils.wait_for_element_and_type(text_area_element(:id => "cc-page-widget-profile-field-#{input['index']}"), '')
        end
      end
      unless selections.nil?
        selections.each do |select|
          select_element = select_list_element(:id => "cc-page-widget-profile-field-#{select['index']}")
          default_option = select_element.options.find { |option| option.text.include? 'Choose' }
          select_element.select default_option.text unless select_element.selected?(default_option.text)
        end
      end
    end

    def add_address(address, inputs, selections)
      click_add_address
      enter_address(address, inputs, selections)
      click_save_address
    end

    def edit_address(index, address, inputs, selections)
      click_edit_address index
      enter_address(address, inputs, selections)
      click_save_address
    end

    def trimmed_input(input)
      # returns the max allowed input in a field regardless of what a user attempts to enter
      input['text'].slice(0..(input['max'] - 1)).strip
    end

    def verify_address(address, index, inputs, selections)
      wait_until(WebDriverUtils.page_load_timeout, 'Timed out waiting for the new address to appear') do
        all_formatted_addresses.length == 2
        sleep 1
        all_formatted_addresses.find { |item| item.include? trimmed_input(inputs[0]) } rescue Selenium::WebDriver::Error::StaleElementReferenceError
      end
      logger.debug "Address displayed is \n#{formatted_address(index)}"
      inputs.each do |input|
        if input['display'].nil?
          logger.debug "Checking that '#{input['text']}' is visible"
          wait_until(1, "The text '#{trimmed_input(input)}' is not present") do
            formatted_address(index).include? trimmed_input(input)
          end
        elsif !input['display']
          logger.debug "Checking that '#{input['text']}' is not visible"
          wait_until(1, "The text '#{input['text']}' is present but it should not be") do
            !formatted_address(index).include? trimmed_input(input)
          end
        end
      end
      unless selections.nil?
        selections.each do |select|
          logger.debug "Checking that '#{select['option']}' is visible"
          wait_until(1, "The option '#{select['option']}' is not present") do
            formatted_address(index).include? select['option']
          end
        end
      end
      unless address['country'] == 'United States'
        wait_until(1, "The country '#{address['country']}' is not present but it should be") do
          formatted_address(index).include? address['country']
        end
      end
    end

    def verify_req_field_error(address)
      req_inputs = address['inputs'].select { |input| input['req'] }
      nonreq_inputs = address['inputs'].reject { |input| input['req'] }
      address_validation_error_element.when_visible WebDriverUtils.page_event_timeout
      logger.debug "Validation error says '#{address_validation_error}'"
      req_inputs.each do |req|
        wait_until(1, "Error message does not include '#{req['label']}'") do
          address_validation_error.include? req['label']
        end
      end
      nonreq_inputs.each do |nonreq|
        wait_until(1, "Error message includes '#{nonreq['label']}'") do
          !address_validation_error.include? nonreq['label']
        end
      end
    end

  end
end
