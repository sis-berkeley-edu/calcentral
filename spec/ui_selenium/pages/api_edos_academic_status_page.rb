class ApiEdosAcademicStatusPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    # Note: This API was removed in SISRP-37719 / SISRP-43077
    logger.info 'Fetching data from /api/edos/academic_status'
    navigate_to "#{WebDriverUtils.base_url}/api/edos/academic_status"
    @parsed = JSON.parse driver.find_element(:xpath => '//pre').text
  end

  def holds
    @parsed['feed'] && @parsed['feed']['student'] && @parsed['feed']['student']['holds']
  end

  def hold_reason_descriptions
    descriptions = holds.map { |hold| hold['reason'] && hold['reason']['description'].gsub(/\s+/, ' ') }
    descriptions.compact
  end

  def hold_reason_formal(hold)
    hold['reason'] && hold['reason']['formalDescription']
  end

  def hold_dates
    # Hold date shows actual date if there is one, otherwise shows term
    holds.map { |hold| hold['fromDate'] ? Time.strptime(hold['fromDate'], '%Y-%m-%d').strftime('%m/%d/%y') : hold['fromTerm']['name'] }
  end

end
