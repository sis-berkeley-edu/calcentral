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
      :id => 'SISEDO.CLC_ENROLLMENTV00_VW',
      :columns => [
        'STUDENT_ID',
        'CAMPUS_UID',
        'ACAD_CAREER',
        'INSTITUTION',
        'STDNT_ENRL_STATUS_CODE',
        'WAITLISTPOSITION',
        'UNITS_TAKEN',
        'UNITS_EARNED',
        'GRADE_MARK',
        'GRADING_BASIS_CODE',
        'TERM_ID',
        'SESSION_ID',
        'CLASS_SECTION_ID',
        'GRADE_POINTS',
        'CRSE_CAREER',
        'RQMNT_DESIGNTN'
      ]
    },
    {
      :id => 'SISEDO.CLC_ENROLLMENT_LAWV00_VW',
      :columns => [
        'STUDENT_ID',
        'CAMPUS_UID',
        'ACAD_CAREER',
        'INSTITUTION',
        'TERM_ID',
        'CLASS_NBR',
        'SEQ_NBR',
        'UNITS_TAKEN_LAW',
        'UNITS_EARNED_LAW',
        'LOCK_FLAG'
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
      :id => 'SISEDO.STUCAR_TERMV00_VW',
      :columns => [
        'STUDENT_ID',
        'PNP_TOT_UNITS_TAKEN',
        'PNP_TOT_UNITS_PASSED'
      ]
    },
    {
      :id => 'SISEDO.STUDENT_REGISTRATIONV01_VW',
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
    },
    {
      :id => 'SISEDO.CLC_STUDENT_CAREER_TERMV00_VW',
      :columns => [
        'STUDENT_ID',
        'CAMPUS_ID',
        'ACAD_CAREER',
        'INSTITUTION',
        'TERM_ID',
        'TOTAL_EARNED_UNITS',
        'TOTAL_ENROLLED_UNITS',
        'GRADING_COMPLETE'
      ]
    },
    {
      :id => 'SISEDO.CLC_STUDENT_CAREER_TERM_LAWV00_VW',
      :columns => [
        'STUDENT_ID',
        'CAMPUS_ID',
        'ACAD_CAREER',
        'INSTITUTION',
        'TERM_ID',
        'EARNED_UNITS_LAW',
        'ENROLLED_UNITS_LAW'
      ]
    },
    {
      :id => 'SISEDO.CLC_RQMNT_DESIG_DESCR',
      :columns => [
        'INSTITUTION',
        'ACAD_CAREER',
        'TERM_ID',
        'RQMNT_DESIGNTN',
        'DESCRIPTION',
        'DESCRSHORT',
        'DESCRFORMAL'
      ]
    },
    {
      :id => 'SISEDO.DISPLAYNAMEXLATV01_MVW',
      :columns => %w(courseDisplayName classDisplayName)
    },
    {
      :id => 'SISEDO.API_COURSEV01_MVW',
      :columns => %w(cms-version-independent-id displayName subjectArea classSubjectArea catalogNumber-formatted catalogNumber-number catalogNumber-prefix catalogNumber-suffix title transcriptTitle updatedDate fromDate toDate)
    },
    {
      :id => 'SISEDO.EXTENDED_TERM_MVW',
      :columns => %w(STRM TERM_END_DT)
    },
    {
      :id => 'SISEDO.CLC_STUDENT_CAREERV00_VW',
      :columns => %w(STUDENT_ID CAMPUS_ID ACAD_CAREER INSTITUTION PROGRAM_STATUS TOTAL_CUMULATIVE_UNITS TOTAL_TRANSFER_UNITS TRANSFER_CREDIT_UNITS_ADJUSTMENT TRANSFER_TEST_UNITS_AP TRANSFER_TEST_UNITS_IB TRANSFER_TEST_UNITS_ALEVEL)
    },
    {
      :id => 'SISEDO.CLC_STUDENT_CAREER_LAWV00_VW',
      :columns => %w(STUDENT_ID CAMPUS_ID ACAD_CAREER INSTITUTION TOTAL_CUMULATIVE_UNITS_LAW TOTAL_TRANSFER_UNITS_LAW)
    },
    {
      :id => 'SISEDO.CLASSSECTIONALLV01_MVW',
      :columns => %w(id cs-course-id offeringNumber term-id session-id sectionNumber number component-code component-descr displayName instructionMode-code instructionMode-descr startDate endDate status-code status-descr classEnrollmentType-code classEnrollmentType-descr updatedDate cancelDate primary primaryAssociatedComponent primaryAssociatedSectionId enrollmentStatus-code enrollmentStatus-descr enrolledCount waitlistedCount minEnroll maxEnroll maxWaitlist instructorAddConsentRequired instructorDropConsentRequired printInScheduleOfClasses graded feesExist roomShare optionalSection contactHours finalExam topic-id topic-descr)
    },
    {
      :id => 'SISEDO.TERM_TBL_VW',
      :columns => %w(STRM DESCR TERM_BEGIN_DT TERM_END_DT)
    },
    {
      :id => 'SISEDO.STUDENT_PLAN_CC_V00_VW',
      :columns => %w(STUDENT_ID ACADPLAN_CODE ACADPLAN_DESCR ACADPLAN_TYPE_CODE ACADPROG_CODE STATUSINPLAN_STATUS_CODE STATUSINPLAN_STATUS_DESCR STATUSINPLAN_ACTION_CODE STATUSINPLAN_ACTION_DESCR STATUSINPLAN_REASON_CODE STATUSINPLAN_REASON_DESCR ACADPLAN_FROMDATE)
    },
    {
      :id => 'SISEDO.STUDENT_GROUPV01_VW',
      :columns => %w(STUDENT_ID STDNT_GROUP STDNT_GROUP_DESCR STDNT_GROUP_FROMDATE)
    },
    {
      :id => 'SISEDO.APPLICANT_ADMIT_DATAV00_VW',
      :columns => %w(STUDENT_ID ACADCAREER_CODE ACADCAREER_DESCR CAREER_NBR APPLICATION_NBR APPLICATION_PROG_NBR APPLICATION_CENTER ADMIT_TERM ADMIT_TERM_DESCR ADMIT_TYPE ADMIT_TYPE_DESCR PROG_STATUS PROG_STATUS_DESCR PROG_ACTION PROG_ACTION_DESCR ACAD_PROG ACAD_PROG_DESCR EVALUATION_CODE EVALUATION_NBR EVALUATOR_ID EVALUATOR_NAME EVALUATOR_EMAIL FINALIZED ATHLETE ADMITTED_GEP EXPIRE_DT_AD EXPIRE_DT_TC)
    },
    {
      :id => 'SISEDO.CLC_CONCURRENT_PROGRAMV00_VW',
      :columns => %w(STUDENT_ID INSTITUTION CONCURRENT_PROGRAM)
    },
    {
      :id => 'SISEDO.STUDENT_ACAD_STNDNGV00_VW',
      :columns => %w(STUDENT_ID ACADCAREER_CODE TERM_ID ACAD_STANDING_ACTION ACAD_STANDING_ACTION_DESCR OVERRIDE_MANUAL ACAD_PROGRAM ACAD_STANDING_STATUS ACAD_STANDING_STATUS_DESCR ACTION_DATE)
    },
    {
      :id => 'SISEDO.GRADING_DATES_CS_V00_VW',
      :columns => %w(ACAD_CAREER TERM_ID SESSION_CODE TERM_DESCR ACAD_CAREER_DESCR SESSION_DESCR MID_BEGIN_DT MID_END_DT FINAL_BEGIN_DT FINAL_END_DT)
    },
    {
      :id => 'SISEDO.CLC_CURRENT_RESERVE_CAPACITYV00_VW',
      :columns => %w(TERM_ID SUBJECT CATALOG_NBR CLASS_SECTION COMPONENT CLASS_NBR RESERVED_SEATS RESERVED_SEATS_TAKEN REQUIREMENT_GROUP REQUIREMENT_GROUP_DESCR)
    },
    {
      :id => 'SISEDO.STUDENT_TERM_CPPV00_VW',
      :columns => %w(TERM_ID INSTITUTION STUDENT_ID CAMPUS_ID ACAD_CAREER_CODE ACAD_CAREER_DESCR STUDENT_CAREER_NBR ACAD_PROGRAM ACAD_PROGRAM_DESCR ADMIT_TERM_ID EXP_GRAD_TERM_ID REQ_TERM_ID ACAD_PLAN ACAD_PLAN_TYPE ACAD_PLAN_DESCR ACAD_SUB_PLAN ACAD_SUBPLAN_DESCR DEGREE DEGREE_DESCR)
    },
    {
      :id => 'SISEDO.CLC_TRANSFER_CREDIT_SCHLV00_VW',
      :columns => %w(STUDENT_ID CAMPUS_UID ACAD_CAREER INSTITUTION MODEL_NBR ARTICULATION_TERM SCHOOL_DESCR RQMNT_DESIGNTN_DESCRFORMAL UNITS_TRNSFR UNITS_TRNSFR_LAW TRF_GRADE_POINTS)
    },
    {
      :id => 'SISEDO.CLC_FA_HOUSING_VW',
      :columns => %w(STUDENT_ID CAMPUS_UID TERM_DESCR TERM_ID HOUSING_OPTION HOUSING_STATUS HOUSING_BEGIN_DATE HOUSING_END_DATE AID_YEAR ACAD_CAREER NSLDS_LOAN_YEAR ACAD_PROG_PRIMARY ADMIT_TYPE ADMIT_TERM STUDENT_GROUP_CODES)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_IS_ACTIVE_VW',
      :columns => %w(STUDENT_ID IS_STUDENT_ACTIVE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_STD_ENRL_PRE_2168',
      :columns => 'STUDENT_ID INSTITUTION ENRL_PRE_2168'
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_CUMULATIVE',
      :columns => %w(INSTITUTION SEQ_NUM CATEGORY_TITLE CATEGORY_TEXT CATEGORY_TEXT_PRE_2168 SEQ_NUM_TYPE TYPE_TITLE TYPE_MIN_AMOUNT TYPE_DURATION TYPE_INTEREST_RATE TYPE_DETAILS_VIEW_NAME)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_GRADPLUS',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_HPSL',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_INST_STATE',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_PERKINS',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_PRIVATE',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_SUB',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_CUMUL_UNSUB',
      :columns => %w(STUDENT_ID LOAN_AMOUNT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_CATEGORIES_AID_YEAR',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR SEQ_NUM TYPE_DESCRIPTION TYPE_MIN_AMOUNT TYPE_DURATION TYPE_INTEREST_RATE USE_NSLDS_INTEREST_RATE, TYPE_DETAILS_VIEW_NAME)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_GRADPLUS',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_HPSL',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_INST_STATE',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_PERKINS',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_PRIVATE',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_SUB',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_DTL_AY_UNSUB',
      :columns => %w(STUDENT_ID INSTITUTION AID_YEAR FA_SOURCE FA_SOURCE_DESCR LOAN_DESCR FEDERAL_ID LOAN_AMOUNT LOAN_INTEREST_RATE)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_RESOURCES',
      :columns => %w(INSTITUTION SEQ_NUM RESOURCE_URL RESOURCE_TITLE RESOURCE_TEXT RESOURCE_HOVER_OVER)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_GLOSSARY_CUMULATIVE',
      :columns => %w(INSTITUTION SEQ_NUM GLOSSARY_ITEM_CD GLOSSARY_TITLE GLOSSARY_TEXT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_GLOSSARY_AID_YEAR',
      :columns => %w(INSTITUTION SEQ_NUM GLOSSARY_ITEM_CD GLOSSARY_TITLE GLOSSARY_TEXT)
    },
    {
      :id => 'SISEDO.CLC_FA_LNHST_MESSAGES',
      :columns => %w(INSTITUTION MESSAGE_TYPE_CD MESSAGE_TITLE MESSAGE_TEXT)
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
