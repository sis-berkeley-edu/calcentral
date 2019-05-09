class OecCelticPlus < ActiveRecord::Migration
  def up
    if Oec::CourseCode.where(dept_code: 'CELTIC').count == 0
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'CELTIC',
          include_in_oec = TRUE
          WHERE dept_name = 'CELTIC'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'MEDIAST',
          include_in_oec = TRUE
          WHERE dept_name = 'MEDIAST'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          include_in_oec = TRUE
          WHERE dept_code in ('HITAL', 'HSCAN', 'LTSLL', 'SHIST')
      SQL
    end
  end

  def down
    if Oec::CourseCode.where(dept_code: 'CELTIC').count == 1
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'HSCAN',
          include_in_oec = FALSE
          WHERE dept_name = 'CELTIC'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          dept_code = 'QHUIS',
          include_in_oec = FALSE
          WHERE dept_name = 'MEDIAST'
      SQL
      update <<-SQL
        UPDATE oec_course_codes SET
          include_in_oec = FALSE
          WHERE dept_code in ('HITAL', 'HSCAN', 'LTSLL', 'SHIST')
      SQL
    end
  end
end
