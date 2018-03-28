class ApiMyStatusPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/status')
    navigate_to "#{WebDriverUtils.base_url}/api/my/status"
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def full_name
    @parsed['fullName']
  end

  def sid
    @parsed['sid']
  end

  def roles
    @parsed['roles']
  end

  def academicRoles
    @parsed['academicRoles']
  end

  def is_applicant?
    roles['applicant']
  end

  def is_student?
    roles['student']
  end

  def is_registered?
    roles['registered']
  end

  def is_ex_student?
    roles['exStudent']
  end

  def is_faculty?
    roles['faculty']
  end

  def is_staff?
    roles['staff']
  end

  def is_guest?
    roles['guest']
  end

  def is_concurrent_enroll_student?
    roles['concurrentEnrollmentStudent']
  end

  def is_advisor?
    roles['advisor']
  end

  def is_delegate?
    roles['isDelegateUser']
  end

  def is_law_student?
    roles['law']
  end

  def is_legacy_user?
    @parsed['isLegacyStudent']
  end

  def has_student_history?
    @parsed['hasStudentHistory']
  end

  def has_instructor_history?
    @parsed['hasInstructorHistory']
  end

  def has_academics_tab?
    @parsed['hasAcademicsTab']
  end

  def has_finances_tab?
    @parsed['hasFinancialsTab']
  end

  def has_toolbox_tab?
    @parsed['hasToolboxTab']
  end

end
