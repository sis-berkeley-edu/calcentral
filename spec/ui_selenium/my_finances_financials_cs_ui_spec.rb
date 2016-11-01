describe 'My Finances Campus Solutions billing details page', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    timeout = WebDriverUtils.page_event_timeout
    test_user = UserUtils.load_test_users.find { |user| user['financesUi'] }
    logger.info "Test UID is #{test_user['uid']}"

    before(:all) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:all) do
      WebDriverUtils.quit_browser @driver
    end

    before(:context) do
      splash_page = CalCentralPages::SplashPage.new @driver
      splash_page.load_page
      splash_page.basic_auth test_user['uid']

      @api = ApiCSBillingPage.new @driver
      @api.get_json@driver

      @my_finances_billing = CalCentralPages::MyFinancesPages::MyFinancesBillingPage.new @driver
      @my_finances_billing.load_page
    end

    context 'activity card' do

      context 'transaction filters' do

        it 'allow a user to filter for open charges' do
          @my_finances_billing.search('Balance', nil, '', '', '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.transactions_with_balance.length }
        end

        it 'allow a user to filter for open charges containing a specified string' do
          if @api.open_charges.any?
            search_string = @api.description @api.open_charges.last
            charges = @api.transactions_by_desc(@api.transactions_with_balance, search_string)
            @my_finances_billing.search('Balance', nil, '', '', search_string)
            @my_finances_billing.show_all
            @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == charges.length }
          end
        end

        it 'allow a user to see all transactions' do
          @my_finances_billing.search('All Transactions', nil, '', '', '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.activity.length }
        end

        it 'allow a user to filter all transactions by a specified string' do
          search_string = @api.description @api.transactions_by_type(@api.activity, 'Charge').first
          expected_transactions = @api.transactions_by_desc(@api.activity, search_string)
          @my_finances_billing.search('All Transactions', nil, '', '', search_string)
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == expected_transactions.length }
        end

        it 'allow a user to filter all transactions by a specific term' do
          trans = @api.activity.last
          term = @api.term_desc trans
          @my_finances_billing.search('Term', term, '', '', '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.transactions_by_term(@api.activity, term).length }
        end

        it 'allow a user to filter all transactions by a specific term and a specified string' do
          trans = @api.transactions_by_type(@api.activity, 'Charge').last
          term = @api.term_desc trans
          search_string = @api.description trans
          expected_transactions = @api.transactions_by_desc(@api.activity, search_string) & @api.transactions_by_term(@api.activity, term)
          @my_finances_billing.search('Term', term, '', '', search_string)
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == expected_transactions.length }
          expect(@my_finances_billing.visible_transaction_descrips).to include(@api.description trans)
        end

        it 'allow a user to filter all transactions by a date range' do
          trans = @api.activity.last
          trans_date = @api.effective_date_as_date trans
          start_date = WebDriverUtils.ui_date_input_format trans_date
          end_date = WebDriverUtils.ui_date_input_format (trans_date + 30)
          @my_finances_billing.search('Date Range', nil, start_date, end_date, '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.transactions_by_date_range(start_date, end_date).length }
          expect(@my_finances_billing.visible_transaction_descrips).to include(@api.description trans)
        end

        it 'allow a user to filter all transactions by a start date only' do
          trans = @api.activity.first
          start_date = WebDriverUtils.ui_date_input_format @api.effective_date_as_date(trans)
          end_date = '12/31/2100'
          @my_finances_billing.search('Date Range', nil, start_date, '', '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.transactions_by_date_range(start_date, end_date).length }
          expect(@my_finances_billing.visible_transaction_descrips).to include(@api.description trans)
        end

        it 'allow a user to filter all transactions by an end date only' do
          trans = @api.activity.last
          start_date = '01/01/2000'
          end_date = WebDriverUtils.ui_date_input_format @api.effective_date_as_date(trans)
          @my_finances_billing.search('Date Range', nil, '', end_date, '')
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == @api.transactions_by_date_range(start_date, end_date).length }
        end

        it 'allow a user to filter all transactions by a date range and a specified string' do
          trans = @api.activity.first
          start_date = WebDriverUtils.ui_date_input_format @api.effective_date_as_date(trans)
          end_date = WebDriverUtils.ui_date_input_format Date.today
          search_string = @api.description trans
          expected_transactions = @api.transactions_by_desc(@api.activity, search_string) & @api.transactions_by_date_range(start_date, end_date)
          @my_finances_billing.search('Date Range', nil, start_date, end_date, search_string)
          @my_finances_billing.show_all
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count == expected_transactions.length }
          expect(@my_finances_billing.visible_transaction_descrips).to include(@api.description trans)
        end

        it 'filter transactions by balance due by default' do
          @my_finances_billing.load_page
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.activity_filter_select_element.options.any? }
          @my_finances_billing.activity_filter_select.should eql('Balance')
        end

        it 'show no results when filtered by a string that does not exist' do
          @my_finances_billing.load_page
          @my_finances_billing.search('All Transactions', nil, '', '', 'XXXXXXXXXXXXXXX')
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count.zero? }
          expect(@my_finances_billing.show_more_button?).to be false
        end

        it 'show no results when filtered by a date range that does not exist among transactions' do
          @my_finances_billing.load_page
          @my_finances_billing.search('Date Range', nil, '01/01/1900', '12/31/1900', '')
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count.zero? }
          expect(@my_finances_billing.show_more_button?).to be false
        end

        it 'show no results when filtered by an illogical date range' do
          @my_finances_billing.load_page
          @my_finances_billing.search('Date Range', nil, '01/01/1902', '01/01/1900', '')
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_count.zero? }
          expect(@my_finances_billing.show_more_button?).to be false
        end

        it 'show a validation error if a date range is in the wrong date format' do
          @my_finances_billing.search('Date Range', nil, '01/01/14', '', '')
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.search_start_date_format_error_element.visible? }
          @my_finances_billing.search('Date Range', nil, '', '01/02/14', '')
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.search_end_date_format_error_element.visible? }
        end
      end

      context 'transaction columns' do

        before(:all) do
          @my_finances_billing.load_page
          @my_finances_billing.search('Date Range', nil, WebDriverUtils.ui_date_input_format(Date.today - 180), '', '')
          @my_finances_billing.show_all
        end

        it 'can be sorted by date descending' do
          date_desc = @my_finances_billing.visible_transaction_dates.sort { |x, y| y <=> x }
          @my_finances_billing.sort_by_date_desc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_dates == date_desc }
        end

        it 'can be sorted by date ascending' do
          date_asc = @my_finances_billing.visible_transaction_dates.sort
          @my_finances_billing.sort_by_date_asc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_dates == date_asc }
        end

        it 'can be sorted by description ascending alphabetically' do
          descrip_asc = @my_finances_billing.visible_transaction_descrips.sort_by &:downcase
          @my_finances_billing.sort_by_descrip_asc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_descrips == descrip_asc }
        end

        it 'can be sorted by description descending alphabetically' do
          descrip_desc = @my_finances_billing.visible_transaction_descrips.sort { |x, y| y.downcase <=> x.downcase }
          @my_finances_billing.sort_by_descrip_desc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_descrips == descrip_desc }
        end

        it 'can be sorted by amount ascending' do
          amt_asc = @my_finances_billing.visible_transaction_amts.sort
          @my_finances_billing.sort_by_amount_asc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_amts == amt_asc }
        end

        it 'can be sorted by amount descending' do
          amt_desc = @my_finances_billing.visible_transaction_amts.sort { |x, y| y <=> x }
          @my_finances_billing.sort_by_amount_desc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_amts == amt_desc }
        end

        it 'can be sorted by transaction type ascending alphabetically' do
          type_asc = @my_finances_billing.visible_transaction_types.sort
          @my_finances_billing.sort_by_trans_type_asc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_types == type_asc }
        end

        it 'can be sorted by transaction type descending alphabetically' do
          type_desc = @my_finances_billing.visible_transaction_types.sort { |x, y| y <=> x }
          @my_finances_billing.sort_by_trans_type_desc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_transaction_types == type_desc }
        end

        it 'can be sorted by due date ascending' do
          dates_asc = @my_finances_billing.visible_due_dates.sort
          @my_finances_billing.sort_by_due_date_asc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_due_dates == dates_asc }
        end

        it 'can be sorted by due date descending' do
          dates_desc = @my_finances_billing.visible_due_dates.sort { |x, y| y <=> x }
          @my_finances_billing.sort_by_due_date_desc
          @my_finances_billing.wait_until(timeout) { @my_finances_billing.visible_due_dates == dates_desc }
        end

      end
    end
  end
end
