class EdoOracle::ViewChecker

  VIEW_DEPENDENCIES = [
    {
      :id => 'SISEDO.API_COURSEV00_MVW',
      :columns => [
        'catalogNumber-formatted',
        'catalogNumber-number',
        'catalogNumber-prefix',
        'catalogNumber-suffix',
        'cms-id',
        'classSubjectArea',
        'displayName',
        'status-code',
        'subjectArea',
        'transcriptTitle',
        'title',
      ]
    },
    {
      :id => 'SISEDO.CLASSSECTIONALLV00_MVW',
      :columns => [
        'component-code',
        'cs-course-id',
        'displayName',
        'endDate',
        'finalExam',
        'id',
        'maxEnroll',
        'maxWaitlist',
        'primary',
        'primaryAssociatedSectionId',
        'printInScheduleOfClasses',
        'sectionNumber',
        'status-code',
        'session-id',
        'startDate',
        'term-id',
      ]
    },
    {
      :id => 'SISEDO.DISPLAYNAMEXLAT_MVW',
      :columns => [
        'classDisplayName',
        'courseDisplayName',
      ]
    },
    {
      :id => 'SISEDO.ENROLLMENTV00_VW',
      :columns => [
        'ACAD_CAREER',
        'CAMPUS_UID',
        'CLASS_SECTION_ID',
        'GRADING_BASIS_CODE',
        'STDNT_ENRL_STATUS_CODE',
        'STUDENT_ID',
        'TERM_ID',
        'UNITS_TAKEN',
        'WAITLISTPOSITION',
      ]
    },
    {
      :id => 'SISEDO.CC_ENROLLMENTV00_VW',
      :columns => [
        'ACAD_CAREER',
        'CAMPUS_UID',
        'CLASS_SECTION_ID',
        'GRADE_MARK',
        'GRADE_POINTS',
        'GRADING_BASIS_CODE',
        'SESSION_ID',
        'STDNT_ENRL_STATUS_CODE',
        'STUDENT_ID',
        'TERM_ID',
        'UNITS_TAKEN',
        'WAITLISTPOSITION',
      ]
    },
    {
      :id => 'SISEDO.ASSIGNEDINSTRUCTORV00_VW',
      :columns => [
        'campus-uid',
        'cs-course-id',
        'familyName',
        'formattedName',
        'givenName',
        'gradeRosterAccess',
        'instructor-id',
        'number',
        'offeringNumber',
        'printInScheduleOfClasses',
        'role-code',
        'role-descr',
        'session-id',
        'term-id',
      ]
    },
    {
      :id => 'SISEDO.EXAMV00_VW',
      :columns => [
        'cs-course-id',
        'date',
        'endTime',
        'location-descr',
        'offeringNumber',
        'session-id',
        'sectionNumber',
        'startTime',
        'term-id',
        'type-code',
      ]
    },
    {
      :id => 'SISEDO.MEETINGV00_VW',
      :columns => [
        'cs-course-id',
        'endDate',
        'endTime',
        'location-descr',
        'meetsDays',
        'offeringNumber',
        'sectionNumber',
        'session-id',
        'startDate',
        'startTime',
        'term-id',
      ]
    },
    {
      :id => 'SISEDO.PERSON_EMAILV00_VW',
      :columns => [
        'PERSON_KEY',
        'EMAIL_PRIMARY',
      ]
    },
    {
      :id => 'SISEDO.STUDENT_REGISTRATIONV00_VW',
      :columns => [
        'STUDENT_ID',
        'ACADCAREER_CODE',
        'TERM_ID',
        'WITHCNCL_TYPE_CODE',
        'WITHCNCL_TYPE_DESCR',
        'WITHCNCL_REASON_CODE',
        'WITHCNCL_REASON_DESCR',
        'WITHCNCL_FROMDATE',
        'WITHCNCL_LASTATTENDDATE',
      ]
    },
    {
      :id => 'SISEDO.API_COURSEIDENTIFIERSV00_VW',
      :columns => ['subjectArea']
    }
  ]

  def initialize
    @report = {
      :successes => [],
      :errors => []
    }
  end

  def perform_checks
    VIEW_DEPENDENCIES.each do |view|
      check_view(view)
    end
    @report
  end

  def check_view(view)
    query_string = "SELECT #{to_query_columns(view[:columns])} FROM #{view[:id]} WHERE rownum=1"
    results = EdoOracle::Queries.query(query_string)
    log_result(:successes, "#{view[:id]} has no issues") if results
  rescue => e
    log_result(:errors, "Failure to query #{view[:id]} - #{e.to_s}")
  end

  def log_result(type, message)
    @report[type].push(message)
  end

  def to_query_columns(column_names_array)
    column_names_array.map {|column_name|
      "\"#{column_name}\""
    }.join(',')
  end
end
