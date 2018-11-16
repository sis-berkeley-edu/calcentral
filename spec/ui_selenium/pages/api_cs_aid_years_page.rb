class ApiCSAidYearsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing aid years from CS')
    navigate_to "#{WebDriverUtils.base_url}/api/campus_solutions/aid_years"
    @parsed = JSON.parse driver.find_element(:xpath, '//pre').text
  end

  def status_code
    @parsed['statusCode']
  end

  def feed
    @parsed['feed']
  end

  def fin_aid_summary
    feed && feed['finaidSummary']
  end

  def fin_aid_years
    fin_aid_summary && fin_aid_summary['finaidYears']
  end

  def fin_aid_year_id(year)
    year['id']
  end

  def fin_aid_year_name(year)
    year['name']
  end

  def fin_aid_semesters(year)
    year['availableSemesters']
  end

  def fin_aid_ui_semesters(year)
    case fin_aid_semesters(year).length
      when 1
        "#{fin_aid_semesters(year)[0]}"
      when 2
        "#{fin_aid_semesters(year)[0]} and #{fin_aid_semesters(year)[1]}"
      when 3
        "#{fin_aid_semesters(year)[0]}, #{fin_aid_semesters(year)[1]} and #{fin_aid_semesters(year)[2]}"
      else
        logger.error 'Unexpected financial aid semesters UI'
    end
  end

  def t_and_c(year)
    year['termsAndConditions']
  end

  def t_and_c_approval(year)
    t_and_c(year)['approved']
  end

  def t_and_c_long_msg(year)
    t_and_c(year)['longMessage']
  end

  def title_iv
    fin_aid_summary['title4']
  end

  def title_iv_approval
    title_iv['approved']
  end

  def title_iv_long_msg
    title_iv['longMessage']
  end

end
