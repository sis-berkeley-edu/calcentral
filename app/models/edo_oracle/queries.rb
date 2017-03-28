module EdoOracle
  class Queries < Connection
    include ActiveRecordHelper
    include ClassLogger

    CANONICAL_SECTION_ORDERING = 'section_display_name, primary DESC, instruction_format, section_num'

    # Changes from CampusOracle::Queries section columns:
    #   - 'course_cntl_num' now 'section_id'
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - 'catalog_suffix_1' and 'catalog_suffix_2' replaced by 'catalog_suffix' (combined)
    #   - 'primary_secondary_cd' replaced by Boolean 'primary'
    #   - 'course_display_name' and 'section_display_name' added
    SECTION_COLUMNS = <<-SQL
      sec."id" AS section_id,
      sec."term-id" AS term_id,
      sec."session-id" AS session_id,
      TRIM(crs."title") AS course_title,
      TRIM(crs."transcriptTitle") AS course_title_short,
      crs."subjectArea" AS dept_name,
      crs."classSubjectArea" AS dept_code,
      sec."primary" AS primary,
      sec."sectionNumber" AS section_num,
      sec."component-code" as instruction_format,
      sec."primaryAssociatedSectionId" as primary_associated_section_id,
      sec."displayName" AS section_display_name,
      xlat."courseDisplayName" AS course_display_name,
      crs."catalogNumber-formatted" AS catalog_id,
      crs."catalogNumber-number" AS catalog_root,
      crs."catalogNumber-prefix" AS catalog_prefix,
      crs."catalogNumber-suffix" AS catalog_suffix
    SQL

    JOIN_SECTION_TO_COURSE = <<-SQL
      LEFT OUTER JOIN SISEDO.DISPLAYNAMEXLAT_MVW xlat ON (
        xlat."classDisplayName" = sec."displayName")
      LEFT OUTER JOIN SISEDO.API_COURSEV00_VW crs ON (
        xlat."courseDisplayName" = crs."displayName" AND
        crs."status-code" = 'ACTIVE')
    SQL

    JOIN_ROSTER_TO_EMAIL = <<-SQL
       LEFT OUTER JOIN SISEDO.PERSON_EMAILV00_VW email ON (
         email."PERSON_KEY" = enroll."STUDENT_ID" AND
         email."EMAIL_PRIMARY" = 'Y')
    SQL

    # EDO equivalent of CampusOracle::Queries.get_enrolled_sections
    # Changes:
    #   - 'wait_list_seq_num' replaced by 'waitlist_position'
    #   - 'course_option' removed
    #   - 'cred_cd' and 'pnp_flag' replaced by 'grading_basis'
    def self.get_enrolled_sections(person_id, terms = nil)
      # The push_pred hint below alerts Oracle to use indexes on SISEDO.API_COURSEV00_VW, aka crs.
      safe_query <<-SQL
        SELECT /*+ push_pred(crs) */
          #{SECTION_COLUMNS},
          sec."maxEnroll" AS enroll_limit,
          enr."STDNT_ENRL_STATUS_CODE" AS enroll_status,
          enr."WAITLISTPOSITION" AS waitlist_position,
          enr."UNITS_TAKEN" AS units,
          enr."GRADE_MARK" AS grade,
          enr."GRADING_BASIS_CODE" AS grading_basis
        FROM SISEDO.ENROLLMENT_UIDV00_VW enr
        JOIN SISEDO.CLASSSECTIONV00_VW sec ON (
          enr."TERM_ID" = sec."term-id" AND
          enr."SESSION_ID" = sec."session-id" AND
          enr."CLASS_SECTION_ID" = sec."id" AND
          sec."status-code" IN ('A','S') )
        #{JOIN_SECTION_TO_COURSE}
        WHERE enr."TERM_ID" IN (#{terms_query_list terms})
          AND enr."CAMPUS_UID" = '#{person_id}'
          AND enr."STDNT_ENRL_STATUS_CODE" != 'D'
        ORDER BY term_id DESC, #{CANONICAL_SECTION_ORDERING}
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.get_instructing_sections
    # Changes:
    #   - 'cs-course-id' added.
    def self.get_instructing_sections(person_id, terms = nil)
      safe_query <<-SQL
        SELECT
          #{SECTION_COLUMNS},
          sec."cs-course-id" AS cs_course_id,
          sec."maxEnroll" AS enroll_limit,
          sec."maxWaitlist" AS waitlist_limit,
          sec."startDate" AS start_date,
          sec."endDate" AS end_date
        FROM SISEDO.ASSIGNEDINSTRUCTORV00_VW instr
        JOIN SISEDO.CLASSSECTIONV00_VW sec ON (
          instr."term-id" = sec."term-id" AND
          instr."session-id" = sec."session-id" AND
          instr."cs-course-id" = sec."cs-course-id" AND
          instr."offeringNumber" = sec."offeringNumber" AND
          instr."number" = sec."sectionNumber")
        #{JOIN_SECTION_TO_COURSE}
        WHERE sec."status-code" IN ('A','S')
          AND instr."term-id" IN (#{terms_query_list terms})
          AND instr."campus-uid" = '#{person_id}'
        ORDER BY term_id DESC, #{CANONICAL_SECTION_ORDERING}
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.get_secondary_sections.
    # Changes:
    #   - More precise associations allow us to query by primary section rather
    #     than course catalog ID.
    #   - 'cs-course-id' added.
    def self.get_associated_secondary_sections(term_id, section_id)
      safe_query <<-SQL
        SELECT
          #{SECTION_COLUMNS},
          sec."cs-course-id" AS cs_course_id,
          sec."maxEnroll" AS enroll_limit,
          sec."maxWaitlist" AS waitlist_limit
        FROM SISEDO.CLASSSECTIONV00_VW sec
        #{JOIN_SECTION_TO_COURSE}
        WHERE sec."status-code" IN ('A','S')
          AND sec."primary" = 'false'
          AND sec."term-id" = '#{term_id}'
          AND sec."primaryAssociatedSectionId" = '#{section_id}'
        ORDER BY #{CANONICAL_SECTION_ORDERING}
      SQL
    end

    # EDO equivalent of #CampusOracle::Queries.get_course_secondary_sections
    # see #self.get_course_sections
    def self.get_course_secondary_sections(term_id, department, catalog_id)
      get_course_sections(term_id, department, catalog_id, true)
    end

    # EDO equivalent of #CampusOracle::Queries.get_all_course_sections
    # see #self.get_course_sections
    def self.get_all_course_sections(term_id, department, catalog_id)
      get_course_sections(term_id, department, catalog_id, false)
    end

    # EDO equivalent of CampusOracle::Queries.get_section_schedules
    # Changes:
    #   - 'course_cntl_num' is replaced with 'section_id'
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - 'session_id' added
    #   - 'building_name' and 'room_number' combined as 'location'
    #   - 'meeting_start_time_ampm_flag' is included in 'meeting_start_time' timestamp
    #   - 'meeting_end_time_ampm_flag' is included in 'meeting_end_time' timestamp
    #   - 'multi_entry_cd' obsolete now that multiple meetings directly associated with section
    #   - 'print_cd' replaced with 'print_in_schedule_of_classes' boolean
    #   - 'meeting_start_date' and 'meeting_end_date' added
    def self.get_section_meetings(term_id, section_id)
      safe_query <<-SQL
        SELECT DISTINCT
          sec."id" AS section_id,
          sec."printInScheduleOfClasses" AS print_in_schedule_of_classes,
          mtg."term-id" AS term_id,
          mtg."session-id" AS session_id,
          mtg."location-descr" AS location,
          mtg."meetsDays" AS meeting_days,
          mtg."startTime" AS meeting_start_time,
          mtg."endTime" AS meeting_end_time,
          mtg."startDate" AS meeting_start_date,
          mtg."endDate" AS meeting_end_date
        FROM
          SISEDO.MEETINGV00_VW mtg
        JOIN SISEDO.CLASSSECTIONV00_VW sec ON (
          mtg."cs-course-id" = sec."cs-course-id" AND
          mtg."term-id" = sec."term-id" AND
          mtg."session-id" = sec."session-id" AND
          mtg."offeringNumber" = sec."offeringNumber" AND
          mtg."sectionNumber" = sec."sectionNumber"
        )
        WHERE
          sec."term-id" = '#{term_id}' AND
          sec."id" = '#{section_id}'
        ORDER BY meeting_start_date, meeting_start_time
      SQL
    end

    # No Campus Oracle equivalent.
    def self.get_section_final_exam(term_id, section_id)
      safe_query <<-SQL
        SELECT DISTINCT
          sec."term-id" AS term_id,
          sec."session-id" AS session_id,
          sec."id" AS section_id,
          sec."finalExam" AS exam_type,
          exam."date" AS exam_date,
          exam."startTime" AS exam_start_time,
          exam."endTime" AS exam_end_time,
          exam."location-descr" AS location
        FROM
          SISEDO.EXAMV00_VW exam
        RIGHT JOIN SISEDO.CLASSSECTIONV00_VW sec ON (
          exam."cs-course-id" = sec."cs-course-id" AND
          exam."term-id" = sec."term-id" AND
          exam."session-id" = sec."session-id" AND
          exam."offeringNumber" = sec."offeringNumber" AND
          exam."sectionNumber" = sec."sectionNumber" AND
          exam."type-code" = 'FIN'
        )
        WHERE
          sec."term-id" = '#{term_id}' AND
          sec."id" = '#{section_id}' AND
          sec."finalExam" IN ('A', 'Y')
        ORDER BY exam_date
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.get_sections_from_ccns
    # Changes:
    #   - 'course_cntl_num' is replaced with 'section_id'
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - 'catalog_suffix_1' and 'catalog_suffix_2' replaced by 'catalog_suffix' (combined)
    #   - 'primary_secondary_cd' replaced by Boolean 'primary'
    def self.get_sections_by_ids(term_id, section_ids)
      safe_query <<-SQL
        SELECT
          #{SECTION_COLUMNS}
        FROM SISEDO.CLASSSECTIONV00_VW sec
        #{JOIN_SECTION_TO_COURSE}
        WHERE sec."term-id" = '#{term_id}'
          AND sec."id" IN (#{section_ids.collect { |id| id.to_i }.join(', ')})
        ORDER BY #{CANONICAL_SECTION_ORDERING}
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.get_section_instructors
    # Changes:
    #   - 'ccn' replaced by 'section_id' argument
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - 'instructor_func' has become represented by 'role_code' and 'role_description'
    #   - Does not provide all user profile fields ('email_address', 'student_id', 'affiliations').
    #     This will require a programmatic join at a higher level.
    #     See CLC-6239 for implementation of batch LDAP profile requests.
    def self.get_section_instructors(term_id, section_id)
      safe_query <<-SQL
        SELECT DISTINCT
          TRIM(instr."formattedName") AS person_name,
          TRIM(instr."givenName") AS first_name,
          TRIM(instr."familyName") AS last_name,
          instr."campus-uid" AS ldap_uid,
          instr."role-code" AS role_code,
          instr."role-descr" AS role_description,
          instr."gradeRosterAccess" AS grade_roster_access,
          instr."printInScheduleOfClasses" AS print_in_schedule
        FROM
          SISEDO.ASSIGNEDINSTRUCTORV00_VW instr
        JOIN SISEDO.CLASSSECTIONV00_VW sec ON (
          instr."cs-course-id" = sec."cs-course-id" AND
          instr."term-id" = sec."term-id" AND
          instr."session-id" = sec."session-id" AND
          instr."offeringNumber" = sec."offeringNumber" AND
          instr."number" = sec."sectionNumber"
        )
        WHERE
          sec."id" = '#{section_id.to_s}' AND
          sec."term-id" = '#{term_id.to_s}' AND
          TRIM(instr."instructor-id") IS NOT NULL
        ORDER BY
          role_code
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.terms
    # Changes:
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - 'term_status', 'term_status_desc', and 'current_tb_term_flag' are not present.
    #     No indication of past, current, or future term status
    #   - Multiple entries for each term due to differing start and end dates that
    #     may exist for LAW as compared to GRAD, UGRAD, or UCBX
    def self.terms
      safe_query <<-SQL
        SELECT
          term."STRM" as term_code,
          trim(term."DESCR") AS term_name,
          term."TERM_BEGIN_DT" AS term_start_date,
          term."TERM_END_DT" AS term_end_date
        FROM
          SISEDO.TERM_TBL_VW term
        ORDER BY
          term_start_date desc
      SQL
    end

    def self.get_cross_listed_course_title(course_code)
      result = safe_query <<-SQL
        SELECT DISTINCT
          TRIM(crs."title") AS course_title,
          TRIM(crs."transcriptTitle") AS course_title_short
        FROM SISEDO.API_CROSSLISTINGSV00_VW xlist
        JOIN SISEDO.API_COURSEV00_VW crs ON
          (xlist."cms-id" = crs."cms-id")
        WHERE xlist."displayName" = '#{course_code}'
      SQL
      result.first if result
    end

    def self.get_subject_areas
      safe_query <<-SQL
        SELECT DISTINCT "subjectArea" FROM SISEDO.API_COURSEIDENTIFIERSV00_VW
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.get_enrolled_students
    # Changes:
    #   - 'ccn' replaced by 'section_id' argument
    #   - 'pnp_flag' replaced by 'grading_basis'
    #   - 'term_yr' and 'term_yr' replaced by 'term_id'
    #   - 'calcentral_student_info_vw' data (first_name, last_name, student_email_address,
    #     affiliations) are not present as these are provided by the CalNet LDAP or HubEdos module.
    def self.get_enrolled_students(section_id, term_id)
      safe_query <<-SQL
        SELECT DISTINCT
          enroll."CAMPUS_UID" AS ldap_uid,
          enroll."STUDENT_ID" AS student_id,
          enroll."STDNT_ENRL_STATUS_CODE" AS enroll_status,
          enroll."WAITLISTPOSITION" AS waitlist_position,
          enroll."UNITS_TAKEN" AS units,
          TRIM(enroll."GRADING_BASIS_CODE") AS grading_basis
        FROM SISEDO.ENROLLMENTV00_VW enroll
        WHERE
          enroll."CLASS_SECTION_ID" = '#{section_id}'
          AND enroll."TERM_ID" = '#{term_id}'
          AND enroll."STDNT_ENRL_STATUS_CODE" != 'D'
      SQL
    end

    # Extended version of #get_enrolled_students used for rosters
    def self.get_rosters(ccns, term_id)
      if Settings.features.allow_alt_email_addr_for_enrollments
        join_roster_to_email = JOIN_ROSTER_TO_EMAIL
        email_col = ", email.\"EMAIL_EMAILADDRESS\" AS email_address"
      end

      safe_query <<-SQL
        SELECT DISTINCT
          enroll."CLASS_SECTION_ID" AS section_id,
          enroll."CAMPUS_UID" AS ldap_uid,
          enroll."STUDENT_ID" AS student_id,
          enroll."STDNT_ENRL_STATUS_CODE" AS enroll_status,
          enroll."WAITLISTPOSITION" AS waitlist_position,
          enroll."UNITS_TAKEN" AS units,
          enroll."ACAD_CAREER" AS academic_career,
          TRIM(enroll."GRADING_BASIS_CODE") AS grading_basis,
          plan."ACADPLAN_DESCR" AS major,
          plan."STATUSINPLAN_STATUS_CODE",
          stdgroup."STDNT_GROUP" AS terms_in_attendance_group
          #{email_col}
        FROM SISEDO.ENROLLMENTV00_VW enroll
        LEFT OUTER JOIN
          SISEDO.STUDENT_PLAN_CC_V00_VW plan ON enroll."STUDENT_ID" = plan."STUDENT_ID" AND
          plan."ACADPLAN_TYPE_CODE" IN ('CRT', 'HS', 'MAJ', 'SP', 'SS')
        LEFT OUTER JOIN
          SISEDO.STUDENT_GROUPV00_VW stdgroup ON enroll."STUDENT_ID" = stdgroup."STUDENT_ID" AND
          stdgroup."STDNT_GROUP" IN ('R1TA', 'R2TA', 'R3TA', 'R4TA', 'R5TA', 'R6TA', 'R7TA', 'R8TA')
        #{join_roster_to_email}
        WHERE
          enroll."CLASS_SECTION_ID" IN ('#{ccns.join "','"}')
          AND enroll."TERM_ID" = '#{term_id}'
          AND enroll."STDNT_ENRL_STATUS_CODE" != 'D'
      SQL
    end

    # EDO equivalent of CampusOracle::Queries.has_instructor_history?
    def self.has_instructor_history?(ldap_uid, instructor_terms = nil)
      if instructor_terms.to_a.any?
        instructor_term_clause = "AND instr.\"term-id\" IN (#{terms_query_list instructor_terms.to_a})"
      end
      result = safe_query <<-SQL
        SELECT
          count(instr."term-id") AS course_count
        FROM
          SISEDO.ASSIGNEDINSTRUCTORV00_VW instr
        WHERE
          instr."campus-uid" = '#{ldap_uid}' AND
          rownum < 2
          #{instructor_term_clause}
      SQL
      if (result_row = result.first)
        Rails.logger.debug "Instructor #{ldap_uid} history for terms #{instructor_terms} count = #{result_row}"
        result_row['course_count'].to_i > 0
      else
        false
      end
    end

    def self.has_student_history?(ldap_uid, student_terms = nil)
      if student_terms.to_a.any?
        student_term_clause = "AND enroll.\"TERM_ID\" IN (#{terms_query_list student_terms.to_a})"
      end
      result = safe_query <<-SQL
        SELECT
          count(enroll."TERM_ID") AS enroll_count
        FROM
          SISEDO.ENROLLMENT_UIDV00_VW enroll
        WHERE
          enroll."CAMPUS_UID" = '#{ldap_uid.to_i}' AND
          rownum < 2
          #{student_term_clause}
      SQL
      if (result_row = result.first)
        Rails.logger.debug "Student #{ldap_uid} history for terms #{student_terms} count = #{result_row}"
        result_row['enroll_count'].to_i > 0
      else
        false
      end
    end

    private

    # EDO equivalent of #CampusOracle::Queries.get_course_sections
    # Changes:
    #   - 'course_cntl_num' is replaced with 'section_id'
    #   - 'term_yr' and 'term_cd' replaced by 'term_id'
    #   - See more info at #SECTION_COLUMNS
    def self.get_course_sections(term_id, department, catalog_id, only_secondary_sections)
      section_type_restriction = only_secondary_sections ? ' AND sec."primary" = \'false\' ' : ''
      safe_query <<-SQL
        SELECT
          #{SECTION_COLUMNS}
        FROM
          SISEDO.CLASSSECTIONV00_VW sec
        #{JOIN_SECTION_TO_COURSE}
        WHERE
          sec."term-id" = '#{term_id}' AND
          crs."subjectArea" = '#{department}' AND
          crs."catalogNumber-formatted" = '#{catalog_id}' AND
          sec."status-code" IN ('A','S')
          #{section_type_restriction}
        ORDER BY
          sec."component-code",
          sec."sectionNumber"
      SQL
    end

  end
end
