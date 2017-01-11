describe Oec::Queries do
  let(:term_code) { '2016-D' }

  context 'enrollments query' do
    subject { described_class.get_enrollments(term_code, requested_section_ids) }

    let(:requested_section_ids) { %w(65536 65537 65538) }
    let(:edo_oracle_columns) do
      %w(section_id ldap_uid sis_id first_name last_name email_address)
    end
    let(:edo_oracle_rows) do
      [
        %w(65536 1234567 87654321 Malachi Mulligan buck@tcd.ie),
        %w(65536 1234568 87654322 Vincent Lynch lynch@tcd.ie),
        %w(65537 1234567 87654321 Malachi Mulligan buck@tcd.ie),
        %w(65537 1234568 87654322 Vincent Lynch lynch@tcd.ie),
        %w(65538 1234567 87654321 Malachi Mulligan buck@tcd.ie),
        %w(65539 1234567 87654321 Malachi Mulligan buck@tcd.ie),
        %w(65540 1234568 87654322 Vincent Lynch lynch@tcd.ie),
        %w(65541 1234568 87654322 Vincent Lynch lynch@tcd.ie)
      ]
    end
    before do
      allow(EdoOracle::Oec).to receive(:get_batch_enrollments).with('2168', 0, Settings.oec.enrollments_batch_size).and_return double(
        columns: edo_oracle_columns,
        rows: edo_oracle_rows
      )
    end

    it 'upcases column names' do
      expect(subject[:columns]).to eq %w(SECTION_ID LDAP_UID SIS_ID FIRST_NAME LAST_NAME EMAIL_ADDRESS)
    end

    it 'filters results to requested section IDs only' do
      expect(subject[:rows]).to have(5).items
      returned_section_ids = subject[:rows].map(&:first).uniq
      expect(returned_section_ids).to match_array requested_section_ids
    end

    context 'missing email address' do
      before { edo_oracle_rows[0][5] = nil }
      it 'fills in email address from attributes query' do
        allow(User::BasicAttributes).to receive(:attributes_for_uids).and_call_original
        expect(User::BasicAttributes).to receive(:attributes_for_uids).with(['1234567']).and_return([{
          ldap_uid: '1234567',
          email_address: 'buck@tcd.ie'
        }])
        expect(subject[:rows][0][5]).to eq 'buck@tcd.ie'
      end
    end
  end
end
