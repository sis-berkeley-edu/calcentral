describe 'My Finances Cal1Card', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users
      testable_users = []
      test_output_heading = ['UID', 'Has Meal Plan', 'Has Points', 'Has Non-Res Meal Plan', 'Has Debit Account', 'Has Balance',
                             'Card Lost', 'Card Found']
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      test_users.each do |user|
        if user['cal1card']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_finances_tab = false
          has_debit_account = false
          has_debit_balance = false
          card_lost = false
          card_found = false

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page
            splash_page.basic_auth uid
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            has_finances_tab = status_api_page.has_finances_tab?
            cal1card_api = ApiMyCal1CardPage.new(driver)
            cal1card_api.get_json(driver)
            if has_finances_tab
              my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new(driver)
              my_finances_page.load_page
              my_finances_page.cal_1_card_content_element.when_visible(WebDriverUtils.page_load_timeout)

              # Debit account:
              if cal1card_api.has_debit_account?
                has_debit_account = true
                testable_users.push(uid)
                if cal1card_api.debit_balance.to_i > 0
                  has_debit_balance = true
                end
                api_balance = cal1card_api.debit_balance
                my_finances_balance = my_finances_page.debit_balance.delete('$, ')
                has_manage_debit_link = my_finances_page.manage_debit_card?
                it "shows the debit account balance for UID #{uid}" do
                  expect(my_finances_balance).to eql(api_balance)
                end
                it "shows a link to manage the debit balance at Cal 1 Card for UID #{uid}" do
                  expect(has_manage_debit_link).to be true
                end
              else
                my_finances_balance = my_finances_page.debit_balance?
                has_learn_about_debit = my_finances_page.learn_about_debit_card?
                it "shows no debit account balance for UID #{uid}" do
                  expect(my_finances_balance).to be false
                end
                it "shows a link to learn about debit accounts at Cal 1 Card for UID #{uid}" do
                  expect(has_learn_about_debit).to be true
                end
              end

              # Meal plan:
              has_learn_about_meals = my_finances_page.learn_about_meal_plan?
              has_view_meal_plan = my_finances_page.view_meal_plan?
              it "shows links to learn about and view meal plan at Cal 1 Card for UID #{uid}" do
                expect(has_learn_about_meals).to be true
                expect(has_view_meal_plan).to be true
              end

              # Card lost & found
              if cal1card_api.card_lost?
                card_lost = true
                my_finances_card_lost = my_finances_page.card_lost_msg?
                it "shows a 'card lost' message for UID #{uid}" do
                  expect(my_finances_card_lost).to be true
                end
              elsif cal1card_api.card_found?
                card_found = true
                my_finances_card_found = my_finances_page.card_found_msg?
                it "shows a 'card found' message for UID #{uid}" do
                  expect(my_finances_card_found).to be true
                end
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          ensure
            test_output_row = [uid, has_debit_account, has_debit_balance, card_lost, card_found]
            UserUtils.add_csv_row(test_output, test_output_row)
          end
        end
      end
      it 'has Cal 1 Card info for at least one of the test UIDs' do
        expect(testable_users.length).to be > 0
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
