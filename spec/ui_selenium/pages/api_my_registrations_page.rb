class ApiMyRegistrationsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info 'Parsing JSON from /api/my/registrations'
    navigate_to "#{WebDriverUtils.base_url}/api/my/registrations"
    @parsed = JSON.parse driver.find_element(:xpath, '//pre').text
  end

  def terms
    @parsed['terms']
  end

  def current_term
    terms && terms['current']
  end

  def next_term
    terms && terms['next']
  end

  def future_term
    terms && terms['future']
  end

  def term_end_date(term)
    term['end'] && Date.parse(term['end']).to_date
  end

  def active_reg_status_terms
    [future_term, next_term, current_term].compact
  end

  def terms_with_registrations
    terms = active_reg_status_terms.map { |term| term_registrations(term_id term) }
    terms.compact.flatten
  end

  def term_id(term)
    term['id']
  end

  def term_name(term)
    term['name']
  end

  def registrations
    @parsed['registrations']
  end

  def term_registrations(term_id)
    registrations && registrations["#{term_id}"]
  end

  def reg_status(term_id, index)
    term_registrations(term_id) && (term_registrations(term_id)[index]['regStatus'] if term_registrations(term_id).any?)
  end

  def reg_status_summary(term_id, index)
    reg_status(term_id, index) && reg_status(term_id, index)['summary']
  end

  def registered?(term, index)
    term_registrations(term_id(term))[index]['registered']
  end

  def current_term_reg_status
    reg_status(term_id(current_term), 0) && (reg_status_summary(term_id(current_term), 0).include?('Registered') if (current_term && term_registrations(term_id current_term)))
  end

end
