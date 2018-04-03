class OecAddCalteach < ActiveRecord::Migration
  def up
    if Oec::CourseCode.where(dept_code: 'CALTEACH').count == 0
      [
        'EDUC', '130', 'CALTEACH', true,
        'EDUC', '131AC', 'CALTEACH', true,
        'HISTORY', '138T', 'CALTEACH', true,
        'HISTORY', '180T', 'CALTEACH', true,
        'HISTORY', '182AT', 'CALTEACH', true,
        'UGIS', '187', 'CALTEACH', true,
        'UGIS', '188', 'CALTEACH', true,
        'UGIS', '303', 'CALTEACH', true,
        'UGIS', '82', 'CALTEACH', true
      ].each_slice(4) do |dept_name, catalog_id, dept_code, include_in_oec|
        Oec::CourseCode.create(
          dept_name: dept_name,
          catalog_id: catalog_id,
          dept_code: dept_code,
          include_in_oec: include_in_oec
        )
      end
    end
  end

  def down
    # Downgrades should be managed through ccadmin.
  end
end
