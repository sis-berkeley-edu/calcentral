class AddOecCourseCodes < ActiveRecord::Migration
  def up
    if Oec::CourseCode.where(dept_code: 'QHINS').count == 0
      [
        'AFRICAM', '24', 'QHINS', true,
        'ANTHRO', '24', 'QHINS', true,
        'ASTRON', '84', 'QHINS', true,
        'CHM ENG', '24', 'QHINS', true,
        'CIV ENG', '24', 'QHINS', true,
        'COMPSCI', '24', 'QHINS', true,
        'COMPSCI', '39', 'QHINS', true,
        'EL ENG', '24', 'QHINS', true,
        'EL ENG', '39', 'QHINS', true,
        'EL ENG', '84', 'QHINS', true,
        'ENGLISH', '24', 'QHINS', true,
        'ENGLISH', '84', 'QHINS', true,
        'ENV SCI', '24', 'QHINS', true,
        'EPS', '24', 'QHINS', true,
        'FRENCH', '24', 'QHINS', true,
        'GLOBAL', '24', 'QHINS', true,
        'HISTORY', '24', 'QHINS', true,
        'IND ENG', '24', 'QHINS', true,
        'INTEGBI', '24', 'QHINS', true,
        'INTEGBI', '84', 'QHINS', true,
        'ITALIAN', '24', 'QHINS', true,
        'JEWISH', '24', 'QHINS', true,
        'JEWISH', '39', 'QHINS', true,
        'JOURN', '24', 'QHINS', true,
        'LEGALST', '39D', 'QHINS', true,
        'LINGUIS', '24', 'QHINS', true,
        'MATH', '24', 'QHINS', true,
        'MEC ENG', '24', 'QHINS', true,
        'MEDIAST', '24', 'QHINS', true,
        'MCELLBI', '90A', 'QHINS', true,
        'MCELLBI', '90B', 'QHINS', true,
        'MCELLBI', '90D', 'QHINS', true,
        'NAT RES', '24', 'QHINS', true,
        'NAT RES', '84', 'QHINS', true,
        'NATAMST', '90', 'QHINS', true,
        'NE STUD', '24', 'QHINS', true,
        'NUCENG', '24', 'QHINS', true,
        'NUSCTX', '24', 'QHINS', true,
        'PHYSICS', '24', 'QHINS', true,
        'PLANTBI', '24', 'QHINS', true,
        'POLECON', '24', 'QHINS', true,
        'PORTUG', '24', 'QHINS', true,
        'PSYCH', '24', 'QHINS', true,
        'RHETOR', '24', 'QHINS', true,
        'SEASIAN', '84', 'QHINS', true,
        'SPANISH', '24', 'QHINS', true,
        'THEATER', '24', 'QHINS', true,
        'THEATER', '39', 'QHINS', true,
        'VIS SCI', '24', 'QHINS', true,
        'VIS SCI', '84', 'QHINS', true
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
