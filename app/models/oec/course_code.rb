module Oec
  class CourseCode < ApplicationRecord

    self.table_name = 'oec_course_codes'
    attr_accessible :dept_name, :catalog_id, :dept_code, :include_in_oec

    def to_h
      Hash[[:dept_name, :catalog_id, :dept_code, :include_in_oec].collect {|m| [m, send(m)]}]
    end

    def self.participating_dept_codes
      self.where(include_in_oec: true).select(:dept_code).distinct.collect {|r| r[:dept_code]}
    end

  end
end
