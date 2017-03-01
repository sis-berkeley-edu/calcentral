describe 'Profile bConnected', :testui => true do

  if ENV['UI_TEST']

    before(:each) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:each) do
      WebDriverUtils.quit_browser(@driver)
    end

    context 'as any user' do

      before(:example) do
        @splash_page = CalCentralPages::SplashPage.new @driver
        @cal_net = CalNetAuthPage.new @driver
        dashboard_page = @splash_page.log_into_dashboard(@driver, @cal_net, UserUtils.qa_username, UserUtils.qa_password)
        basic_info_card = dashboard_page.click_profile_link @driver
        @bconnected_card = basic_info_card.click_bconnected @driver
        @bconnected_card.disconnect_bconnected
        google = GooglePage.new @driver
        google.connect_calcentral_to_google(UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      end

      context 'when connected' do
        it 'shows "connected"' do
          @bconnected_card.load_page
          @bconnected_card.disconnect_button_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(@bconnected_card.connect_button?).to be false
          expect(@bconnected_card.connected_as).to include("#{UserUtils.qa_gmail_username}")
        end
      end

      context 'when disconnecting' do
        it 'keeps you connected if you\'re not sure' do
          @bconnected_card.load_page
          @bconnected_card.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          @bconnected_card.disconnect_button
          @bconnected_card.disconnect_no_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
          @bconnected_card.disconnect_no_button
          @bconnected_card.wait_until(WebDriverUtils.page_event_timeout, 'Disconnect button has not appeared') do
            @bconnected_card.disconnect_button?
          end
          expect(@bconnected_card.connect_button?).to be false
          expect(@bconnected_card.connected_as).to include("#{UserUtils.qa_gmail_username}")
        end
        it 'disconnects you if you\'re sure' do
          @bconnected_card.load_page
          @bconnected_card.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          @bconnected_card.disconnect_button
          @bconnected_card.disconnect_yes_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
          @bconnected_card.disconnect_yes_button
          @bconnected_card.wait_until(WebDriverUtils.page_event_timeout, 'Connect button has not appeared') do
            @bconnected_card.connect_button?
          end
          expect(@bconnected_card.disconnect_button?).to be false
          expect(@bconnected_card.connected_as?).to be false
        end
      end

      context 'when connected as a user without current student classes' do
        it 'shows no "class calendar" option for a non-student' do
          @bconnected_card.load_page
          @bconnected_card.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        end
      end

    end
  end
end
