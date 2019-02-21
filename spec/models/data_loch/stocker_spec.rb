describe DataLoch::Stocker do
  let(:term_code) { '2182' }

  it 'generates an agreeable daily path' do
    subpath = subject.get_daily_path
    expect(subpath).to eq 'daily/8e8847c1bdf012037ee13bb62da8a5c1-2013-10-10'
  end

  def unzipped(basename)
    zipped = "tmp/data_loch/#{basename}.gz"
    Zlib::GzipReader.new(open(zipped)).read.split("\n")
  end

  context 'SIS terms job' do
    let(:courses_edo_oracle_columns) do
      %w(section_id term_id print_in_schedule_of_classes primary instruction_format section_num course_display_name
         enrollment_count instructor_uid instructor_name instructor_role_code location
         meeting_days meeting_start_time meeting_end_time meeting_start_date meeting_end_date)
    end
    let(:courses_edo_oracle_rows) do
      [
        ['65536', 2182, 'Y', true, 'LEC', '001', 'SCANDIN 60', 40.0, 234567, 'Snorri Sturluson', 'PI', 'Dwinelle 109', 'MOWEFR', '13:00', '13:59', '2018-01-16 00:00:00 UTC', '2018-05-04 00:00:00 UTC', 'Battling with Blubber'],
        ['65537', 2182, 'Y', true, 'LEC', '001', 'SLAVIC 46', 13.0, 345678, 'Vladimir Propp', 'PI', 'Dwinelle 242', 'MOWEFR', '10:00', '10:59', '2018-01-16 00:00:00 UTC', '2018-05-04 00:00:00 UTC', 'The Gogolian Slap']
      ]
    end
    let(:enrollments_edo_oracle_columns) do
      %w(section_id term_id ldap_uid sis_id enrollment_status waitlist_position units grade grade_points grading_basis grade_midterm)
    end
    let(:enrollments_edo_oracle_rows) do
      [
        ['65536', 2182, 1234567, 87654321, 'E', nil, 4.0, 'A-', 14.8, 'GRD', nil],
        ['65536', 2182, 1234568, 87654322, 'E', nil, 4.0, 'B+', 13.2, 'GRD', 'D'],
        ['65537', 2182, 1234567, 87654321, 'E', nil, 3.0, ' ', 0.0, 'PNP', nil],
        ['65537', 2182, 1234568, 87654322, 'W', 7, 3.0, ' ', 0.0, 'PNP', nil]
      ]
    end

    shared_examples 'writes zipped term data' do
      it 'writes zipped course and enrollment results' do
        expect(EdoOracle::Bulk).to receive(:get_courses).with(term_code).and_return double(
          columns: courses_edo_oracle_columns,
          rows: courses_edo_oracle_rows
        )
        expect(EdoOracle::Bulk).to receive(:get_batch_enrollments).with(term_code, 0, DataLoch::Zipper::BATCH_SIZE).and_return double(
          columns: enrollments_edo_oracle_columns,
          rows: enrollments_edo_oracle_rows
        )
        expect(DataLoch::S3).to receive(:new).and_return (mock_s3 = double)
        expect(mock_s3).to receive(:upload).with("#{s3_subfolder}/courses", 'tmp/data_loch/courses-2182.gz').ordered.and_return true
        expect(mock_s3).to receive(:upload).with("#{s3_subfolder}/enrollments", 'tmp/data_loch/enrollments-2182.gz').ordered.and_return true
        expect(subject).to receive(:clean_tmp_files).with(['tmp/data_loch/courses-2182.gz', 'tmp/data_loch/enrollments-2182.gz'])

        subject.upload_term_data([term_code], ['s3_test'], is_historical)
        csv_rows = unzipped("courses-#{term_code}")
        expect(csv_rows).to have(2).items
        expect(csv_rows[0]).to eq '65536,2182,Y,true,LEC,001,SCANDIN 60,40.0,234567,Snorri Sturluson,PI,Dwinelle 109,MOWEFR,13:00,13:59,2018-01-16 00:00:00 UTC,2018-05-04 00:00:00 UTC,Battling with Blubber'
        expect(csv_rows[1]).to eq '65537,2182,Y,true,LEC,001,SLAVIC 46,13.0,345678,Vladimir Propp,PI,Dwinelle 242,MOWEFR,10:00,10:59,2018-01-16 00:00:00 UTC,2018-05-04 00:00:00 UTC,The Gogolian Slap'
        csv_rows = unzipped("enrollments-#{term_code}")
        expect(csv_rows).to have(4).items
        expect(csv_rows[0]).to eq '65536,2182,1234567,87654321,E,,4.0,A-,14.8,GRD,'
        expect(csv_rows[1]).to eq '65536,2182,1234568,87654322,E,,4.0,B+,13.2,GRD,D'
        expect(csv_rows[2]).to eq '65537,2182,1234567,87654321,E,,3.0, ,0.0,PNP,'
        expect(csv_rows[3]).to eq '65537,2182,1234568,87654322,W,7,3.0, ,0.0,PNP,'
      end
    end

    context 'historical' do
      let(:is_historical) {true}
      let(:s3_subfolder) {'historical'}
      include_examples 'writes zipped term data'
    end

    context 'daily' do
      let(:is_historical) {false}
      let(:s3_subfolder) {'daily/8e8847c1bdf012037ee13bb62da8a5c1-2013-10-10'}
      include_examples 'writes zipped term data'
    end
  end

  context 'EDW advisee data' do
    let(:advisee_sids) do
      %w(87654321 87654322)
    end
    let(:socio_econ_columns) do
      %w(sid, lcff, first_gen, socio_econ, parent_income)
    end
    let(:socio_econ_rows) do
      [
        ['87654321', false, true, nil, nil],
        ['87654322', true, false, true, 150]
      ]
    end
    it 'writes social-economic results' do
      expect(EdwOracle::Queries).to receive(:get_socio_econ).with(advisee_sids).and_return double(
        columns: socio_econ_columns,
        rows: socio_econ_rows
      )
      expect(DataLoch::S3).to receive(:new).and_return (mock_s3 = double)
      expect(mock_s3).to receive(:load_advisee_sids).and_return advisee_sids
      expect(mock_s3).to receive(:upload).with('advisees/socio_econ', 'tmp/data_loch/socio_econ.gz').and_return true
      expect(subject).to receive(:clean_tmp_files).with(['tmp/data_loch/socio_econ.gz'])

      subject.upload_advisee_data(['s3_test'], ['socio_econ'])
      csv_rows = unzipped("socio_econ")
      expect(csv_rows).to have(2).items
      expect(csv_rows[0]).to eq '87654321,false,true,,'
      expect(csv_rows[1]).to eq '87654322,true,false,true,150'
    end
  end

end
