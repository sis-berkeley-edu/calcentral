describe DataLoch::Zipper do
  let(:term_code) { '2182' }

  context 'courses query' do
    let(:edo_oracle_columns) do
      %w(section_id term_id print_in_schedule_of_classes primary instruction_format section_num course_display_name
         enrollment_count instructor_uid instructor_name instructor_role_code location
         meeting_days meeting_start_time meeting_end_time meeting_start_date meeting_end_date)
    end

    let(:edo_oracle_rows) do
      [
        [
          '65536',
          2182,
          'Y',
          true,
          'LEC',
          '001',
          'SCANDIN 60',
          40.0,
          234567,
          'Snorri Sturluson',
          'PI',
          'Dwinelle 109',
          'MOWEFR',
          '13:00',
          '13:59',
          '2018-01-16 00:00:00 UTC',
          '2018-05-04 00:00:00 UTC'
        ],
        [
          '65537',
          2182,
          'Y',
          true,
          'LEC',
          '001',
          'SLAVIC 46',
          13.0,
          345678,
          'Vladimir Propp',
          'PI',
          'Dwinelle 242',
          'MOWEFR',
          '10:00',
          '10:59',
          '2018-01-16 00:00:00 UTC',
          '2018-05-04 00:00:00 UTC'
        ]
      ]
    end

    before do
      allow(EdoOracle::Bulk).to receive(:get_courses).with(term_code).and_return double(
        columns: edo_oracle_columns,
        rows: edo_oracle_rows
      )
    end

    let(:zipped) { described_class.zip_courses(term_code) }
    let(:csv_rows) { Zlib::GzipReader.new(open(zipped)).read.split("\n") }

    it 'writes zipped course results to the filesystem' do
      expect(csv_rows).to have(2).items
      expect(csv_rows[0]).to eq '65536,2182,Y,true,LEC,001,SCANDIN 60,40.0,234567,Snorri Sturluson,PI,Dwinelle 109,MOWEFR,13:00,13:59,2018-01-16 00:00:00 UTC,2018-05-04 00:00:00 UTC'
      expect(csv_rows[1]).to eq '65537,2182,Y,true,LEC,001,SLAVIC 46,13.0,345678,Vladimir Propp,PI,Dwinelle 242,MOWEFR,10:00,10:59,2018-01-16 00:00:00 UTC,2018-05-04 00:00:00 UTC'
    end
  end

  context 'enrollments query' do
    let(:edo_oracle_columns) do
      %w(section_id term_id ldap_uid sis_id enrollment_status waitlist_position units grade grade_points grading_basis)
    end

    let(:edo_oracle_rows) do
      [
        ['65536', 2182, 1234567, 87654321, 'E', nil, 4.0, 'A-', 14.8, 'GRD'],
        ['65536', 2182, 1234568, 87654322, 'E', nil, 4.0, 'B+', 13.2, 'GRD'],
        ['65537', 2182, 1234567, 87654321, 'E', nil, 3.0, ' ', 0.0, 'PNP'],
        ['65537', 2182, 1234568, 87654322, 'W', 7, 3.0, ' ', 0.0, 'PNP']
      ]
    end

    before do
      allow(EdoOracle::Bulk).to receive(:get_batch_enrollments).with(term_code, 0, DataLoch::Zipper::BATCH_SIZE).and_return double(
        columns: edo_oracle_columns,
        rows: edo_oracle_rows
      )
    end

    let(:zipped) { described_class.zip_enrollments(term_code) }
    let(:csv_rows) { Zlib::GzipReader.new(open(zipped)).read.split("\n") }

    it 'writes zipped enrollment results to the filesystem' do
      expect(csv_rows).to have(4).items
      expect(csv_rows[0]).to eq '65536,2182,1234567,87654321,E,,4.0,A-,14.8,GRD'
      expect(csv_rows[1]).to eq '65536,2182,1234568,87654322,E,,4.0,B+,13.2,GRD'
      expect(csv_rows[2]).to eq '65537,2182,1234567,87654321,E,,3.0, ,0.0,PNP'
      expect(csv_rows[3]).to eq '65537,2182,1234568,87654322,W,7,3.0, ,0.0,PNP'
    end
  end
end
