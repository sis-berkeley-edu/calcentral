describe 'My Finances Financial Resources card', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      @splash_page = CalCentralPages::SplashPage.new @driver
      @my_finances = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new @driver
      test_user = UserUtils.load_test_users.find { |user| user['financesUi'] }

      @splash_page.load_page
      @splash_page.basic_auth test_user['uid']
      @my_finances.load_page
      @my_finances.fin_resources_list_element.when_visible WebDriverUtils.page_load_timeout
    end

    after(:all) { WebDriverUtils.quit_browser @driver }

    # Billing & Payments

    it 'includes a link to Delegate Access' do
      expect(@my_finances.delegate_access_link?).to be true
    end
    it 'includes a link to Electronic Funds Transfer / EFT' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.eft_link_element, 'About Electronic Funds Transfer')).to be true
    end
    it 'includes a link to Manage Account for EFT' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.eft_manage_acct_link_element, '')).to be true
    end
    it 'includes a link to Payment Options' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.payment_options_link_element, 'Payment Options')).to be true
    end
    it 'includes a link to Tuition and Fees' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.tuition_and_fees_link_element, 'Fee Schedule | Office of the Registrar')).to be true
    end
    it 'includes a link to Tuition and Fees Payment Plan' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.fpp_link_element, 'Fee Payment Plan')).to be true
    end
    it 'includes a link to Activate Plan for FPP' do
      expect(@my_finances.fpp_activate_link?).to be true
    end
    it 'includes a link to Tax 1098-T Form' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.tax_1098t_form_link_element, 'Taxpayer Relief Act of 1997')).to be true
    end
    it 'includes a link to View Form for Tax 1098-T' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.tax_1098t_view_form_link_element, 'ACS :: 1098T')).to be true
    end
    it 'includes a link to Billing FAQ' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.billing_faq_link_element, 'FAQs | Cal Student Central')).to be true
    end

    # Financial Assistance

    it 'includes a link to FAFSA' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.fafsa_link_element, 'Home - FAFSA on the Web - Federal Student Aid')).to be true
    end
    it 'includes a link to Dream Act Application' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.dream_act_link_element, 'Home - CA Dream Act Application')).to be true
    end
    it 'includes a link to Financial Aid & Scholarships Office' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.fin_aid_scholarships_link_element, 'Financial Aid and Scholarships | UC Berkeley')).to be true
    end
    it 'includes a link to MyFinAid (aid prior to Fall 2016)' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.my_fin_aid_link_element, 'CalNet Central Authentication Service - Single Sign-on')).to be true
    end
    it 'includes a link to Cost of Attendance' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.cost_of_attend_link_element, 'Cost of Attendance | Financial Aid and Scholarships | UC Berkeley')).to be true
    end
    it 'includes a link to Graduate Financial Support' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.grad_fin_support_link_element, 'Financial Support | Berkeley Graduate Division')).to be true
    end
    it 'includes a link to Work-Study' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.work_study_link_element, 'Work-Study | Financial Aid and Scholarships | UC Berkeley')).to be true
    end
    it 'includes a link to Financial Literacy' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.fin_literacy_link_element, 'Bears for Financial Success | Financial Aid and Scholarships | UC Berkeley')).to be true
    end
    it 'includes a link to National Student Loan Database System' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.natl_student_loan_db_link_element, 'National Student Loan Data System for Students')).to be true
    end
    it 'includes a link to Loan Repayment Calculator' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.loan_replay_calc_link_element, 'StudentLoans.gov'))
    end
    it 'includes a link to Federal Student Loans' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.fed_student_loans_link_element, 'StudentLoans.gov')).to be true
    end
    it 'includes a link to Student Advocates Office' do
      expect(@my_finances.student_advocates_link?).to be true
    end
    it 'includes a link to Berkeley International Office' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.berk_intl_office_link_element, 'BIO Home | Berkeley International Office')).to be true
    end
    it 'includes a link to Apply for an Emergency Loan' do
      expect(@my_finances.emergency_loan_link?).to be true
    end

    # Leaving Cal?

    it 'includes a link to Have a loan?' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.have_loan_link_element, 'Exit Loan Counseling')).to be true
    end
    it 'includes a link to Withdrawing or Canceling?' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.withdraw_cancel_link_element, 'Withdrawing from UC Berkeley | Cal Student Central')).to be true
    end

    # Summer Programs

    it 'includes a link to Schedule & Deadlines' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.sched_and_dead_link_element, 'Schedule | Berkeley Summer Sessions')).to be true
    end
    it 'includes a link to Summer Session' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.summer_session_link_element, 'Berkeley Summer Sessions |')).to be true
    end

    # Your Questions Answered Here

    it 'includes a link to Cal Student Central' do
      expect(WebDriverUtils.verify_external_link(@driver, @my_finances.cal_student_central_link_element, 'Welcome! | Cal Student Central')).to be true
    end
  end
end
