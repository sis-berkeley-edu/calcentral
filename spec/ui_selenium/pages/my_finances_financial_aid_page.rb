module CalCentralPages

  module MyFinancesPages

    class MyFinancesFinancialAidPage

      include PageObject
      include CalCentralPages
      include MyFinancesPages
      include ClassLogger

      # T & C / TITLE IV

      h3(:t_and_c_heading, :xpath => '//h3[text()="Terms and Conditions"]')
      div(:t_and_c_body, :xpath => '//h3[text()="Terms and Conditions"]/following-sibling::div')
      button(:decline_t_and_c, :xpath => '//button[text()="I Do Not Agree"]')
      button(:accept_t_and_c, :xpath => '//button[text()="I Do Agree"]')
      h2(:declined_t_and_c_heading, :xpath => '//h2[text()="Declined Terms and Conditions"]')
      div(:declined_t_and_c_msg, :xpath => '//div[contains(text(),"You have not agreed to the Terms and Conditions. You are not eligible to view your financial aid via CalCentral.")]')
      link(:back_to_finances, :text => 'Go Back to My Finances')
      h2(:title_iv_heading, :xpath => '//h2[text()="Title IV Authorization"]')
      button(:decline_title_iv, :xpath => '//button[text()="I Do Not Authorize"]')
      button(:authorize_title_iv, :xpath => '//button[text()="Authorize"]')

      def accept_t_and_c
        logger.debug 'Clicking button to accept T & C'
        WebDriverUtils.wait_for_element_and_click accept_t_and_c_element
      end

      def decline_t_and_c
        logger.debug 'Clicking button to decline T & C'
        WebDriverUtils.wait_for_element_and_click decline_t_and_c_element
        declined_t_and_c_heading_element.when_visible WebDriverUtils.page_load_timeout
      end

      def authorize_title_iv
        logger.debug 'Clicking button to authorize Title IV'
        WebDriverUtils.wait_for_element_and_click authorize_title_iv_element
      end

      def go_back_to_finances
        logger.debug 'Clicking Back to Finances button'
        WebDriverUtils.wait_for_element_and_click back_to_finances_element
        finaid_content_element.when_visible WebDriverUtils.page_load_timeout
      end

      # AWARDS CARD
      div(:coa_ttl, :xpath => '//span[text()="Estimated Cost of Attendance"]/../following-sibling::div')
      div(:gift_aid_ttl, :xpath => '//span[text()="Gift Aid"]/../following-sibling::div')
      div(:net_cost_ttl, :xpath => '//span[text()="Net Cost"]/../following-sibling::div')

      elements(:gift_aid, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li')
      elements(:gift_aid_title, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//div[@data-ng-bind="item.title"]')
      elements(:gift_aid_source, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//div[@data-ng-bind="item.subtitle"]')
      elements(:gift_aid_status, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//div[@data-ng-bind="item.leftColumn.value"]')
      elements(:gift_aid_ttl_amount, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.leftColumn.amount"]')
      elements(:gift_aid_used_status, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//span[@data-ng-bind="item.rightColumn.value"]')
      elements(:gift_aid_used_amount, :div, :xpath => '//h3[text()="Gift Aid"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.rightColumn.amount"]')

      elements(:subsidized_loan, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li')
      elements(:subsidized_title, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.title"]')
      elements(:subsidized_source, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.subtitle"]')
      elements(:subsidized_status, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.leftColumn.value"]')
      elements(:subsidized_ttl_amount, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.leftColumn.amount"]')
      elements(:subsidized_used_status, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//span[@data-ng-bind="item.rightColumn.value"]')
      elements(:subsidized_used_amount, :div, :xpath => '//h3[text()="Subsidized Loans"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.rightColumn.amount"]')

      elements(:unsubsidized_loan, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li')
      elements(:unsubsidized_title, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.title"]')
      elements(:unsubsidized_source, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.subtitle"]')
      elements(:unsubsidized_status, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//div[@data-ng-bind="item.leftColumn.value"]')
      elements(:unsubsidized_ttl_amount, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.leftColumn.amount"]')
      elements(:unsubsidized_used_status, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//span[@data-ng-bind="item.rightColumn.value"]')
      elements(:unsubsidized_used_amount, :div, :xpath => '//h3[text()="Unsubsidized Loans"]/../../following-sibling::ul/li//div[@data-cc-amount-directive="item.rightColumn.amount"]')

      button(:show_t_and_c_toggle, :xpath => '//h3[text()="Terms and Conditions"]/following-sibling::button[@class="cc-button-link cc-widget-finaid-profile-button-toggle"]')

      def load_page(aid_year)
        logger.info "Loading My Finances Financial Aid details page for aid year #{aid_year}"
        navigate_to "#{WebDriverUtils.base_url}/finances/finaid/#{aid_year}"
      end

      def wait_for_fin_aid_semesters
        finaid_content_element.when_visible WebDriverUtils.page_load_timeout
      end

      def load_fin_aid_summary(aid_year)
        load_page aid_year
        wait_for_fin_aid_semesters
      end

      # BUDGET / ESTIMATED COST OF ATTENDANCE

      div(:budget_msg, :xpath => '//div[@data-ng-bind="coa.message"]')
      button(:toggle_budget_view, :xpath => '//h2[text()="Estimated Cost of Attendance"]/../following-sibling::div//button[@data-ng-click="toggleView()"]')
      table(:standard_budget_table, :xpath => '//h2[text()="Estimated Cost of Attendance"]/../following-sibling::div//th[text()="Standard Budget"]/../../..')
      table(:additional_budget_table, :xpath => '//h2[text()="Estimated Cost of Attendance"]/../following-sibling::div//th[text()="Additional"]/../../..')
      elements(:standard_budget_row_toggle, :element, :xpath => '//th[text()="Standard Budget"]/../../../tbody')
      elements(:additional_budget_row_toggle, :element, :xpath => '//th[text()="Additional"]/../../../tbody')
      elements(:sub_item_title, :cell, :xpath => '//td[@data-ng-bind="subItem.title"]')
      elements(:sub_item_total, :span, :xpath => '//span[@data-cc-amount-directive="subItem.total"]')
      elements(:sub_item_amount, :cell, :xpath => '//td[@data-ng-repeat="amount in subItem.amounts track by $index"]')
      table(:grand_total_budget_table, :xpath => '//h2[text()="Estimated Cost of Attendance"]/../following-sibling::div//th[text()="Grand Total"]/../../..')

      def load_fin_aid_budget(aid_year)
        load_page aid_year
        budget_msg_element.when_visible WebDriverUtils.page_load_timeout
      end

      def budget_rows(table_element)
        rows = []
        table_element.each { |row| rows << row } if table_element.exists?
        # Remove rows that do not contain budget items
        if rows.any?
          rows = rows.drop 1
          rows.slice!(-2, 2)
        end
        rows
      end

      def budget_items(table_element)
        items = []
        budget_rows(table_element).each { |row| items << row[0].text }
        items
      end

      def budget_item_annual_totals(table_element)
        totals = []
        budget_rows(table_element).each { |row| totals << WebDriverUtils.currency_to_f(row[1].text) }
        totals
      end

      def budget_item_term_amounts(table_element)
        budget_rows(table_element).map do |row|
          row_amounts = row.map do |cell|
            # Treat currency amounts as numbers, but null values should be 'N/A'
            cell.text.include?('$') ? WebDriverUtils.currency_to_f(cell.text) : cell.text
          end
          # Remove the item label in the first column
          row_amounts = row_amounts.drop(1)
          # Remove the total value in the last column
          row_amounts.pop
          row_amounts
        end
      end

      def budget_item_term_totals(table_element)
        totals = []
        budget_rows(table_element).each do |row|
          row_amounts = []
          row.each { |cell| row_amounts << cell.text }
          totals << WebDriverUtils.currency_to_f(row_amounts.last)
        end
        totals
      end

      def expand_budget_item(toggle_elements, item_index)
        WebDriverUtils.wait_for_element_and_click toggle_elements[item_index]
      end

      def budget_subitems
        titles = []
        sub_item_title_elements.each { |title| titles << title.text }
        titles.drop 1
        titles
      end

      def budget_subitem_annual_amounts
        amounts = []
        sub_item_total_elements.each { |amount| amounts << WebDriverUtils.currency_to_f(amount.text) }
        amounts.drop 1
        amounts
      end

      def budget_subitem_term_amounts
        amounts = []
        sub_item_amount_elements.each { |amount| amounts << WebDriverUtils.currency_to_f(amount.text) }
        amounts
      end

      def budget_subitem_term_totals
        totals = []
        sub_item_total_elements.each { |total| totals << WebDriverUtils.currency_to_f(total.text) }
        totals
      end

      def budget_total(table_element)
        table_element.last_row[1].text
      end

      def coa_grand_total
        grand_total_budget_table_element[1][1].text
      end

      # PROFILE CARD

      div(:profile_msg, :class => 'cc-widget-finaid-profile-message')
      button(:show_profile_button, :xpath => '//h3[text()="Financial Aid Profile"]/following-sibling::button[contains(.,"Show")]')
      button(:hide_profile_button, :xpath => '//h3[text()="Financial Aid Profile"]/following-sibling::button[contains(.,"Hide")]')
      button(:show_t_and_c_button, :xpath => '//h3[text()="Terms and Conditions"]/following-sibling::button[contains(.,"Show")]')
      button(:hide_t_and_c_button, :xpath => '//h3[text()="Terms and Conditions"]/following-sibling::button[contains(.,"Hide")]')
      elements(:academic_career, :div, :xpath => '//strong[text()="Academic Career"]/../following-sibling::div')
      elements(:level, :div, :xpath => '//strong[text()="Level"]/../following-sibling::div/div')
      div(:expected_graduation, :xpath => '//strong[text()="Expected Graduation"]/../following-sibling::div')
      div(:sap_status, :xpath => '//strong[text()="SAP Status"]/../following-sibling::div')
      div(:academic_holds, :xpath => '//strong[text()="Academic Holds"]/../following-sibling::div')
      div(:award_status, :xpath => '//strong[text()="Award Status"]/../following-sibling::div')
      div(:verification_status, :xpath => '//strong[text()="Verification Status"]/../following-sibling::div')
      div(:dependency_status, :xpath => '//strong[text()="Dependency Status"]/../following-sibling::div')
      div(:efc, :xpath => '//strong[text()="Expected Family Contribution (EFC)"]/../following-sibling::div')
      div(:berkeley_parent_contrib, :xpath => '//strong[text()="Berkeley Parent Contribution"]/../following-sibling::div')
      div(:family_members_in_college, :xpath => '//strong[text()="Family Members in College"]/../following-sibling::div')
      link(:family_members_update_link, :xpath => '//strong[text()="Family Members in College"]/following-sibling::a')
      elements(:residency, :div, :xpath => '//strong[text()="Residency"]/../following-sibling::div/div')
      elements(:enrollment, :div, :xpath => '//strong[text()="Enrollment"]/../following-sibling::div/div')
      elements(:housing, :div, :xpath => '//strong[text()="Housing"]/../following-sibling::div/div')
      link(:housing_update_link, :xpath => '//strong[text()="Housing"]/following-sibling::a')
      elements(:ship_health_insurance, :div, :xpath => '//strong[text()="SHIP Health Insurance"]/../following-sibling::div/div')

      div(:title_iv, :xpath => '//strong[text()="Title IV"]/../following-sibling::div')
      link(:title_iv_update_link, :xpath => '//strong[text()="Title IV"]/following-sibling::a')
      div(:t_and_c, :xpath => '//strong[text()="Terms & Conditions"]/../following-sibling::div')

      def load_fin_aid_profile(aid_year)
        load_page aid_year
        profile_msg_element.when_visible WebDriverUtils.page_load_timeout
      end

      def show_profile
        WebDriverUtils.wait_for_element_and_click show_profile_button_element unless hide_profile_button?
      end

      def hide_profile
        WebDriverUtils.wait_for_element_and_click hide_profile_button_element unless show_profile_button?
      end

      def profile_elements_text(elements)
        texts = []
        elements.each { |element| texts << element.text.gsub(/[^a-zA-Z0-9]/, ' ').gsub(/\s+/, ' ') }
        texts
      end

      def show_t_and_c
        WebDriverUtils.wait_for_element_and_click show_t_and_c_button_element unless hide_t_and_c_button?
      end

      def hide_t_and_c
        WebDriverUtils.wait_for_element_and_click hide_t_and_c_button_element unless show_t_and_c_button?
      end

      def click_title_iv_update
        WebDriverUtils.wait_for_element_and_click title_iv_update_link_element
      end

    end
  end
end
