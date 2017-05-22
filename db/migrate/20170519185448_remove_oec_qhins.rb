class RemoveOecQhins < ActiveRecord::Migration
  def up
    if Oec::CourseCode.where(dept_code: 'FSSEM').count == 0
      Oec::CourseCode.create(
        dept_name: 'FSSEM',
        catalog_id: '',
        dept_code: 'FSSEM',
        include_in_oec: true
      )
    end
    Oec::CourseCode.destroy_all(dept_code: 'QHINS')
  end

  def down
    # Downgrades should be managed through ccadmin.
    puts "No action will be taken. Downgrades should be managed manually."
  end
end
