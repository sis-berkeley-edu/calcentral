describe 'My Finances Financial Aid Profile card', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    begin
      @driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users
      testable_users = []
      test_output_heading = ['UID', 'Aid Years', 'Career', 'Grad Date', 'Enrollment', 'Residency', 'Family in College', 'Housing']
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      @api_aid_years = ApiCSAidYearsPage.new @driver
      @api_fin_aid_data = ApiCSFinAidDataPage.new @driver

      @splash_page = CalCentralPages::SplashPage.new @driver
      @finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new @driver
      @fin_aid_page = CalCentralPages::MyFinancesPages::MyFinancesFinancialAidPage.new @driver
      @title_iv_page = CalCentralPages::MyProfileTitleIVCard.new @driver

      test_users.each do |user|
        if user['finAidCs']
          uid = user['uid']
          logger.info "UID is #{uid}"

          aid_years = []
          api_academic_career = []
          api_expected_grad = nil
          api_enrollments = []
          api_residency = []
          api_family_in_college = nil
          api_housing = []

          begin
            @splash_page.load_page
            @splash_page.basic_auth uid
            @api_aid_years.get_json @driver

            unless @api_aid_years.feed.nil?
              api_aid_years = @api_aid_years.fin_aid_years
              api_aid_years.each { |year| aid_years << year['id'] }

              if api_aid_years.any?
                testable_users << uid

                api_aid_years.each do |year|

                  year_id = @api_aid_years.fin_aid_year_id year

                  @api_fin_aid_data.get_json(@driver, year_id)

                  # Don't bother executing tests if the package is not yet visible
                  unless @api_aid_years.t_and_c_approval(year).nil? || !@api_aid_years.t_and_c_approval(year)
                    @fin_aid_page.load_fin_aid_profile year_id

                    # PROFILE

                    @fin_aid_page.show_profile

                    ui_academic_career = @fin_aid_page.profile_elements_text @fin_aid_page.academic_career_elements
                    api_academic_career = @api_fin_aid_data.profile_values 'Academic Career'
                    it ("displays the right academic career(s) for UID #{uid}") { expect(ui_academic_career).to eql(api_academic_career) }

                    ui_level = @fin_aid_page.profile_elements_text @fin_aid_page.level_elements
                    api_level = @api_fin_aid_data.profile_sub_values 'Level'
                    it ("displays the right level for each semester for UID #{uid}") { expect(ui_level).to eql(api_level) }

                    @fin_aid_page.expected_graduation_element.exists? ?
                        ui_expected_grad = @fin_aid_page.expected_graduation :
                        ui_expected_grad = nil
                    api_expected_grad = @api_fin_aid_data.profile_value 'Expected Graduation'
                    it ("displays expected graduation date for UID #{uid}") { expect(ui_expected_grad).to eql(api_expected_grad) }

                    ui_sap_status = @fin_aid_page.sap_status
                    api_sap_status = @api_fin_aid_data.profile_value 'SAP Status'
                    it ("displays the SAP status for UID #{uid}") { expect(ui_sap_status).to eql(api_sap_status) }

                    ui_award_status = @fin_aid_page.award_status
                    api_award_status = @api_fin_aid_data.profile_value 'Award Status'
                    it ("displays the awards (packaging) status for UID #{uid}") { expect(ui_award_status).to eql(api_award_status) }

                    ui_verification_status = @fin_aid_page.verification_status
                    api_verification_status = @api_fin_aid_data.profile_value 'Verification Status'
                    it ("displays the verification status for UID #{uid}") { expect(ui_verification_status).to eql(api_verification_status) }

                    ui_dependency_status = @fin_aid_page.dependency_status
                    api_dependency_status = @api_fin_aid_data.profile_value 'Dependency Status'
                    it ("displays the dependency status for UID #{uid}") { expect(ui_dependency_status).to eql(api_dependency_status) }

                    ui_efc = @fin_aid_page.efc
                    api_efc = @api_fin_aid_data.profile_value 'Expected Family Contribution (EFC)'
                    it ("displays the expected family contribution for UID #{uid}") { expect(ui_efc).to eql(api_efc) }

                    ui_berkeley_parent_contrib = @fin_aid_page.berkeley_parent_contrib
                    api_berkeley_parent_contrib = @api_fin_aid_data.profile_value 'Berkeley Parent Contribution'
                    it ("displays the Berkeley Parent Contribution for UID #{uid}") { expect(ui_berkeley_parent_contrib).to eql(api_berkeley_parent_contrib) }

                    ui_family_in_college = @fin_aid_page.family_members_in_college
                    api_family_in_college = @api_fin_aid_data.profile_value 'Family Members in College'
                    it ("displays the number of family members in college for UID #{uid}") { expect(ui_family_in_college).to eql(api_family_in_college) }

                    ui_residency = @fin_aid_page.profile_elements_text @fin_aid_page.residency_elements
                    api_residency = @api_fin_aid_data.profile_sub_values 'Residency'
                    it ("displays the right residency associated with each semester for UID #{uid}") { expect(ui_residency).to eql(api_residency) }

                    ui_enrollments = @fin_aid_page.profile_elements_text @fin_aid_page.enrollment_elements
                    api_enrollments = @api_fin_aid_data.profile_sub_values 'Enrollment'
                    it ("displays the right semester(s) and enrolled units for UID #{uid}") { expect(ui_enrollments).to eql(api_enrollments) }

                    ui_ship_health = @fin_aid_page.profile_elements_text @fin_aid_page.ship_health_insurance_elements
                    api_ship_health = @api_fin_aid_data.profile_sub_values 'SHIP Health Insurance'
                    it ("displays SHIP health insurance for UID #{uid}") { expect(ui_ship_health).to eql(api_ship_health) }

                    ui_housing = @fin_aid_page.profile_elements_text @fin_aid_page.housing_elements
                    api_housing = @api_fin_aid_data.profile_sub_values 'Housing'
                    it ("displays the right housing associated with each semester for UID #{uid}") { expect(ui_housing).to eql(api_housing) }

                    has_update_family_link = @fin_aid_page.family_members_update_link?
                    it ("offers no family members in college 'update' link for UID #{uid}") { expect(has_update_family_link).to be false }

                    has_update_housing_link = @fin_aid_page.housing_update_link?
                    it ("offers housing 'update' link for UID #{uid}") { expect(has_update_housing_link).to be true }

                    # T and C

                    @fin_aid_page.show_t_and_c
                    @api_aid_years.title_iv_approval ? api_title_iv = 'Authorized' : api_title_iv = 'Not Authorized'

                    ui_t_and_c = @fin_aid_page.t_and_c
                    it ("displays the T&C response for UID #{uid}") { expect(ui_t_and_c).to eql('Accepted') }

                    ui_title_iv = @fin_aid_page.title_iv
                    it ("displays Title IV response for UID #{uid}") { expect(ui_title_iv).to eql(api_title_iv) }

                    @fin_aid_page.click_title_iv_update
                    @title_iv_page.authorize_cbx_element.when_visible WebDriverUtils.page_load_timeout

                    if @api_aid_years.title_iv_approval

                      @title_iv_page.revoke_title_iv
                      shows_not_auth_short_msg = @title_iv_page.non_authorized_msg.include? 'I have not authorized the University to apply my Title IV awards'
                      it ("allows UID #{uid} to change the Title IV response from authorized to not authorized") { expect(shows_not_auth_short_msg).to be true }

                      @title_iv_page.show_more
                      shows_not_auth_long_msg = @title_iv_page.non_authorized_msg_long.include? 'If you would like to authorize the use of your Title IV awards to pay all outstanding charges, please check the box below.'
                      it ("shows UID #{uid} instructions for changing the Title IV response from not authorized to authorized") { expect(shows_not_auth_long_msg).to be true }

                      @fin_aid_page.load_fin_aid_profile year_id
                      @fin_aid_page.show_t_and_c
                      updated_title_iv = @fin_aid_page.title_iv
                      it ("updates the Title IV authorization on the FinAid Profile for UID #{uid}") { expect(updated_title_iv).to eql('Not Authorized') }

                    else

                      @title_iv_page.authorize_title_iv
                      shows_auth_short_msg = @title_iv_page.authorized_msg.include? 'I have authorized the University to apply my Title IV awards'
                      it ("allows UID #{uid} to change the Title IV response from not authorized to authorized") { expect(shows_auth_short_msg).to be true }

                      @title_iv_page.show_more
                      shows_auth_long_msg = @title_iv_page.authorized_msg_long.include? 'If you would like to revoke this authorization, please uncheck the box below.'
                      it ("shows UID #{uid} instructions for changing the Title IV response from authorized to not authorized") { expect(shows_auth_long_msg).to be true }

                      @fin_aid_page.load_fin_aid_profile year_id
                      @fin_aid_page.show_t_and_c
                      updated_title_iv = @fin_aid_page.title_iv
                      it ("updates the Title IV authorization on the FinAid Profile for UID #{uid}") { expect(updated_title_iv).to eql('Authorized') }

                    end
                  end
                end
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")

            # Force a test failure in the event of an error controlling the UI
            it ("caused an unexpected error in the test for UID #{uid}") { fail }

          ensure
            test_output_row = [uid, aid_years * ', ', api_academic_career * ', ', api_expected_grad, api_enrollments * ', ',
                               api_residency * ', ', api_family_in_college, api_housing * ', ']
            UserUtils.add_csv_row(test_output, test_output_row)
          end
        end
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(@driver)
      it ('has FinAid data for at least one of the test users') { expect(testable_users.any?).to be true }
    end
  end
end
