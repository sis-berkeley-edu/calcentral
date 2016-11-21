module CalCentralPages

  module MyFinancesPages

    class MyFinancesBillingPage

      include PageObject
      include ClassLogger
      include CalCentralPages
      include MyFinancesPages

      div(:spinner, :xpath => '//div[@data-cc-spinner-directive="billing.isLoading"][@aria-live="polite"][@aria-busy="false"]')
      div(:error_msg, :xpath => '//div[contains(.,"There was a problem reaching campus services.  Please try again later.")]')

      link(:sort_by_date, :xpath => '//th[@data-ng-click="changeSorting(\'itemEffectiveDate\')"]')
      link(:sort_by_descrip, :xpath => '//th[@data-ng-click="changeSorting(\'itemDescription\')"]')
      link(:sort_by_amount, :xpath => '//th[@data-ng-click="changeSortingAmount()"]')
      link(:sort_by_trans_type, :xpath => '//th[@data-ng-click="changeSorting(\'itemType\')"]')
      link(:sort_by_due_date, :xpath => '//th[@data-ng-click="changeSorting(\'itemDueDate\')"]')
      image(:sort_descending, :xpath => '//i[@class="fa fa-chevron-down"]')
      image(:sort_ascending, :xpath => '//i[@class="fa fa-chevron-up"]')

      elements(:due_date, :span, :xpath => '//span[@data-ng-if="item.itemDueFlag"]')

      # The following are elements from the first transaction in the UI
      span(:item_date, :xpath => '//span[contains(@data-ng-bind,"item.itemEffectiveDate")]')
      div(:item_desc, :xpath => '//div[@data-ng-bind="item.itemDescription"]')
      td(:item_balance, :xpath => '//td[@data-cc-amount-directive="item.item.itemBalanceString"]')
      td(:item_amt, :xpath => '//td[@data-cc-amount-directive="item.itemLineAmountString"]')
      span(:item_type, :xpath => '//span[@data-ng-bind="item.itemType"]')
      span(:item_due_date, :xpath => '//span[contains(@data-ng-bind,"item.itemDueDate")]')

      image(:item_due_future_icon, :xpath => '//td[contains(@class,"cc-page-myfinances-due-date")]//i[contains(@class,"fa-arrow-right")]')
      image(:item_due_now_icon, :xpath => '//td[contains(@class,"cc-page-myfinances-due-date")]//i[contains(@class,"fa-exclamation")]')
      image(:item_due_past_icon, :xpath => '//td[contains(@class,"cc-page-myfinances-due-date")]//i[contains(@class,"fa-exclamation-circle")]')

      span(:item_detail_status, :xpath => '//span[contains(@data-ng-bind,"item.itemStatus")]')
      span(:item_detail_orig_amt, :xpath => '//span[@data-cc-amount-directive="item.itemLineAmountString"]')
      span(:item_detail_term, :xpath => '//span[contains(@data-ng-bind,"item.itemTermDescription")]')
      span(:item_detail_type, :xpath => '//tr[@data-ng-if="item.show"]//span[@data-ng-bind="item.itemType"]')

      paragraph(:zero_balance_text, :xpath => '//p[contains(text(),"You do not owe anything at this time. Please select a different filter to view activity details.")]')
      paragraph(:credit_balance_text, :xpath => '//p[contains(text(),"You have an over-payment on your account. You do not owe anything at this time. Please select a different filter to view activity details.")]')

      button(:show_more_button, :class => 'cc-widget-show-more')

      def load_page
        logger.info 'Loading My Finances Billing page'
        navigate_to "#{WebDriverUtils.base_url}/billing/details"
        spinner_element.when_not_present(WebDriverUtils.page_load_timeout) if spinner?
      end

      def load_summary
        tries ||= 5
        load_page
        min_amt_due_cs_element.when_visible
      rescue
        retry unless (tries -= 1).zero?
      end

      def visible_due_dates
        due_date_elements.map { |date| Date.strptime(date.text, '%m/%d/%y') }
      end

      def visible_transactions_sum_str
        visible_transaction_amts_str.inject(BigDecimal.new('0')) { |acc, amt| acc + BigDecimal.new(amt) }
      end

      # TRANSACTION SORTING

      def sort_by_date_asc
        logger.info 'Sorting by date ascending'
        sort_by_date
        sort_by_date if sort_descending?
      end

      def sort_by_date_desc
        logger.info 'Sorting by date descending'
        sort_by_date
        sort_by_date if sort_ascending?
      end

      def sort_by_descrip_asc
        logger.info 'Sorting by description ascending'
        sort_by_descrip
        sort_by_descrip if sort_descending?
      end

      def sort_by_descrip_desc
        logger.info 'Sorting by description descending'
        sort_by_descrip
        sort_by_descrip if sort_ascending?
      end

      def sort_by_amount_asc
        logger.info 'Sorting by amount ascending'
        sort_by_amount
        sort_by_amount if sort_descending?
      end

      def sort_by_amount_desc
        logger.info 'Sorting by amount descending'
        sort_by_amount
        sort_by_amount if sort_ascending?
      end

      def sort_by_trans_type_asc
        logger.info 'Sorting by transaction type ascending'
        sort_by_trans_type
        sort_by_trans_type if sort_descending?
      end

      def sort_by_trans_type_desc
        logger.info 'Sorting by transaction type descending'
        sort_by_trans_type
        sort_by_trans_type if sort_ascending?
      end

      def sort_by_due_date_asc
        logger.info 'Sorting by due date ascending'
        sort_by_due_date
        sort_by_due_date if sort_descending?
      end

      def sort_by_due_date_desc
        logger.info 'Sorting by due date descending'
        sort_by_due_date
        sort_by_due_date if sort_ascending?
      end

    end
  end
end
