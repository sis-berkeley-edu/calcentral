module CalCentralPages

  class MyProfileWorkExperienceCard < MyProfilePage

    include PageObject
    include ClassLogger
    include CalCentralPages

    h2(:heading, :xpath => '//h2[text()="Work Experience"]')
    elements(:employer, :div, :xpath => '//strong[@data-ng-bind="item.employer"]')
    button(:add, :xpath => '//button[contains(., "Add")]')
    elements(:employment_edit, :button, :xpath => '//button[contains(text(), "Edit")]')

    form(:edit_form, :name => 'cc_page_widget_profile_work_experience')
    text_area(:employer_input, :id => 'cc-page-widget-profile-work-experience-employment-descr')
    select_list(:country_select, :id => 'cc-page-widget-profile-address-country')
    text_area(:phone_input, :id => 'cc-page-widget-profile-work-experience-phone-number')
    text_area(:start_date_input, :id => 'cc-page-widget-profile-work-experience-start-date')
    text_area(:end_date_input, :id => 'cc-page-widget-profile-work-experience-end-date')
    paragraph(:date_validation_error, :xpath => '//p[contains(text(),"Please use mm/dd/yyyy date format")]')
    text_area(:title_input, :id => 'cc-page-widget-profile-work-experience-job-title')
    radio_button(:full_time_radio, :xpath => '//span[text()="Full Time"]/preceding-sibling::input')
    radio_button(:three_quarter_time_radio, :xpath => '//span[text()="3/4 Time"]/preceding-sibling::input')
    radio_button(:half_time_radio, :xpath => '//span[text()="Half Time"]/preceding-sibling::input')
    radio_button(:one_quarter_time_radio, :xpath => '//span[text()="1/4 Time"]/preceding-sibling::input')
    text_area(:pay_rate_input, :id => 'cc-page-widget-profile-work-experience-ending-pay-rate')
    select_list(:currency_select, :id => 'cc-page-widget-profile-work-experience-currency-type')
    text_area(:hours_per_week_input, :id => 'cc-page-widget-profile-work-experience-hours-per-week')
    select_list(:pay_frequency_select, :id => 'cc-page-widget-profile-work-experience-pay-frequency')
    button(:save, :xpath => '//button[contains(.,"Save")]')
    button(:cancel, :xpath => '//button[contains(.,"Cancel")]')
    button(:delete, :xpath => '//button[text()="Delete work experience"]')

    def load_page
      logger.debug 'Loading profile work experience page'
      navigate_to "#{WebDriverUtils.base_url}/profile/work-experience"
    end

    def all_employers
      employer_elements.map &:text
    end

    def get_job_index(jobs_added, job)
      wait_until(WebDriverUtils.page_load_timeout) { employer_elements.any? }
      sorted_jobs(jobs_added).index job
    end

    def sorted_jobs(jobs_added)
      # Jobs without start dates come before jobs with dates
      jobs_without_dates = (jobs_added.select { |j| job_data(j)[:start_date].blank? }).sort_by { |j| job_data(j)[:index] }
      jobs_with_dates = (jobs_added.select { |j| !job_data(j)[:start_date].blank? }).sort_by { |j| DateTime.strptime(job_data(j)[:start_date], '%m/%d/%Y') }
      jobs_without_dates.reverse + jobs_with_dates.reverse
    end

    def fraction_radio(job_data)
      case job_data[:fraction]
        when '100'
          full_time_radio_element
        when '75'
          three_quarter_time_radio_element
        when '50'
          half_time_radio_element
        when '25'
          one_quarter_time_radio_element
        else
          nil
      end
    end

    def click_add_job
      click_cancel if cancel_element.visible?
      click_element_js add_element
    end

    def click_edit(index)
      click_cancel if cancel_element.visible?
      click_element_js employment_edit_elements[index]
    end

    def click_save
      click_element_js save_element
      # Wait for transaction to complete
      sleep WebDriverUtils.page_event_timeout
    end

    def click_cancel
      click_element_js cancel_element
      add_element.when_visible WebDriverUtils.page_event_timeout
    end

    def click_delete_job
      click_element_js delete_element
    end

    def inputs_max(inputs)
      {
          employer: inputs['employer'],
          phone: inputs['phone'],
          title: inputs['title']
      }
    end

    def job_data(job)
      {
          employer: job['employer'],
          country: job['country'],
          phone: job['phone'],
          start_date: job['startDate'],
          end_date: job['endDate'],
          title: job['title'],
          fraction: job['fraction'],
          rate: job['rate'],
          currency: job['currency'],
          hours: job['hours'],
          pay_frequency: job['payFrequency']
      }
    end

    def enter_job(job_data)
      logger.info "Entering job data for employer '#{job_data[:employer]}'"
      edit_form_element.when_visible WebDriverUtils.page_event_timeout
      clear_and_type(employer_input_element, job_data[:employer])
      self.country_select = job_data[:country] unless country_select == job_data[:country]
      clear_and_type(phone_input_element, job_data[:phone])
      clear_and_type(start_date_input_element, job_data[:start_date])
      clear_and_type(end_date_input_element, job_data[:end_date])
      clear_and_type(title_input_element, job_data[:title])
      click_element_js fraction_radio(job_data) unless job_data[:fraction].blank?
      clear_and_type(hours_per_week_input_element, job_data[:hours])
      self.currency_select = job_data[:currency] unless currency_select == job_data[:currency]
      clear_and_type(pay_rate_input_element, job_data[:rate])
      self.pay_frequency_select = job_data[:pay_frequency] unless pay_frequency_select == job_data[:pay_frequency]
    end

    def trimmed_input(field_max, input)
      # returns the max allowed in a field regardless of what a user enters
      input.slice(0..(field_max.to_i - 1)).strip
    end

    def verify_job(job_data, index, inputs)
      logger.info "Verifying job with employer #{job_data[:employer]} at index #{index}"
      logger.debug "The current sort order of jobs in the UI is '#{all_employers}'"

      # Employer has max char
      expected_employer = trimmed_input(inputs_max(inputs)[:employer], job_data[:employer])
      wait_until(1, "Expected '#{expected_employer}' but got '#{employer_elements[index].text}'") do
        employer_elements[index].text == expected_employer
      end

      # TODO: verify the start / end dates on the work experience list

      click_edit index

      # Employer is required, has max char
      wait_until(1, "Expected '#{expected_employer}' but got '#{employer_input}'") do
        employer_input == expected_employer
      end

      # Country is required, defaults to US
      expected_country = job_data[:country]
      wait_until(1, "Expected '#{expected_country}' but got '#{country_select}'") do
        expected_country.blank? ? country_select == 'United States' : country_select == expected_country
      end

      # Phone is optional, has max char
      expected_phone = trimmed_input(inputs_max(inputs)[:phone], job_data[:phone])
      wait_until(1, "Expected '#{expected_phone}' but got '#{phone_input}'") do
        expected_phone.blank? ? phone_input.blank? : phone_input == expected_phone
      end

      # TODO: verify the start / end dates on the work experience edit form

      # Job title is optional, has max char
      expected_title = trimmed_input(inputs_max(inputs)[:title], job_data[:title])
      wait_until(1, "Expected '#{expected_title}' but got '#{title_input}'") do
        expected_title.blank? ? title_input.blank? : title_input == expected_title
      end

      # Time fraction is optional
      wait_until(1) do
        fraction_radio(job_data).selected? unless job_data[:fraction].blank?
      end

      # Pay rate is optional
      expected_rate = job_data[:rate]
      wait_until(1, "Expected '#{expected_rate} but got '#{pay_rate_input}'") do
        expected_rate.blank? ? pay_rate_input.blank? : pay_rate_input == expected_rate
      end

      # Currency is required, defaults to USD
      expected_currency = job_data[:currency]
      wait_until(1, "Expected '#{expected_currency}' but got '#{currency_select}'") do
        expected_currency.blank? ? currency_select == 'USD - US Dollar' : currency_select == expected_currency
      end

      # Hours is optional
      expected_hours = job_data[:hours]
      wait_until(1, "Expected '#{expected_hours}' but got '#{hours_per_week_input}'") do
        hours_per_week_input == expected_hours
      end

      # Pay frequency is required, defaults to Month
      expected_pay_frequency = job_data[:pay_frequency]
      wait_until(1, "Expected '#{expected_pay_frequency}' but got '#{pay_frequency_select}'") do
        expected_pay_frequency.blank? ? pay_frequency_select == 'Month' : pay_frequency_select == expected_pay_frequency
      end
    end

    def add_new_job(jobs_added, job)
      logger.info 'Adding a new job'
      job_data = job_data job
      click_add_job
      enter_job job_data
      click_save
      # Add the new job to the collection of jobs added thus far
      jobs_added << job
      jobs_now = sorted_jobs jobs_added
      logger.info "The current sort order of jobs should be: #{jobs_now.map { |j| job_data(j)[:employer] }}"
      jobs_now
    end

    def edit_job(jobs_added, existing_job, edited_job)
      logger.info 'Editing an existing job'
      job_data = job_data edited_job
      index = get_job_index(jobs_added, existing_job)
      click_edit index
      enter_job job_data
      click_save
      # To keep track of jobs in the UI, replace the original job with the edited job
      jobs_added.map! { |j| j == existing_job ? edited_job : j }
      jobs_now = sorted_jobs jobs_added
      logger.info "The current sort order of jobs should be: #{jobs_now.map { |j| job_data(j)[:employer] }}"
      jobs_now
    end

    def delete_job(index)
      logger.debug "Deleting job at index #{index}"
      jobs = employer_elements.length
      click_edit index
      click_delete_job
      sleep 5
      wait_until(WebDriverUtils.page_event_timeout) { employer_elements.length == jobs - 1 }
    end

    def delete_all_jobs
      job_count = employer_elements.length
      logger.debug "There are #{job_count} jobs to delete"
      (1..job_count).each do
        job_count = employer_elements.length
        delete_job 0
      end
    end

  end
end
