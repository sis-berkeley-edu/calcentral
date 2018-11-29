module EdoOracle
  class Bulk < Connection
    include ActiveRecordHelper

    # See http://www.oracle.com/technetwork/issue-archive/2006/06-sep/o56asktom-086197.html for explanation of
    # query batching with ROWNUM.
    def self.get_batch_enrollments(term_id, batch_number, batch_size)
      mininum_row_exclusive = (batch_number * batch_size)
      maximum_row_inclusive = mininum_row_exclusive + batch_size
      sql = <<-SQL
        SELECT section_id, term_id, ldap_uid, sis_id, enrollment_status, waitlist_position, units,
               grade, grade_points, grading_basis FROM (
          SELECT /*+ FIRST_ROWS(n) */ enrollments.*, ROWNUM rnum FROM (
            SELECT DISTINCT
              enroll."CLASS_SECTION_ID" as section_id,
              enroll."TERM_ID" as term_id,
              enroll."CAMPUS_UID" AS ldap_uid,
              enroll."STUDENT_ID" AS sis_id,
              enroll."STDNT_ENRL_STATUS_CODE" AS enrollment_status,
              enroll."WAITLISTPOSITION" AS waitlist_position,
              enroll."UNITS_TAKEN" AS units,
              enroll."GRADE_MARK" AS grade,
              enroll."GRADE_POINTS" AS grade_points,
              enroll."GRADING_BASIS_CODE" AS grading_basis,
              enroll."GRADE_MARK_MID" as grade_midterm
            FROM SISEDO.ETS_ENROLLMENTV00_VW enroll
            WHERE
              enroll."TERM_ID" = '#{term_id}'
            ORDER BY section_id, sis_id
          ) enrollments
          WHERE ROWNUM <= #{maximum_row_inclusive}
        )
        WHERE rnum > #{mininum_row_exclusive}
      SQL
      # Result sets are too large for bulk stringification.
      safe_query(sql, do_not_stringify: true)
    end

    def self.get_courses(term_id)
      sql = <<-SQL
        SELECT DISTINCT
          sec."id" AS section_id,
          sec."term-id" AS term_id,
          sec."printInScheduleOfClasses" AS print_in_schedule_of_classes,
          sec."primary" AS primary,
          sec."component-code" AS instruction_format,
          sec."sectionNumber" AS section_num,
          crs."displayName" AS course_display_name,
          sec."enrolledCount" AS enrollment_count,
          instr."campus-uid" AS instructor_uid,
          TRIM(instr."formattedName") AS instructor_name,
          instr."role-code" AS instructor_role_code,
          mtg."location-descr" AS location,
          mtg."meetsDays" AS meeting_days,
          mtg."startTime" AS meeting_start_time,
          mtg."endTime" AS meeting_end_time,
          mtg."startDate" AS meeting_start_date,
          mtg."endDate" AS meeting_end_date,
          TRIM(crs."title") AS course_title,
          cls."allowedUnitsMaximum" AS allowed_units
        FROM
          SISEDO.CLASSSECTIONALLV01_MVW sec
        LEFT OUTER JOIN SISEDO.DISPLAYNAMEXLATV01_MVW xlat ON (xlat."classDisplayName" = sec."displayName")
        LEFT OUTER JOIN SISEDO.API_COURSEV01_MVW crs ON (xlat."courseDisplayName" = crs."displayName")
        LEFT OUTER JOIN SISEDO.CLASSV00_VW cls ON (
          cls."term-id" = sec."term-id" AND
          cls."sectionId" = sec."id")
        LEFT OUTER JOIN SISEDO.MEETINGV00_VW mtg ON (
          mtg."cs-course-id" = sec."cs-course-id" AND
          mtg."term-id" = sec."term-id" AND
          mtg."session-id" = sec."session-id" AND
          mtg."offeringNumber" = sec."offeringNumber" AND
          mtg."sectionNumber" = sec."sectionNumber")
        LEFT OUTER JOIN SISEDO.ASSIGNEDINSTRUCTORV00_VW instr ON (
          instr."cs-course-id" = sec."cs-course-id" AND
          instr."term-id" = sec."term-id" AND
          instr."session-id" = sec."session-id" AND
          instr."offeringNumber" = sec."offeringNumber" AND
          instr."number" = sec."sectionNumber")
        WHERE
          sec."term-id" = '#{term_id}'
          AND sec."status-code" IN ('A','S')
          AND crs."updatedDate" = (
            SELECT MAX(crs2."updatedDate")
            FROM SISEDO.API_COURSEV01_MVW crs2, SISEDO.EXTENDED_TERM_MVW term2
            WHERE crs2."cms-version-independent-id" = crs."cms-version-independent-id"
            AND crs2."displayName" = crs."displayName"
            AND term2.ACAD_CAREER = 'UGRD'
            AND term2.STRM = sec."term-id"
            AND (
              (
                CAST(crs2."fromDate" AS DATE) <= term2.TERM_END_DT AND
                CAST(crs2."toDate" AS DATE) >= term2.TERM_END_DT
              )
              OR CAST(crs2."updatedDate" AS DATE) = TO_DATE('1901-01-01', 'YYYY-MM-DD')
            )
          )
      SQL
      # Result sets are too large for bulk stringification.
      safe_query(sql, do_not_stringify: true)
    end

  end
end
