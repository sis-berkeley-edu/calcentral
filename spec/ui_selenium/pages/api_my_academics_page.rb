class ApiMyAcademicsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info 'Parsing JSON from /api/my/academics'
    navigate_to "#{WebDriverUtils.base_url}/api/my/academics"
    @parsed = JSON.parse driver.find_element(:xpath, '//pre').text
  end

  def academics_date(epoch)
    (Time.strptime(epoch, '%s')).strftime("%a %b %-d")
  end

  def academics_time(epoch)
    time_format = (Time.strptime(epoch, '%s')).strftime("%-l:%M %p")
    (time_format == '12:00 PM') ? 'Noon' : time_format
  end

  # PROFILE

  def college_and_level
    @parsed['collegeAndLevel']
  end

  # Use case for multiple careers is Law + MBA
  def careers
    college_and_level['careers']
  end

  def has_no_standing?
    college_and_level['empty']
  end

  def student_not_found?
    college_and_level['studentNotFound'].blank?
  end

  def level
    college_and_level['level']
  end

  def non_ap_level
    college_and_level['nonApLevel']
  end

  def gpa_units
    @parsed['gpaUnits']
  end

  def gpa
    gpa_units['cumulativeGpa']
  end

  def ttl_units
    units = gpa_units['totalUnits']
    if units.nil?
      nil
    else
      (units == units.floor) ? units.floor : units
    end
  end

  def units_attempted
    gpa_units['totalUnitsAttempted']
  end

  def colleges_and_majors
    college_and_level['majors']
  end

  def colleges
    colleges = colleges_and_majors.map { |college| college['college'] }
    # For double majors within the same college, only show the college once
    colleges.reject { |college| college.blank? }
  end

  def majors
    colleges_and_majors.map { |college_and_major| college_and_major['major'].split.join(' ') }
  end

  def term_name
    college_and_level['termName']
  end

  def transition_term
    @parsed['transitionTerm']
  end

  def transition_term?
    transition_term.nil? ? false : true
  end

  def trans_term_name
    transition_term['termName']
  end

  def trans_term_registered?
    transition_term['registered']
  end

  def trans_term_profile_current?
    transition_term['isProfileCurrent']
  end

  # OTHER SITE MEMBERSHIPS

  def other_site_memberships
    @parsed['otherSiteMemberships']
  end

  def other_sites(semester_name)
    sites = []
    other_site_memberships.nil? ? nil : other_site_memberships.each { |membership| sites.concat(membership['sites']) if membership['name'] == semester_name }
    sites
  end

  def other_site_names(sites)
    sites.map { |site| site['name'] }
  end

  def other_site_descriptions(sites)
    sites.map { |site| site['shortDescription'].gsub(/\s+/, ' ') }
  end

end
