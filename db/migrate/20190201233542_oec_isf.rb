class OecIsf < ActiveRecord::Migration
  def up
    if Oec::CourseCode.where(dept_code: 'ISF').count == 0
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'ISF',
          include_in_oec = 1
          WHERE dept_name = 'ISF'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'HGEAL',
          include_in_oec = 1
          WHERE dept_name = 'BUDDSTD'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          include_in_oec = 1
          WHERE dept_code in ('HGEAL')
      SQL
    end
  end

  def down
    if Oec::CourseCode.where(dept_code: 'ISF').count == 1
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'QHUIS',
          include_in_oec = 0
          WHERE dept_name = 'ISF'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'HWBUD',
          include_in_oec = 0
          WHERE dept_name = 'BUDDSTD'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          include_in_oec = 0
          WHERE dept_code in ('HGEAL')
      SQL
    end
  end
end
