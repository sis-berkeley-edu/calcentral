module CalCentralPages

  module MyFinancesPages

    class MyFinancesLandingPage

      include PageObject
      include CalCentralPages
      include MyFinancesPages
      include ClassLogger

      wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
      h1(:page_heading, :xpath => '//h1[text()="My Finances"]')

      # FINANCIAL RESOURCES CARD
      h2(:fin_resources_heading, :xpath => '//h2[text()="Financial Resources"]')
      div(:fin_resources_spinner, :xpath => '//h2[text()="Financial Resources"]/../following-sibling::div[@class="cc-spinner"]')
      unordered_list(:fin_resources_list, :xpath => '//ul[@class="cc-list-links"]')
      link(:delegate_access_link, :xpath => '//a[contains(@href,"/profile/delegate")]')
      link(:eft_link, :xpath => '//a[contains(text(),"Electronic Funds Transfer / EFT")]')
      link(:eft_manage_acct_link, :xpath => '//a[@title="Manage your electronic fund transfer accounts"]')
      link(:payment_options_link, :xpath => '//a[contains(text(),"Payment Options")]')
      link(:tuition_and_fees_link, :xpath => '//a[@title="Estimated fee schedule"]')
      link(:fpp_link, :xpath => '//a[contains(text(),"Tuition and Fees Payment Plan")]')
      link(:fpp_activate_link, :xpath => '//a[@title="Activate your tuition and fees payment plan"]')
      link(:tax_1098t_form_link, :xpath => '//a[contains(text(),"Tax 1098-T Form")]')
      link(:tax_1098t_view_form_link, :xpath => '//a[@title="Start here to access your 1098-T form"]')
      link(:billing_faq_link, :xpath => '//a[contains(text(),"Billing FAQ")]')
      link(:fafsa_link, :xpath => '//a[contains(text(),"FAFSA")]')
      link(:dream_act_link, :xpath => '//a[contains(text(),"Dream Act Application")]')
      link(:fin_aid_scholarships_link, :xpath => '//a[contains(text(),"Financial Aid & Scholarships Office")]')
      link(:my_fin_aid_link, :xpath => '//div[@data-ng-controller="FinancesLinksController"]//a[contains(text(),"MyFinAid (aid prior to Fall 2016)")]')
      link(:cost_of_attend_link, :xpath => '//a[contains(text(),"Cost of Attendance")]')
      link(:grad_fin_support_link, :xpath => '//a[contains(text(),"Graduate Financial Support")]')
      link(:work_study_link, :xpath => '//a[contains(text(),"Work-Study")]')
      link(:fin_literacy_link, :xpath => '//a[contains(text(),"Financial Literacy")]')
      link(:natl_student_loan_db_link, :xpath => '//a[contains(text(),"National Student Loan Database System")]')
      link(:loan_replay_calc_link, :xpath => '//a[contains(text(),"Loan Repayment Calculator")]')
      link(:fed_student_loans_link, :xpath => '//a[contains(text(),"Federal Student Loans")]')
      link(:student_advocates_link, :xpath => '//a[contains(text(),"Student Advocates Office")]')
      link(:berk_intl_office_link, :xpath => '//a[contains(text(),"Berkeley International Office")]')
      link(:emergency_loan_link, :xpath => '//a[contains(text(),"Apply for an Emergency Loan")]')
      link(:have_loan_link, :xpath => '//a[contains(text(),"Have a loan?")]')
      link(:withdraw_cancel_link, :xpath => '//a[contains(text(),"Withdrawing or Canceling?")]')
      link(:sched_and_dead_link, :xpath => '//a[contains(text(),"Schedule & Deadlines")]')
      link(:summer_session_link, :xpath => '//a[contains(text(),"Summer Session")]')
      link(:cal_student_central_link, :xpath => '//div[@data-ng-controller="FinancesLinksController"]//a[contains(text(),"Cal Student Central")]')

      def load_page
        logger.info('Loading My Finances landing page')
        navigate_to "#{WebDriverUtils.base_url}/finances"
      end

      def load_fin_aid_summary(aid_year = nil)
        load_page
        finaid_content_element.when_visible WebDriverUtils.page_load_timeout
      end

    end
  end
end
