describe Oec::Worksheet do

  describe 'parsing from CSV' do
    let(:csv) { File.read Rails.root.join('fixtures', 'oec', filename) }
    subject { klass.from_csv csv }

    context 'CSV headers matching class definition' do
      let(:klass) { Oec::Supervisors }
      let(:filename) { 'supervisors.csv' }
      let(:rows) { subject.to_a }

      it 'parses headers and rows' do
        expect(subject).to be_a klass
        expect(rows).to be_present
      end

      context 'header-only csv' do
        let(:csv_headers) { csv.sub(/\n.*\Z/m, '') }
        subject { klass.from_csv csv_headers }

        it 'parses headers and no rows' do
          expect(subject).to be_a klass
          expect(rows).to be_empty
        end
      end
    end

    context 'CSV headers not matching class definition' do
      let(:klass) { Oec::Supervisors }
      let(:filename) { 'courses.csv' }

      it 'errors out' do
        expect {subject}.to raise_error /Header mismatch/
      end
    end

    context 'empty CSV' do
      let(:klass) { Oec::Supervisors }
      let(:csv) { '' }

      it 'errors out' do
        expect {subject}.to raise_error /Header mismatch/
      end
    end
  end

end
