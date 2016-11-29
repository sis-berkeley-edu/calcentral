module CalCentralPages

  class MyAcademicsStatusAndHoldsCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    div(:status_holds_section, :class => 'cc-status-holds-section')
    elements(:reg_status, :unordered_list, :xpath => '//ul[@data-ng-if="api.user.profile.features.regstatus"]')

    # Registration

    def reg_status_summary_element(term_name, index)
      span_element(:xpath => "//h4[@data-ng-bind='registration.name'][contains(.,'#{term_name}')]/following-sibling::ul/li[#{index + 1}]//span[@data-ng-bind='registration.summary']")
    end

    def reg_status_collapsed_element(term_name, index)
      list_item_element(:xpath => "//h4[@data-ng-bind='registration.name'][contains(.,'#{term_name}')]/following-sibling::ul/li[#{index + 1}][@class='cc-widget-list-hover']")
    end

    def show_reg_status_detail(term_name, index)
      WebDriverUtils.wait_for_element_and_click reg_status_collapsed_element(term_name, index)
      reg_status_detail_element(term_name, index).when_visible WebDriverUtils.page_event_timeout
    end

    def reg_status_detail_element(term_name, index)
      span_element(:xpath => "//h4[@data-ng-bind='registration.name'][contains(.,'#{term_name}')]/following-sibling::ul/li[#{index + 1}]//div[@class='cc-status-holds-expanded-text']")
    end

    # Residency

    def res_status_summary_element(index)
      span_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//span[@data-ng-bind='residency.official.description']")
    end

    def res_status_collapsed_element(index)
      list_item_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul//li[#{index + 1}][@class='cc-widget-list-hover']")
    end

    def res_status_expanded_element(index)
      list_item_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul//li[#{index + 1}][@class='cc-widget-list-hover cc-widget-list-hover-opened']")
    end

    def res_msg_element(index)
      div_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul//li[#{index + 1}]//div[@data-ng-bind-html='residency.message.description']")
    end

    def res_from_term_element(index)
      span_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//span[@data-ng-bind='residency.fromTerm.label']")
    end

    def res_slr_link_element(index)
      link_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//a[contains(text(),'Statement of Legal Residence')]")
    end

    def res_status_icon_green_element(index)
      image_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//i[@class='cc-icon fa fa-check-circle cc-icon-green ng-scope']")
    end

    def res_status_icon_gold_element(index)
      image_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//i[@class='cc-icon fa fa-warning cc-icon-gold ng-scope']")
    end

    def res_status_icon_red_element(index)
      image_element(:xpath => "//h4[text()='California Residency']/following-sibling::ul/li[#{index + 1}]//i[@class='cc-icon fa fa-exclamation-circle cc-icon-red ng-scope']")
    end

    def show_res_status_detail(index)
      WebDriverUtils.wait_for_element_and_click res_status_collapsed_element index
      res_status_expanded_element(index).when_visible WebDriverUtils.page_event_timeout
    end

    # Holds (service indicators)

    h3(:active_holds_heading, :xpath => '//h3[text()="Active Holds"]')
    table(:active_holds_table, :xpath => '//div[@data-ng-if="holds.length"]/table')
    elements(:active_holds_row, :row, :xpath => '//div[@data-ng-if="holds.length"]/table//tr')
    div(:active_hold_message, :xpath => '//div[@data-ng-if="hold.reason.formalDescription"]')
    span(:active_hold_term, :xpath => '//span[@data-ng-bind="hold.fromTerm.name"]')
    div(:no_active_holds_message, :xpath => '//div[contains(text(),"You have no active holds at this time.")]')

    def active_hold_count
      active_holds_table_element.when_visible WebDriverUtils.academics_timeout
      active_holds_table_element.rows - 1
    end

    def active_hold_reasons
      types = active_holds_table_element.map { |row| row[0].text }
      types.drop 1
    end

    def active_hold_dates
      types = active_holds_table_element.map { |row| row[1].text }
      types.drop 1
    end

    def expand_hold_detail(row_index)
      active_holds_table_element[row_index].click
    end

  end
end
