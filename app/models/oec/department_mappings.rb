module Oec
  class DepartmentMappings
    extend Cache::Cacheable
    include ClassLogger

    # At present (and, we hope, forever), Freshman & Sophomore Seminars is the only RegExp-based
    # "virtual department" we need to handle, so we treat it as an explicit exception.
    FSSEM_CODE = 'FSSEM'

    def initialize(opts = {})
      # Although statically stored CourseTable table rows are term-independent, the courses of a virtual
      # department query may differ from term to term.
      @term_code = opts[:term_code]
    end

    # Options are a choice of {dept_code: [dept_codes...]} or {include_in_oec: true}
    def by_dept_code(opts)
      selected = all_mappings.select do |c|
        if opts[:include_in_oec]
          c.include_in_oec
        else
          opts[:dept_code].include? c.dept_code
        end
      end
      selected.group_by { |course_code| course_code.dept_code }
    end

    def catalog_id_home_department(dept_name, catalog_id)
      specifics = catalog_id_specific_mappings
      if (row = specifics.find { |m| (m.dept_name == dept_name) && (m.catalog_id == catalog_id) })
        home_mapping = all_mappings.find {|c| c.dept_code == row.dept_code && c.catalog_id.blank?}
        home_mapping && home_mapping.dept_name
      end
    end

    def excluded_courses(dept_name, home_dept_code)
      catalog_id_specific_mappings.select do |m|
        (m.dept_name == dept_name) && (m.dept_code != home_dept_code || !m.include_in_oec)
      end
    end

    def catalog_id_specific_mappings
      all_mappings.select {|c| c.catalog_id.present?}
    end

    private

    def all_mappings
      self.class.fetch_from_cache @term_code do
        mappings = Oec::CourseCode.all
        mappings.concat create_virtural_department_mappings @term_code
      end
    end

    def create_virtural_department_mappings(term_code)
      term_id = EdoOracle::Adapters::Oec.term_id(term_code)
      fssem_root = Oec::CourseCode.where(dept_code: FSSEM_CODE, catalog_id: '').first
      fssem_courses = EdoOracle::Oec.get_fssem_course_codes(term_id)
      fssem_courses.collect do |c|
        Oec::CourseCode.new(
          dept_name: c[:dept_name], catalog_id: c[:catalog_id],
          dept_code: FSSEM_CODE, include_in_oec: fssem_root[:include_in_oec]
        )
      end
    end

  end
end
