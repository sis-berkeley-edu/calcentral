describe CanvasCsv::Base do

  let(:user_ids)  { ['1234','1235'] }

  describe '#accumulate_user_data' do
    context 'when all users known' do
      before do
        people_attributes = [
          { ldap_uid: '1234', first_name: 'John', last_name: 'Smith', email_address: 'johnsmith@example.com', student_id: nil, roles: {faculty: true} },
          { ldap_uid: '1235', first_name: 'Jane', last_name: 'Smith', email_address: 'janesmith@example.com', student_id: nil, roles: {faculty: true} },
        ]
        expect(User::BasicAttributes).to receive(:attributes_for_uids).with(['1234','1235']).and_return people_attributes
      end

      it 'should assemble array with user attribute hashes' do
        result = subject.accumulate_user_data user_ids
        expect(result.count).to eq 2
        expect(result[0]['user_id']).to eq 'UID:1234'
        expect(result[0]['login_id']).to eq '1234'
        expect(result[0]['first_name']).to eq 'John'
        expect(result[0]['last_name']).to eq 'Smith'
        expect(result[0]['email']).to eq 'johnsmith@example.com'
        expect(result[0]['status']).to eq 'active'
      end

      it 'should not remove the contents of the user_ids argument' do
        result = subject.accumulate_user_data user_ids
        expect(result).to be_a Array
        expect(user_ids).to be_a Array
        expect(user_ids.count).to eq 2
      end
    end

    context 'when querying many user records from the DB' do
      before do
        allow(CalnetLdap::UserAttributes).to receive(:get_bulk_attributes).and_return []
      end
      it 'should find all available ones' do
        known_first = ['238382', '2040']
        known_last = ['3060', '211159', '238382']
        user_data = subject.accumulate_user_data(known_first + (1..1000).to_a + known_last)
        known_users = user_data.select do |row|
          known_first.include?(row['login_id']) || known_last.include?(row['login_id'])
        end
        expect(known_users).to have(known_first.length + known_last.length).items
      end
    end
  end

  describe '#csv_count' do
    let(:csv_filepath) { 'tmp/csv_count_test.csv' }
    let(:csv_rows) do
      [
        ['45','John Smith','johnsmith@example.com'],
        ['46','Jane Smith','janesmith@example.com'],
        ['63','Robin Williams','rwilliams@example.com'],
      ]
    end
    let(:csv_file) { subject.make_csv(csv_filepath, 'id,full_name,email_address', csv_rows) }
    after { delete_files_if_exists([csv_filepath]) }
    it 'returns number of records in csv file' do
      expect(subject.csv_count csv_file).to eq 3
    end
  end

  describe '#get_csv' do
    subject {Canvas::Report::Users.new(fake: true, download_to_file: download_filename)}
    context 'without an intermediate save to the file system' do
      let(:download_filename) { nil }
      it 'returns parsed CSV' do
        result = subject.get_csv
        expect(result.length).to eq 3
        expect(result.first['first_name']).to eq 'Ray'
      end
    end
    context 'downloading to the file system' do
      let(:download_filename) { "tmp/test_report_download_#{DateTime.now.strftime('%Y%m%dT%H%M%S')}.csv" }
      after { delete_files_if_exists([download_filename]) }
      it 'returns the file name' do
        result = subject.get_csv
        expect(result).to eq download_filename
        copied_csv = CSV.read(download_filename, headers: true)
        expect(copied_csv.length).to eq 3
        expect(copied_csv.first['first_name']).to eq 'Ray'
      end
    end
  end

end
