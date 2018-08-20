module CalCentralPages

  module MyFinancesPages

    include PageObject
    include CalCentralPages
    include ClassLogger

    wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
    h1(:page_heading, :xpath => '//h1[text()="My Finances"]')

    # BILLING SUMMARY CARD - CARS
    h2(:billing_summary_heading, :xpath => '//h2[contains(text(),"Billing Summary")]')
    link(:details_link, :text => 'Details')
    div(:billing_summary_spinner, :xpath => '//h2[contains(.,"Billing Summary")]/../following-sibling::div[@class="cc-spinner"]')
    paragraph(:no_cars_data_msg, :class => 'cc-page-myfinances-account-summary-error')
    unordered_list(:billing_summary_list, :xpath => '//ul[@data-ng-show="myfinances.summary"]')
    div(:dpp_bal, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppBalance"]')
    div(:dpp_norm_install, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppNormalInstallmentAmount"]')
    div(:dpp_text, :xpath => '//div[contains(text(),"1: Reflected in charges with DPP")]')
    label(:amt_due_now_label, :xpath => '//strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]/../../preceding-sibling::div/strong')
    div(:min_amt_due, :xpath => '//div[@class="cc-page-myfinances-amount"]/strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]')
    span(:past_due, :xpath => '//span[@data-cc-amount-directive="myfinances.summary.totalPastDueAmount"]')
    div(:chg_not_due, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.futureActivity"]')
    div(:account_bal, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.accountBalance"]')
    link(:toggle_last_statement_bal, :xpath => '//div[@data-ng-click="api.widget.toggleShow($event, null, myfinances, \'My Finances - Summary\')"]')
    div(:last_statement_bal, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.lastStatementBalance"]')
    link(:view_statements_link, :xpath => '//a[contains(text(),"View Statements")]')
    link(:make_payment_link, :xpath => '//a[@href="http://studentbilling.berkeley.edu/carsPaymentOptions.htm"]')

    # BILLING SUMMARY CARD - CS
    label(:amt_due_now_label_cs, :xpath => '//strong[@data-cc-amount-directive="billing.data.summary.amountDueNowString"]/../../preceding-sibling::div/strong')
    div(:min_amt_due_cs, :xpath => '//strong[@data-cc-amount-directive="billing.data.summary.amountDueNowString"]')
    div(:chg_not_due_cs, :xpath => '//div[@data-cc-amount-directive="billing.data.summary.chargesNotYetDueString"]')
    div(:account_bal_cs, :xpath => '//div[@data-cc-amount-directive="billing.data.summary.accountBalanceString"]')
    link(:make_payment_link_cs, :xpath => '//a[contains(@href,"/higher_one")]')
    # TODO - past due?
    link(:view_prior_link, :xpath => '//a[contains(.,"View transactions prior to")]')
    div(:no_cs_data_msg, :xpath => '//div[contains(.," There was a problem reaching campus services. Please try again later.")]')

    # BILLING ACTIVITY - for both CARS and CS
    select_list(:activity_filter_select, :id => 'cc-page-myfinances-account-choices')
    select_list(:activity_filter_term_select, :id => 'cc-page-myfinances-select-term')
    text_area(:search_string_input, :xpath => '//input[@data-ng-model="search.$"]')
    text_area(:search_start_date_input, :id => 'cc-page-myfinances-date-start')
    text_area(:search_end_date_input, :id => 'cc-page-myfinances-date-end')
    paragraph(:search_start_date_format_error, :xpath => '//p[contains(.,"Please use mm/dd/yyyy date format for the start date.")]')
    paragraph(:search_end_date_format_error, :xpath => '//p[contains(.,"Please use mm/dd/yyyy date format for the end date.")]')

    table(:transaction_table, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table cc-table-finances"]/table')
    link(:transaction_table_row_one, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table cc-table-finances"]/table/tbody')
    paragraph(:zero_balance_text, :xpath => '//p[contains(text(),"You do not owe anything at this time. Please select a different filter to view activity details.")]')
    paragraph(:credit_balance_text, :xpath => '//p[contains(text(),"You have an over-payment on your account. You do not owe anything at this time. Please select a different filter to view activity details.")]')
    button(:show_more_button, :class => 'cc-widget-show-more')

    # FINANCIAL AID SUMMARY CARD
    div(:finaid_content, :xpath => '//div[@data-ng-if="!finaidSummaryInfo.errored"]')
    div(:finaid_summary_info, :xpath => '//div[@data-onload="netCostInfo.card = \'summary\'"]')
    div(:finaid_summary_label, :class => 'cc-widget-finaid-summary-label')
    div(:no_finaid_message, :xpath => '//div[contains(.,"You do not currently have any Financial Aid information ready to view.")]')

    span(:finaid_single_year, :xpath => '//span[@data-ng-bind="selected.finaidYear.name"]')
    select_list(:finaid_multi_year_select, :id => 'cc-widget-finaid-summary-select-year')
    span(:finaid_semesters, :xpath => '//span[@data-ng-bind="selected.finaidYear.availableSemesters | andFilter"]')

    div(:net_cost_section, :class => 'cc-widget-finaid-summary-netcost-summary')
    div(:finaid_cost_of_attend, :xpath => '//div[@data-ng-if="financialAidSummary.totalNetCost"]//span[text()="Estimated Cost of Attendance"]/../following-sibling::div')
    div(:finaid_gift_aid, :xpath => '//div[@data-ng-if="financialAidSummary.totalNetCost"]//span[text()="Gift Aid"]/../following-sibling::div')
    div(:finaid_net_cost, :xpath => '//div[@data-ng-if="financialAidSummary.totalNetCost"]//span[text()="Net Cost"]/../following-sibling::div')

    div(:finaid_funding_offered_ttl, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Funding Offered"]/../following-sibling::div')
    div(:finaid_funding_gift_aid, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Gift Aid"]/../following-sibling::div')
    div(:finaid_funding_grants, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Grants and Scholarships"]/../following-sibling::div')
    div(:finaid_funding_waivers, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Fee Waivers"]/../following-sibling::div')
    div(:finaid_funding_other, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Other Funding"]/../following-sibling::div')
    div(:finaid_funding_loans, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Loans"]/../following-sibling::div')
    div(:finaid_funding_work_study, :xpath => '//div[@class="cc-widget-finaid-summary-funding-offered ng-scope"]//span[text()="Work Study"]/../following-sibling::div')

    link(:finaid_t_and_c_link, :text => 'Complete Terms and Conditions')
    link(:finaid_title_iv_link, :text => 'Complete Title IV')
    link(:finaid_details_link, :xpath => '//h2[contains(.,"Financial Aid and Scholarships")]/following-sibling::a')
    link(:awards_link, :xpath => '//div[@data-ng-controller="FinaidSummaryController"]//a[contains(.,"View Awards")]')
    link(:shopping_sheet_link, :xpath => '//a[contains(.,"Shopping Sheet")]')

    link(:learn_more_link, :xpath => '//a[contains(.,"Learn more about Financial Aid")]')
    link(:faso_link, :xpath => '//div[@data-ng-controller="FinaidSummaryController"]//a[contains(.,"Financial Aid & Scholarships")]')
    link(:csu_link, :xpath => '//div[@data-ng-controller="FinaidSummaryController"]//a[contains(.,"Cal Student Central")]')

    def strip_currency(currency_amount)
      currency_amount.delete('$, ')
    end

    # ACCOUNT SUMMARY - CARS

    def account_balance
      strip_currency account_bal
    end

    def last_statement_balance
      strip_currency last_statement_bal
    end

    def amt_due_now
      strip_currency min_amt_due
    end

    def past_due_amt
      strip_currency past_due
    end

    def charges_not_due
      strip_currency chg_not_due
    end

    def dpp_balance
      strip_currency dpp_bal
    end

    def dpp_normal_install
      strip_currency dpp_norm_install
    end

    def show_last_statement_bal
      unless last_statement_bal_element.visible?
        toggle_last_statement_bal
        last_statement_bal_element.when_visible WebDriverUtils.page_event_timeout
      end
    end

    def hide_last_statement_bal
      if last_statement_bal_element.visible?
        toggle_last_statement_bal
        last_statement_bal_element.when_not_visible WebDriverUtils.page_event_timeout
      end
    end

    def click_billing_details_link
      details_link
      activity_heading_element.when_visible WebDriverUtils.page_load_timeout
    end

    # ACCOUNT SUMMARY - CS

    def amt_due_now_cs
      strip_currency min_amt_due_cs
    end

    def charges_not_due_cs
      strip_currency chg_not_due_cs
    end

    def account_balance_cs
      strip_currency account_bal_cs
    end

    # TRANSACTION FILTERING

    def search(activity, term, start_date, end_date, string)
      activity_filter_select_element.when_visible WebDriverUtils.page_load_timeout
      self.activity_filter_select = activity
      self.activity_filter_term_select = term unless term.nil?
      if activity == 'Date Range'
        WebDriverUtils.wait_for_element_and_type(search_start_date_input_element, start_date)
        WebDriverUtils.wait_for_element_and_type(search_end_date_input_element, end_date)
      end
      WebDriverUtils.wait_for_element_and_type(search_string_input_element, string)
    end

    # TRANSACTION DATA

    def visible_transaction_count
      transaction_table_element.exists? ? (transaction_table_element.rows - 1) : 0
    end

    def visible_transaction_dates
      dates = []
      transaction_table_element.each { |row| dates << row[0].text }
      dates_minus_heading = dates.drop 1
      dates_minus_heading.map { |date| Date.strptime(date, '%m/%d/%y') }
    end

    def visible_transaction_descrips
      descriptions = []
      transaction_table_element.each { |row| descriptions << row[1].text }
      descriptions.drop 1
    end

    def visible_transaction_amts_str
      amounts = []
      transaction_table_element.each { |row| amounts << row[2].text.delete('$, ') }
      amounts.drop 1
    end

    def visible_transaction_amts
      visible_transaction_amts_str.collect { |s| s.to_f }
    end

    def visible_transaction_types
      trans_types = []
      transaction_table_element.each { |row| trans_types << row[3].text }
      trans_types.drop 1
    end

    def show_all
      show_more_button while show_more_button_element.visible?
    end

    def toggle_first_trans_detail
      transaction_table_row_one
    end

    # FINANCIAL AID - CS CARD

    def click_fin_aid_details_link
      logger.debug 'Clicking link to FinAid Details'
      details_link
      activity_heading_element.when_visible WebDriverUtils.page_load_timeout
    end

    def select_fin_aid_year(available_years, desired_year)
      logger.debug "Viewing FinAid for #{desired_year}"
      finaid_summary_label_element.when_visible WebDriverUtils.page_load_timeout
      WebDriverUtils.wait_for_element_and_select(finaid_multi_year_select_element, desired_year) unless available_years.length == 1
      wait_until(WebDriverUtils.page_event_timeout) { finaid_details_link_element.attribute('href').include? desired_year }
    end

    def click_t_and_c_link(finaid_page)
      logger.info 'Clicking T&C link'
      WebDriverUtils.wait_for_element_and_click finaid_t_and_c_link_element
      finaid_page.t_and_c_heading_element.when_visible WebDriverUtils.page_load_timeout
    end

    def click_title_iv_link(finaid_page)
      logger.info 'Clicking Title IV link'
      WebDriverUtils.wait_for_element_and_click finaid_title_iv_link_element
      finaid_page.title_iv_heading_element.when_visible WebDriverUtils.page_load_timeout
    end

  end
end
