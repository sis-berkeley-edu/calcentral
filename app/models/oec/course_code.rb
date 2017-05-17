module Oec
  class CourseCode < ActiveRecord::Base

    self.table_name = 'oec_course_codes'
    attr_accessible :dept_name, :catalog_id, :dept_code, :include_in_oec

    def to_h
      Hash[[:dept_name, :catalog_id, :dept_code, :include_in_oec].collect {|m| [m, send(m)]}]
    end

    def self.participating_dept_codes
      self.where(include_in_oec: true).select(:dept_code).distinct.collect {|r| r[:dept_code]}
    end

    # Only used for cross-listings sort.
    def self.dept_names_for_code(dept_code)
      self.where(dept_code: dept_code).pluck(:dept_name)
    end

    # Only used for cross-listings inclusion.
    def self.included?(dept_name, catalog_id)
      find_by(dept_name: dept_name, catalog_id: catalog_id, include_in_oec: true) || find_by(dept_name: dept_name, catalog_id: '', include_in_oec: true)
    end

    # Only used for cross-listings sort.
    def self.participating_dept_names
      self.where(include_in_oec: true).pluck(:dept_name).uniq
    end

  end
end
