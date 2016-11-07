describe 'My Profile Contact Info', :testui => true, :order => :defined do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer == 'local'

    include ClassLogger

    # Load a test data file.  See sample in the ui_selenium fixtures dir.
    test_users = UserUtils.load_profile_test_data
    student = test_users.first
    contact_info = student['contactInfo']
    addresses = contact_info['addresses']

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
      @contact_info_card = CalCentralPages::MyProfileContactInfoCard.new @driver

      @splash_page.load_page
      @splash_page.basic_auth student['basicInfo']['uid']
      @my_dashboard.click_profile_link @driver
      @contact_info_card.click_contact_info
      @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) do
        @contact_info_card.phone_label_element.visible?
        @contact_info_card.email_label_element.visible?
        @contact_info_card.address_label_element.visible?
      end
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    describe 'phone number' do

      before(:all) do
        # Get rid of any existing phone data
        @contact_info_card.delete_all_phones
        @possible_phone_types = %w(Local Mobile Home/Permanent)
        @phones = contact_info['phones']
      end

      describe 'adding' do

        before(:all) do
          @mobile_phone = @phones.find { |phone| phone['type'] == 'Mobile' && phone['test'] == 'adding' }
          @home_phone = @phones.find { |phone| phone['type'] == 'Home/Permanent' && phone['test'] == 'adding' }
          @local_phone = @phones.find { |phone| phone['type'] == 'Local' && phone['test'] == 'adding' }
        end

        it 'requires that a phone number be entered' do
          @contact_info_card.click_add_phone
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
          @contact_info_card.click_cancel_phone
        end
        it 'allows a user to save a new preferred phone' do
          @contact_info_card.add_new_phone(@mobile_phone, true)
          @contact_info_card.verify_phone(@mobile_phone, true)
        end
        it 'prevents a user adding a phone of the same type as an existing one' do
          @contact_info_card.click_add_phone
          expect(@contact_info_card.phone_type_select_options).not_to include('Mobile')
        end
        it 'allows a user to save a new non-preferred phone' do
          @contact_info_card.add_new_phone @home_phone
          @contact_info_card.verify_phone @home_phone
        end
        it 'allows a maximum number of characters to be entered in each field' do
          @contact_info_card.click_add_phone
          @contact_info_card.enter_phone(@local_phone['type'], @local_phone['phoneNumberInput'], @local_phone['phoneExt'], false)
          expect(@contact_info_card.phone_number_input).to eql(@local_phone['phoneNumberInput'].slice(0..23))
          expect(@contact_info_card.phone_ext_input).to eql(@local_phone['phoneExt'].slice(0..5))
        end
      end

      describe 'editing' do

        before(:all) do
          @mobile_phone = @phones.find { |phone| phone['type'] == 'Mobile' && phone['test'] == 'editing' }
          @home_phone = @phones.find { |phone| phone['type'] == 'Home/Permanent' && phone['test'] == 'editing' }

          @mobile_index = @contact_info_card.phone_type_index 'Mobile'
          @home_index = @contact_info_card.phone_type_index 'Home/Permanent'
        end

        it 'allows a user to change the phone number and extension' do
          @contact_info_card.edit_phone(@home_index, @home_phone)
          @contact_info_card.verify_phone @home_phone
        end
        it 'allows a user to prefer a phone while editing that phone' do
          @contact_info_card.edit_phone(@home_index, @home_phone, true)
          @contact_info_card.verify_phone(@home_phone, true)
          expect(@contact_info_card.phone_primary? @mobile_index).to be false
        end
        it 'does not allow a user to un-prefer a phone while editing that phone' do
          @contact_info_card.click_edit_phone @home_index
          @contact_info_card.add_phone_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.phone_preferred_cbx?).to be false
        end
        it 'does not allow a user to change the phone type' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.add_phone_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.phone_type_select?).to be false
        end
        it 'requires that a phone number be entered' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.enter_phone(nil, '', nil, nil)
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
        end
        it 'does not require that a phone extension be entered' do
          @contact_info_card.click_edit_phone @mobile_index
          @contact_info_card.enter_phone(nil, '1234567890', nil, nil)
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to be_nil
        end
        it 'requires that a valid phone extension be entered' do
          @contact_info_card.edit_phone(@mobile_index, @mobile_phone)
          expect(@contact_info_card.phone_number_input).to be_blank
          expect(@contact_info_card.save_phone_button_element.attribute('disabled')).to eql('true')
        end
      end

      describe 'deleting' do

        before(:all) do
          @home_index = @contact_info_card.phone_type_index 'Home/Permanent'
          @mobile_index = @contact_info_card.phone_type_index 'Mobile'
        end

        it 'prevents a user deleting a preferred phone if there are more than two phones' do
          if @contact_info_card.phone_type_elements.length > 2
            @contact_info_card.click_edit_phone @home_index
            @contact_info_card.click_delete_phone
            @contact_info_card.phone_validation_error_element.when_visible WebDriverUtils.page_load_timeout
            expect(@contact_info_card.phone_validation_error).to eql('One Phone number must be checked as Preferred')
          end
        end
        it 'allows a user to delete any non-preferred phone' do
          if @contact_info_card.phone_type_elements.length > 2
            @contact_info_card.delete_phone @mobile_index
          end
        end
      end
    end

    describe 'email address' do

      describe 'adding' do

        before do
          @contact_info_card.load_page
        end

        it 'allows a user to add an email of type "Other" only' do
          unless @contact_info_card.email_types.include? 'Other'
            address = 'email@berkeley.edu.us'
            @contact_info_card.add_email(address)
            @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'New email was not saved') do
              @contact_info_card.email_addresses.include? address
            end
          end
        end

      end

      describe 'editing' do

        before(:all) do
          @index = @contact_info_card.email_type_index 'Other'
        end

        it 'allows a user to prefer an "Other" type email' do
          # This requires that the Other address not be preferred already
          unless @contact_info_card.email_primary? @index
            @contact_info_card.edit_email(nil, true)
            @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'Preferred flag not updated to true') do
              @contact_info_card.email_primary?(@index)
            end
          end
        end
        it 'does not allow a user to un-prefer an email while editing that email' do
          # This requires that Other address be preferred already
          if @contact_info_card.email_primary? @index
            @contact_info_card.click_edit_email
            @contact_info_card.email_form_element.when_visible WebDriverUtils.page_event_timeout
            expect(@contact_info_card.email_preferred_cbx?).to be false
          end
        end
        it 'allows a user to change the email address' do
          new_address = 'foo@bar.bar'
          @contact_info_card.edit_email(new_address, true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout, 'New email was not saved') do
            @contact_info_card.email_addresses.include? new_address
          end
        end
        it 'requires that an email address be entered' do
          @contact_info_card.click_edit_email
          @contact_info_card.email_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.save_email_button_element.attribute('disabled')).to be_nil
        end
        it 'prevents a user changing an email type to the same type as an existing one' do
          @contact_info_card.click_edit_email
          @contact_info_card.email_form_element.when_visible(WebDriverUtils.page_event_timeout)
          expect(@contact_info_card.email_type_select?).to be false
        end
        it 'requires that the email address include the @ and . characters' do
          @contact_info_card.edit_email('foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the . character' do
          @contact_info_card.edit_email('foo@bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address include the @ character' do
          @contact_info_card.edit_email('foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address contain at least one . following the @' do
          @contact_info_card.edit_email('foo.bar@foo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain @ as the first character' do
          @contact_info_card.edit_email('@foo.bar', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'requires that the email address not contain . as the last character' do
          @contact_info_card.edit_email('foo@bar.', true)
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_validation_error == 'Invalid email address' }
        end
        it 'allows a maximum of 70 email address characters to be entered' do
          @contact_info_card.edit_email('foobar@foobar.foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoo', true)
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.email_types.include? 'Other' }
        end
      end

      describe 'deleting' do

        it 'allows a user to delete an email of type Other' do
          # Don't try to delete the Other email if it's preferred
          @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { @contact_info_card.email_types.include? 'Other' }
          unless @contact_info_card.email_primary? @contact_info_card.email_type_index('Other')
            @contact_info_card.delete_email
            @contact_info_card.wait_until(WebDriverUtils.page_event_timeout) { !@contact_info_card.email_types.include? 'Other' }
          end
        end

      end
    end

    describe 'address' do

      before(:all) do
        @contact_info_card.load_page
        @contact_info_card.address_label_element.when_visible WebDriverUtils.page_load_timeout
        unless @contact_info_card.address_elements.any?
          @contact_info_card.add_address(addresses[0], addresses[0]['inputs'], addresses[0]['selects'])
          @contact_info_card.wait_until(WebDriverUtils.page_load_timeout) { @contact_info_card.address_elements.any? }
        end
        @possible_address_types = %w(Local Home Diploma)
        @current_address_types = @contact_info_card.address_types
        @type = @current_address_types.first
        @index = @current_address_types.index @type
        logger.info "The address for testing is '#{@type}'"
      end

      describe 'editing' do

        addresses.each do |address|

          # A WebDriver bug prevents interaction with selects, so only the default country can be tested for now
          if address['country'] == 'United States'

            it "allows a user to enter an address for #{address['country']} with max character restrictions" do
              address_inputs = address['inputs']
              address_selects = address['selects']
              @contact_info_card.load_page
              @contact_info_card.edit_address(@index, address, address_inputs, address_selects)
              @contact_info_card.verify_address(address, @index, address_inputs, address_selects)
            end
            it "requires a user to complete certain fields for an address in #{address['country']}" do
              @contact_info_card.load_page
              @contact_info_card.click_edit_address @index
              @contact_info_card.clear_address_fields(address, address['inputs'], address['selects'])
              @contact_info_card.click_save_address
              @contact_info_card.verify_req_field_error address
            end
            it "allows a user to cancel the new address in #{address['country']}" do
              @contact_info_card.click_cancel_address if @contact_info_card.cancel_address_button_element.visible?
              current_address = @contact_info_card.formatted_address @index
              @contact_info_card.click_edit_address @index
              @contact_info_card.click_cancel_address
              expect(@contact_info_card.formatted_address @index).to eql(current_address)
            end
            it "allows a user to delete individual address fields from an address in #{address['country']}" do
              nonreq_address_inputs = address['inputs'].reject { |input| input['req'] }
              req_address_inputs = address['inputs'] - nonreq_address_inputs
              @contact_info_card.click_edit_address @index
              @contact_info_card.clear_address_fields(address, nonreq_address_inputs, address['selects'])
              @contact_info_card.click_save_address
              @contact_info_card.verify_address(address, @index, req_address_inputs, [])
            end
            it 'prevents a user adding an address of the same type as an existing one' do
              if @current_address_types == @possible_address_types
                expect(@contact_info_card.add_address_button?).to be false
              else
                @contact_info_card.click_add_address
                @contact_info_card.address_type_select_element.when_visible WebDriverUtils.page_event_timeout
                expect(@contact_info_card.unused_address_types).to eql(@possible_address_types - @current_address_types)
              end
            end

          else
            it('cannot be tested since the test data file contains a non-US address') { fail }
          end
        end
      end

      describe 'deleting' do

        it 'prevents a user deleting addresses' do
          @contact_info_card.address_types.each do |type|
            @contact_info_card.click_edit_address @contact_info_card.address_type_index(type)
            expect(@contact_info_card.delete_address_button?).to be false
          end
        end

      end
    end
  end
end
