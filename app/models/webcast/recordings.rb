module Webcast
  class Recordings < Proxy

    def get_json_path
      'warehouse/webcast.json'
    end

    def request_internal
      return {} unless Settings.features.videos

      recordings = {
        courses: {}
      }
      response = get_json_data['courses']
      migrated_response = handle_legacy_ccns response
      migrated_response.each do |course|
        year = course['year']
        semester = course['semester']
        ccn = course['ccn']
        if year && semester && ccn
          key = Webcast::CourseMedia.id_per_ccn(year, semester, ccn)
          recordings[:courses][key] = {
            legacy_ccn: course['legacy_ccn'],
            recordings: course['recordings'],
            youtube_playlist: course['youTubePlaylist']
          }
        elsif course['legacy_ccn']
          logger.warn "No CS Section ID found for class with recordings: #{year} #{semester} #{course['deptName']} #{course['catalogId']} CCN #{course['legacy_ccn']}"
        end
      end
      recordings
    end

    # Which "ccn" value we need to match depends on whether the application is using the CS-era DB (which is missing
    # "legacy CCNs") or the application is using bCourses sites or the legacy DB2-era DB (both of which include the
    # original section Course Control Numbers).
    # To support a match against CS-era-only data, we need to take the extra step of merging CS Section IDs
    # into the basic Recordings list.

    def handle_legacy_ccns(recordings)
      return recordings if Settings.features.allow_legacy_fallback
      legacy_terms = Hash.new {|h, k| h[k] = []}
      cs_era_courses = recordings.reject do |course|
        term_yr, term_cd = course['year'], Berkeley::TermCodes.to_code(course['semester'])
        if Berkeley::TermCodes.legacy?(term_yr, term_cd)
          legacy_terms[Berkeley::TermCodes.to_edo_id(term_yr, term_cd)] << course
        end
      end
      if legacy_terms.present?
        legacy_courses = []
        legacy_terms.each do |term_id, term_courses|
          ccns = term_courses.map {|c| c['ccn'].to_s}
          legacy_to_cs = Berkeley::LegacyTerms.legacy_ccns_to_section_ids(term_id, ccns)
          term_courses.each do |course|
            legacy_ccn = course['ccn'].to_s
            course['legacy_ccn'] = legacy_ccn
            # The CS Section ID will be nil if the section wasn't migrated.
            course['ccn'] = legacy_to_cs[legacy_ccn]
            legacy_courses << course
          end
        end
        legacy_courses + cs_era_courses
      else
        cs_era_courses
      end
    end

  end
end
