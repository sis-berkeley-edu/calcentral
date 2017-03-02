module CanvasLti
  module SisAdapter
    extend EdoOracle::Adapters::Common
    extend self

    def get_enrolled_students(section_id, term_year, term_code)
      if Berkeley::Terms.legacy?(term_year, term_code) && Settings.features.allow_legacy_fallback
        CampusOracle::Queries.get_enrolled_students(section_id, term_year, term_code)
      else
        EdoOracle::Queries.get_enrolled_students(section_id, term_id(term_year, term_code)).each do |enrollment|
          adapt_pnp_flag enrollment
        end
      end
    end

    def get_section_instructors(section_id, term_year, term_code)
      if Berkeley::Terms.legacy?(term_year, term_code) && Settings.features.allow_legacy_fallback
        CampusOracle::Queries.get_section_instructors(term_year, term_code, section_id)
      else
        EdoOracle::Queries.get_section_instructors(term_id(term_year, term_code), section_id).each do |instructor|
          adapt_instructor_func instructor
        end
      end
    end

    def get_sections_by_ids(section_ids, term_year, term_code)
      if Berkeley::Terms.legacy?(term_year, term_code) && Settings.features.allow_legacy_fallback
        CampusOracle::Queries.get_sections_from_ccns(term_year, term_code, section_ids)
      else
        user_courses = EdoOracle::UserCourses::Base.new
        EdoOracle::Queries.get_sections_by_ids(term_id(term_year, term_code), section_ids).each do |section|
          adapt_course_cntl_num section
          adapt_dept_name_and_catalog_id(section, user_courses)
          adapt_primary_secondary_cd section
          adapt_term section
        end
      end
    end

  end
end
