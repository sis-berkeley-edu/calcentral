module Oec
  class DepartmentMappings
    extend Cache::Cacheable
    include ClassLogger

    def initialize(opts = {})
      @term_code = opts[:term_code]
    end

    # Options are a choice of {dept_code: [dept_codes...]} or {include_in_oec: true}
    def by_dept_code(opts)
      Oec::CourseCode.where(opts).group_by { |course_code| course_code.dept_code }
    end

    # Only used for SisImportTask.set_dept_form. Needs to be FSSem aware.
    def catalog_id_home_department(dept_name, catalog_id)
      if (row = catalog_id_specific_mappings.find { |m| (m.dept_name == dept_name) && (m.catalog_id == catalog_id) })
        Oec::CourseCode.where(dept_code: row.dept_code, catalog_id: '').pluck(:dept_name).first
      end
    end

    # Only used in the EdoOracle::Oec.depts_clause method. Needs to be FSSem aware.
    def excluded_courses(dept_name, home_dept_code)
      catalog_id_specific_mappings.select do |m|
        (m.dept_name == dept_name) && (m.dept_code != home_dept_code || !m.include_in_oec)
      end
    end

    # Needs to be FSSem aware.
    def catalog_id_specific_mappings
      # Although statically stored CourseTable table rows are term-independent, the courses of a VirtualDepartment
      # may differ from term to term.
      self.class.fetch_from_cache @term_code do
        Oec::CourseCode.where.not(catalog_id: '').to_a
      end
    end

  end
end
