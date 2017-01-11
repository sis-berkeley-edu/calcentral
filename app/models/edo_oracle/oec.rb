module EdoOracle
  class Oec < Connection
    include ActiveRecordHelper

    def self.get_courses(term_id, filter_clause)
      safe_query <<-SQL
      SELECT DISTINCT
        sec."id" AS section_id,
        sec."primary" AS primary,
        sec."component-code" AS instruction_format,
        sec."sectionNumber" AS section_num,
        sec."displayName" AS course_display_name,
        instr."campus-uid" AS ldap_uid,
        instr."instructor-id" AS sis_id,
        TRIM(instr."givenName") AS first_name,
        TRIM(instr."familyName") AS last_name,
        instr."role-code" AS role_code,
        instr."emailAddress" AS email_address,
        mtg."startDate" AS start_date,
        mtg."endDate" AS end_date,
        TRIM(crs."transcriptTitle") AS course_title_short,
        sec."enrolledCount" AS enrollment_count,
        (
          SELECT listagg("AFFILIATION_TYPE_CODE", ',') WITHIN GROUP (ORDER BY "AFFILIATION_TYPE_CODE")
          FROM SISEDO.PERSON_AFFILIATIONV00_VW aff
          WHERE
            aff."PERSON_KEY" = instr."instructor-id" AND
            aff."AFFILIATION_STATUS_CODE" = 'ACT' AND
            aff."AFFILIATION_TYPE_CODE" IN ('INSTRUCTOR', 'STUDENT')
        ) AS affiliations,
        (
          SELECT LISTAGG("id", ',') WITHIN GROUP (ORDER BY "id")
          FROM SISEDO.CLASSSECTIONV00_VW sec2
          WHERE
            sec."cs-course-id" = sec2."cs-course-id" AND
            sec."term-id" = sec2."term-id" AND
            sec."session-id" = sec2."session-id" AND
            sec."sectionNumber" = sec2."sectionNumber"
        ) AS cross_listed_ccns,
        CASE mtg."location-code"
          WHEN 'INTR' THEN NULL ELSE (
          SELECT listagg("id", ',') WITHIN GROUP (ORDER BY "id")
          FROM SISEDO.MEETINGV00_VW mtg2 JOIN SISEDO.CLASSSECTIONV00_VW sec3 ON (
            mtg2."location-code" = mtg."location-code" AND
            mtg2."meetsDays" = mtg."meetsDays" AND
            mtg2."startTime" = mtg."startTime" AND
            mtg2."endTime" = mtg."endTime" AND
            mtg2."startDate" = mtg."startDate" AND
            mtg2."endDate" = mtg."endDate" AND
            mtg2."cs-course-id" = sec3."cs-course-id" AND
            mtg2."term-id" = sec3."term-id" AND
            mtg2."session-id" = sec3."session-id" AND
            mtg2."offeringNumber" = sec3."offeringNumber" AND
            mtg2."sectionNumber" = sec3."sectionNumber")
          )
        END AS co_scheduled_ccns,
        (
          SELECT listagg("primaryAssociatedSectionId", ',') WITHIN GROUP (ORDER BY "primaryAssociatedSectionId")
          FROM SISEDO.CLASSSECTIONV00_VW sec4
          WHERE
            sec."id" = sec4."id" AND
            sec4."term-id" = '#{term_id}'
        ) AS associated_primary
      FROM
        SISEDO.CLASSSECTIONV00_VW sec
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
        LEFT OUTER JOIN SISEDO.DISPLAYNAMEXLAT_MVW xlat ON (
          xlat."classDisplayName" = sec."displayName")
        LEFT OUTER JOIN SISEDO.API_COURSEV00_VW crs ON (
          xlat."courseDisplayName" = crs."displayName"
          AND crs."status-code" = 'ACTIVE')
        WHERE
          sec."term-id" = '#{term_id}'
          AND #{filter_clause}
          AND sec."status-code" IN ('A','S')
      SQL
    end

    # See http://www.oracle.com/technetwork/issue-archive/2006/06-sep/o56asktom-086197.html for explanation of
    # query batching with ROWNUM.
    def self.get_batch_enrollments(term_id, batch_number, batch_size)
      mininum_row_exclusive = (batch_number * batch_size)
      maximum_row_inclusive = mininum_row_exclusive + batch_size
      sql = <<-SQL
        SELECT * FROM (
          SELECT /*+ FIRST_ROWS(n) */ enrollments.*, ROWNUM rnum FROM (
            SELECT DISTINCT
              enroll."CLASS_SECTION_ID" as section_id,
              enroll."CAMPUS_UID" AS ldap_uid,
              enroll."STUDENT_ID" AS sis_id,
              TRIM(name."NAME_GIVENNAME" || ' ' || name."NAME_MIDDLENAME") AS first_name,
              name."NAME_FAMILYNAME" AS last_name,
              email."EMAIL_EMAILADDRESS" AS email_address
            FROM SISEDO.ENROLLMENTV00_VW enroll
            LEFT OUTER JOIN SISEDO.PERSON_EMAILV00_VW email ON (
              email."PERSON_KEY" = enroll."STUDENT_ID" AND
              email."EMAIL_TYPE_CODE" = 'CAMP')
            LEFT OUTER JOIN SISEDO.PERSON_NAMEV00_VW name ON (
              name."PERSON_KEY" = enroll."STUDENT_ID" AND
              name."NAME_TYPE_CODE" = 'PRF')
            WHERE
              enroll."TERM_ID" = '#{term_id}'
              AND (enroll."STDNT_ENRL_STATUS_CODE" = 'E')
            ORDER BY section_id, sis_id
          ) enrollments
          WHERE ROWNUM <= #{maximum_row_inclusive}
        )
        WHERE rnum > #{mininum_row_exclusive}
      SQL
      # Result sets are too large for bulk stringification.
      safe_query(sql, do_not_stringify: true)
    end

    # Awkward substring matches on sec."displayName" are necessary because the better-parsed dept_name and catalog_id
    # fields are derived from a join and not guaranteed to be present.
    def self.depts_clause(course_codes, import_all)
      return if course_codes.blank?
      subclauses = course_codes.group_by(&:dept_name).map do |dept_name, codes|
        subclause = ''
        if (default_code = codes.find { |code| code.catalog_id.blank? }) && (default_code.include_in_oec || import_all)
          #All catalog IDs are included by default; note explicit exclusions
          excluded_catalog_ids = codes.reject(&:include_in_oec).map(&:catalog_id)
          subclause << "sec.\"displayName\" LIKE '#{SubjectAreas.compress dept_name} %'"
          if !import_all && excluded_catalog_ids.any?
            excluded_catalog_ids.each do |id|
              subclause << " and sec.\"displayName\" NOT LIKE '%#{id}')"
            end
          end
        else
          #No catalog IDs are included by default; note explicit inclusions
          included_catalog_ids = codes.select(&:include_in_oec).map(&:catalog_id)
          if included_catalog_ids.any?
            subclause << "sec.\"displayName\" LIKE '#{SubjectAreas.compress dept_name} %' and ("
            subclause << included_catalog_ids.map { |id| "sec.\"displayName\" LIKE '%#{id}'" }.join(' or ')
            subclause << ')'
          end
        end
        subclause
      end
      subclauses.reject! &:blank?
      case subclauses.count
        when 0
          nil
        when 1
          "(#{subclauses.first})"
        else
          "(#{subclauses.map { |subclause| "(#{subclause})" }.join(' or ')})"
      end
    end

    def self.course_ccn_column
      'sec."id"'
    end

    def self.enrollment_ccn_column
      'enroll."CLASS_SECTION_ID"'
    end

  end
end

