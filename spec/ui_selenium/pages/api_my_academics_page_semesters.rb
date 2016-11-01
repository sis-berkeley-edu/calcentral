class ApiMyAcademicsPageSemesters < ApiMyAcademicsPage

  include PageObject

  # SEMESTERS

  def all_student_semesters
    @parsed['semesters']
  end

  def all_teaching_semesters
    @parsed['teachingSemesters']
  end

  def semesters_in_time_bucket(semesters, time_bucket)
    semesters.select { |semester| semester['timeBucket'] == time_bucket }
  end

  def past_semesters(semesters)
    semesters_in_time_bucket(semesters, 'past')
  end

  def current_semester(semesters)
    semesters.nil? ? nil : semesters_in_time_bucket(semesters, 'current')[0]
  end

  def future_semesters(semesters)
    semesters_in_time_bucket(semesters, 'future')
  end

  # The semesters visible by default on the My Academics page
  def default_semesters_in_ui(semesters)
    default_semesters = future_semesters(semesters)
    default_semesters << current_semester(semesters) unless current_semester(semesters).nil?
    default_semesters << past_semesters(semesters)[0] if past_semesters(semesters).any?
    default_semesters
  end

  def semester_name(semester)
    semester['name']
  end

  def semester_names(semesters)
    names = []
    semesters.each { |semester| names << semester_name(semester) }
    names
  end

  def semester_slug(semester)
    semester['slug']
  end

  def has_enrollment_data?(semester)
    semester['hasEnrollmentData']
  end

  # COURSES

  def semester_courses(semester)
    semester['classes']
  end

  # Semester cards list courses once per primary section OR once per transcript record (if transcripts exist)
  def semester_card_courses(semester, courses)
    if has_enrollment_data?(semester)
      course_list = []
      courses.each do |course|
        if course_transcripts(course).nil?
          course_primary_sections(course).each { course_list << course }
        else
          course_transcripts(course).each { course_list << course }
        end
      end
      course_list
    else
      courses
    end
  end

  # Semester pages always list courses once per primary section
  def courses_by_primary_section(courses)
    course_list = []
    courses.each do |course|
      course_primary_sections(course).each { course_list << course }
    end
    course_list
  end

  def course_code(course)
    course['course_code']
  end

  def course_codes(courses)
    codes = []
    courses.each { |course| codes << course_code(course) }
    codes
  end

  # Semester cards show course codes differently depending on enrollment data, primary sections, and transcript data
  def semester_card_course_codes(semesters, semester, courses)
    codes = []
    courses.each do |course|
      if has_enrollment_data?(semester)
        if past_semesters(semesters).include?(semester)
          if course_transcripts(course).nil?
            course_primary_sections(course).each { codes << course_code(course) }
          else
            course_transcripts(course).each { codes << course_code(course) }
          end
        elsif !past_semesters(semesters).include?(semester) && multiple_primaries?(course)
          course_primary_sections(course).each { |section| codes << "#{course_code(course)} #{section_label(section)}" }
        else
          codes << course_code(course)
        end
      else
        codes << course_code(course)
      end
    end
    codes
  end

  def course_title(course)
    course['title'].nil? ? '' : (course['title'].gsub(/\s+/, ' ')).strip
  end

  def course_titles(courses)
    titles = []
    courses.each { |course| titles << course_title(course) }
    titles
  end

  def course_url(course)
    course['url']
  end

  def course_slug(course)
    course['slug']
  end

  def course_transcripts(course)
    course['transcript']
  end

  def grade_options(courses)
    options = []
    courses.each { |course| options.concat(sections_grade_options(course_sections(course))) }
    options.compact
  end

  def multiple_primaries?(course)
    course['multiplePrimaries']
  end

  def units_by_enrollment(courses)
    units = courses.map do |course|
      course_primary_sections(course).map { |section| section['units'] }
    end
    units.flatten
  end

  # Semester card shows units by primary section unless transcripts exist
  def semester_card_units(courses)
    units = []
    courses.each do |course|
      if course_transcripts(course).nil?
        course_primary_sections(course).each { |section| units << section['units'] }
      else
        course_transcripts(course).each { |transcript| units << transcript['units'] }
      end
    end
    units
  end

  def transcript_grade(transcript)
    transcript['grade']
  end

  def course_grades(course)
    course_transcripts(course).map { |transcript| transcript_grade(transcript) } unless course_transcripts(course).nil?
  end

  def semester_grades(courses)
    grades = courses.map { |course| course_grades(course) }
    grades.flatten.compact
  end

  def semester_card_grades(semesters, courses, semester)
    grades = []
    courses.each do |course|
      if past_semesters(semesters).include?(semester)
        if course_transcripts(course).nil?
          course_primary_sections(course).each { | | grades << '--' }
        else
          course_transcripts(course).each do |transcript|
            if transcript_grade(transcript).nil?
              grades << ''
            else
              grades << transcript_grade(transcript)
            end
          end
        end
        # EAP grades can turn up on semester cards during the current semester
      elsif !has_enrollment_data?(semester) && !course_transcripts(course).nil?
        course_transcripts(course).each { |transcript| grades << transcript_grade(transcript) }
      end
    end
    grades
  end

  def course_listing_course_codes(course)
    codes = []
    course['listings'].each { |listing| codes << listing['course_code'] }
    codes
  end

  def semester_listing_course_codes(semester)
    codes = []
    semester_courses(semester).each { |course| codes.concat(course_listing_course_codes(course)) }
    codes
  end

  # SECTIONS

  def course_sections(course)
    course['sections']
  end

  def primary_section?(section)
    section['is_primary_section']
  end

  def course_primary_sections(course)
    prim_sections = []
    course_sections(course).each { |section| prim_sections << section if primary_section? section }
    prim_sections
  end

  # Courses with multiple primary sections can have secondaries associated with only one of the primaries
  def associated_sections(course, primary_section)
    assoc_sections = []
    assoc_sections << primary_section
    course_sections(course).each { |section| assoc_sections << section if section['associatedWithPrimary'] == section_slug(primary_section) }
    assoc_sections
  end

  def sections_by_listing(course)
    sections = []
    course_sections(course).each { |section| sections << section if section_course_code(section) == course_code(course) }
    sections
  end

  def sections_ccns(sections)
    ccns = []
    sections.each { |section| ccns << section['ccn'] }
    ccns
  end

  def section_course_code(section)
    section['courseCode']
  end

  def sections_units(sections)
    units = []
    sections.each { |section| units << section['units'] }
    units.compact
  end

  def section_label(section)
    section['section_label']
  end

  def sections_labels(sections)
    labels = []
    sections.each { |section| labels << section_label(section) }
    labels
  end

  # Section labels are omitted from class page section schedules if the section has no schedule
  def section_schedule_labels(sections)
    labels = []
    sections.each { |section| labels << section_label(section) unless section_schedules_recurring(section).empty? }
    labels
  end

  def courses_section_labels(courses)
    labels = []
    courses.each { |course| labels.concat(sections_labels(course_sections(course))) }
    labels
  end

  def section_schedules(section)
    section['schedules']
  end

  def section_schedules_recurring(section)
    section_schedules(section)['recurring']
  end

  def section_schedules_one_time(section)
    section_schedules(section)['oneTime']
  end

  def section_building(schedule)
    schedule['buildingName']
  end

  def section_room(schedule)
    schedule['roomNumber']
  end

  def section_date_time(schedule)
    schedule['schedule']
  end

  def section_date(schedule)
    schedule['date']
  end

  def section_time(schedule)
    schedule['time']
  end

  def course_schedules_recurring(sections)
    schedules = sections.map { |section| section_schedules_recurring section }
    schedules.flatten
  end

  def course_schedules_one_time(sections)
    schedules = sections.map { |section| section_schedules_one_time section }
    schedules.flatten
  end

  def concatenated_schedules(schedules)
    course_schedules = schedules.map do |schedule|
      section_schedule = ''
      section_schedule += "#{section_date_time schedule} " unless section_date_time(schedule).blank?
      section_schedule += "#{section_date schedule} | " unless section_date(schedule).blank?
      section_schedule += "#{section_time schedule} " unless section_time(schedule).blank?
      section_schedule += '| ' unless (section_time(schedule).nil? && section_building(schedule).nil? && section_date_time(schedule).nil?)
      section_schedule += "#{section_room(schedule).strip} " unless section_room(schedule).nil?
      section_schedule += "#{section_building(schedule).strip}" unless section_building(schedule).nil?
      section_schedule.gsub(/\s+/, ' ')
    end
    course_schedules.reject { |schedule| schedule.blank? }
  end

  def section_instructor_names(section)
    names = []
    section['instructors'].each { |instructor| names << instructor['name'].gsub(/\s+/, ' ') }
    names
  end

  def sections_instructor_names(sections)
    names = []
    sections.each { |section| names.concat(section_instructor_names(section)) }
    names
  end

  def sections_grade_options(sections)
    options = []
    sections.each { |section| options << section['gradeOption'] }
    options.compact
  end

  def section_slug(section)
    section['slug']
  end

  def section_url(section)
    section['url']
  end

# WAIT LISTS

  def wait_list_courses(courses)
    wait_lists = []
    courses.each { |course| wait_lists << course unless wait_list_course_sections(course).empty? }
    wait_lists
  end

  def wait_list_course_sections(course)
    wait_list_sections = []
    course_sections(course).each { |section| wait_list_sections << section unless wait_list_position(section).blank? }
    wait_list_sections
  end

  def wait_list_semester_sections(courses)
    wait_list_sections = []
    courses.each { |course| wait_list_sections.concat(wait_list_course_sections(course)) }
    wait_list_sections
  end

  def wait_list_primary_sections(courses)
    wait_list_semester_sections(courses).delete_if { |section| !primary_section?(section) }
  end

  def wait_list_course_codes(wait_list_courses)
    codes = []
    wait_list_courses.each do |course|
      wait_list_course_sections(course).each { codes << course_code(course) }
    end
    codes
  end

  def wait_list_course_titles(wait_list_courses)
    titles = []
    wait_list_courses.each do |course|
      wait_list_course_sections(course).each { titles << course_title(course) }
    end
    titles
  end

  def wait_list_position(section)
    section['waitlistPosition']
  end

  def wait_list_positions(sections)
    positions = []
    sections.each { |section| positions << wait_list_position(section).to_s unless wait_list_position(section).zero? }
    positions
  end

  def enrollment_limits(wait_list_courses)
    limits = []
    wait_list_courses.each do |course|
      course_primary_sections(course).each { |section| limits << section['enroll_limit'].to_s unless section['enroll_limit'].nil? }
    end
    limits
  end

  # ADDITIONAL CREDITS (e.g., AP course work)

  def addl_credits
    @parsed['additionalCredits']
  end

  def addl_credits_titles
    titles = []
    addl_credits.each { |credit| titles << credit['title'] }
    titles
  end

  def addl_credits_units
    units = []
    addl_credits.each { |credit| units << credit['units'] }
    units
  end

  # COURSE SITES

  def course_sites(course)
    course['class_sites']
  end

  def course_site_name(course_site)
    course_site['name'].nil? ? nil : course_site['name'].strip.gsub('  ', ' ')
  end

  def course_site_names(course)
    names = []
    unless course_sites(course).nil?
      course_sites(course).each { |site| names << course_site_name(site) }
    end
    names
  end

  def semester_course_site_names(semester_courses)
    names = []
    semester_courses.each { |course| names.concat(course_site_names(course)) }
    names
  end

  def course_site_descrip(course_site)
    course_site['shortDescription'].nil? ? nil : course_site['shortDescription'].strip.gsub('  ', ' ')
  end

  def course_site_descrips(course)
    descriptions = []
    unless course_sites(course).nil?
      course_sites(course).each do |site|
        unless course_site_descrip(site).nil? || course_site_descrip(site) == course_site_name(site) || course_site_descrip(site) == course_title(course)
          descriptions << course_site_descrip(site)
        end
      end
    end
    descriptions
  end

  def semester_course_site_descrips(semester_courses)
    descriptions = []
    semester_courses.each { |course| descriptions.concat(course_site_descrips(course)) }
    descriptions
  end

  # FINAL EXAMS

  # Current or future semesters can have exams, but not Summer
  def exam_semesters
    ([current_semester(all_student_semesters)] + future_semesters(all_student_semesters)).delete_if { |semester| semester && semester_name(semester).include?('Summer') }
  end

  def exam_schedules
    @parsed['examSchedule']
  end

  def term_exam_schedule(term)
    exam_schedules && exam_schedules.find { |schedule| schedule['name'] == semester_name(term) }
  end

  def exam_schedule_term_name(term)
    term_exam_schedule(term)['name']
  end

  def term_cs_data_available?(term)
    term_exam_schedule(term)['cs_data_available']
  end

  def term_exam_courses(term)
    term_exam_schedule(term) && term_exam_schedule(term)['courses']
  end

  def term_exam_course_codes(term)
    term_exam_courses(term).map { |course| course['name'] }
  end

  def term_exams(term)
    # Collect the data from all the semester exams
    term_exams = []
    term_exam_courses(term).each do |course|
      course_exam = []
      course_exam << semester_name(term)
      course_exam << course['exam_date'].to_s
      course_exam << course['exam_time'].to_s
      # Add a wait list indicator if applicable
      wait_list_courses = wait_list_courses(semester_courses term)
      wait_list_course_codes(wait_list_courses).include?(course['name']) ?
          course_exam << "#{course['name']}(waitlisted)" :
          course_exam << course['name']
      course_exam << course['exam_location']
      course_exam << course['exam_slot']
      term_exams << course_exam
    end
    # Sort the exams by time slot if they have time slots
    exams_without_slots = term_exams.select { |exam| exam[5]== 'none' }
    term_exams.delete_if { |exam| exam[5] == 'none' }
    term_exams = term_exams.sort { |a, b| a[5] <=> b[5] }
    # Exams without time slots come after those with time slots
    term_exams = term_exams + exams_without_slots
    # Remove the time slots since they do not surface in the UI
    term_exams.each { |exam| exam.pop }
    term_exams
  end

  def has_conflicts?(term)
    # Collect the non-empty exam dates and times and check if any dupes exist
    dates_and_times = []
    term_exams(term).each { |exam| dates_and_times << [exam[1], exam[2]] unless (exam[1].blank? || exam[2].blank?) }
    dates_and_times.uniq!.present?
  end

end
