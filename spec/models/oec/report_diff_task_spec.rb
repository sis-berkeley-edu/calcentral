describe Oec::ReportDiffTask do

  let(:now) { DateTime.now }

  context 'Report diff on fake data' do
    let(:term_code) { '2014-B' }
    # Map dept_code to test-data filenames under fixtures/oec
    let(:dept_code_mappings) {
      {
        'SZANT' => 'ANTHRO',
        'FOO' => nil,
        'PSTAT' => 'STAT',
        'SPOLS' => 'POL_SCI'
      }
    }
    let (:fake_remote_drive) { double }
    subject do
      Oec::ReportDiffTask.new({
        term_code: term_code,
        dept_codes: dept_code_mappings.keys,
        date_time: now,
        local_write: true,
        allow_past_term: true
      })
    end

    before do
      allow_any_instance_of(Oec::DepartmentMappings).to receive(:by_dept_code).and_return dept_code_mappings
      allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
      allow(fake_remote_drive).to receive(:check_conflicts_and_upload)
      fake_csv_hash = {}
      modified_stat_data = File.read File.open("#{Rails.root}/fixtures/oec/modified_by_dept_STAT.json")
      Dir.glob(Rails.root.join 'fixtures', 'oec', 'courses_for_dept_*.json').each do |json|
        dept_name = json.partition('for_dept_').last.sub(/.json$/, '')
        sis_data = JSON.parse(File.read json)
        # Two entries for each dept: sis_data and modified data. In this test, only STAT data has been modified.
        dept_data = dept_name == 'STAT' ? JSON.parse(modified_stat_data) : sis_data
        fake_csv_hash[dept_name] = [sis_data, dept_data]
      end

      # Behave as if there is no previous diff report on remote drive for any of the three departments
      expect(fake_remote_drive).to receive(:spreadsheet_by_id).exactly(3).times.and_return (remote_sheet = double)
      expect(remote_sheet).to receive(:worksheets).exactly(3).times.and_return []
      expect(remote_sheet).to receive(:add_worksheet).exactly(3).times.with('Diff Report', anything, anything).and_return (fake_worksheet = double(
        max_rows: 100,
        rows: []
      ))
      expect(fake_remote_drive).to receive(:update_worksheet).exactly(3).times.with(fake_worksheet, anything)

      expect(fake_remote_drive).to receive(:find_nested).with([term_code, Oec::Folder.confirmations]).and_return (departments_folder = double)
      allow(fake_remote_drive).to receive(:find_first_matching_item).and_return mock_google_drive_item
      dept_code_mappings.each do |dept_code, dept_name|
        friendly_name = Berkeley::Departments.get(dept_code, concise: true)
        imports_path = [term_code, Oec::Folder.sis_imports, now.strftime('%F %H:%M:%S'), friendly_name]
        if dept_name.nil?
          expect(fake_remote_drive).to receive(:find_nested).with(imports_path, anything).and_return nil
        else
          courses_path = [term_code, Oec::Folder.confirmations, friendly_name]
          sheet_classes = [Oec::SisImportSheet, Oec::CourseConfirmation]
          [ imports_path, courses_path ].each_with_index do |path, index|
            expect(fake_remote_drive).to receive(:find_nested).with(path, anything).and_return (remote_file = double)
            expect(fake_remote_drive).to receive(:export_csv).with(remote_file).and_return (import_csv = double)
            spreadsheet = fake_csv_hash[dept_name][index]
            allow(sheet_classes[index]).to receive(:from_csv).with(import_csv, dept_code: dept_code).and_return spreadsheet
          end
        end
      end
    end

    it 'should log errors' do
      subject.run
      expect(subject.errors).to have(1).item
      expect(subject.errors['PSTAT']).to have(2).item
      expect(subject.errors['PSTAT']['87672'].keys).to match_array ['Invalid EVALUATION_TYPE: X']
      expect(subject.errors['PSTAT']['99999'].keys).to match_array ['Invalid annotation: wrong', 'Invalid ldap_uid: bad_data']
    end

    context 'discrepancies in STAT department' do
      let(:diff_rows_by_dept) do
        {}.tap do |dept_hash|
          original_update_departmental_diff = subject.method(:update_departmental_diff)
          allow(subject).to receive(:update_departmental_diff) do |diff_rows, dept_code|
            dept_hash[dept_code] = diff_rows
            original_update_departmental_diff.call(diff_rows, dept_code)
          end
          subject.run
        end
      end

      it 'should omit nonexistent departments' do
        expect(diff_rows_by_dept['FOO']).to be_nil
      end

      it 'should include diff for STAT department only' do
        expect(diff_rows_by_dept['SZANT']).to have(0).items
        expect(diff_rows_by_dept['SPOLS']).to have(0).items
        expect(diff_rows_by_dept['PSTAT']).to have(14).items
      end

      it 'should note rows missing from the department confirmation sheet' do
        expect(diff_rows_by_dept['PSTAT']['2015-B-87690-12345678'].to_hash).to include({
          'REASON' => 'Not in DCS',
          'COURSE_NAME' => nil,
          'sis:COURSE_NAME' => 'STAT C236A LEC 001 STATS SOCI SCI',
          'EMAIL_ADDRESS' => nil,
          'sis:EMAIL_ADDRESS' => 'stat_supervisor@berkeley.edu'
        })
      end

      it 'should note rows missing from the SIS import sheet' do
        expect(diff_rows_by_dept['PSTAT']['2015-B-11111'].to_hash).to include({
          'REASON' => 'Not in SIS',
          'COURSE_NAME' => 'Added by dept',
          'sis:COURSE_NAME' => nil,
          'EMAIL_ADDRESS' => 'trump@berkeley.edu',
          'sis:EMAIL_ADDRESS' => nil
        })
      end

      it 'should highlight differing course name and ignore other columns' do
        expect(diff_rows_by_dept['PSTAT']['2015-B-87672-10316-COURSE_NAME'].to_hash).to include({
          'REASON' => 'COURSE_NAME',
          'COURSE_NAME' => 'different_course_name',
          'sis:COURSE_NAME' => 'STAT C205A LEC 001 PROB THEORY',
          'EMAIL_ADDRESS' => nil,
          'sis:EMAIL_ADDRESS' => nil
        })
      end

      it 'should highlight differing email address and include course name for identification' do
        expect(diff_rows_by_dept['PSTAT']['2015-B-87672-10316-EMAIL_ADDRESS'].to_hash).to include({
          'COURSE_NAME' => 'different_course_name',
          'sis:COURSE_NAME' => 'STAT C205A LEC 001 PROB THEORY',
          'REASON' => 'EMAIL_ADDRESS',
          'EMAIL_ADDRESS' => 'different_email_address@berkeley.edu',
          'sis:EMAIL_ADDRESS' => 'blanco@berkeley.edu'
        })
      end
    end
  end
end
