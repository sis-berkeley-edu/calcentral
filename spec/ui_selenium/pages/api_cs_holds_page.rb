class ApiCSHoldsPage

  include PageObject
  include ClassLogger

  def initialize(root, visit=false)
    logger.warn 'DEPRECATION WARNING: ApiCSHoldsPage is deprecated. The CampusSolutions::Holds feed is not in use and the route \'/api/campus_solutions/holds\' has been deleted.'
    super
  end

  def get_json(driver)
    logger.info 'Fetching data from /api/campus_solutions/holds'
    navigate_to "#{WebDriverUtils.base_url}/api/campus_solutions/holds"
    @parsed = JSON.parse driver.find_element(:xpath => '//pre').text
  end

  def service_indicators
    @parsed['feed'] && @parsed['feed']['serviceIndicators']
  end

  def has_t_calc?
    service_indicator_reasons(service_indicators).include? 'Tuition Calculated for term'
  end

  def service_indicator_reasons(indicators)
    indicators && (indicators.map { |indicator| indicator['reasonDescr'].gsub(/\s+/, ' ') }).to_a
  end

  def service_indicator_dates(indicators)
    indicators.map do |indicator|
      # Shows the start term if there is no start date
      indicator['startDate'].blank? ?
          service_indicator_term(indicator) :
          Time.strptime(indicator['startDate']['epoch'].to_s, '%s').strftime('%m/%d/%y')
    end
  end

  def service_indicator_term(indicator)
    indicator['startTermDescr']
  end

  def service_indicator_contacts(indicator)
    indicator['contactName']
  end

  def service_indicator_instructions(indicator)
    indicator['instructions']
  end

end
