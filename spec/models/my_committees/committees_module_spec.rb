describe MyCommittees::CommitteesModule do

  let(:cs_committee) do
    {
      committeeType: cs_committee_type
    }
  end

  describe '#translate_committee_type' do
    subject { described_class.translate_committee_type(cs_committee) }

    context 'when committeeType is nil' do
      let(:cs_committee_type) { nil }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is not a string' do
      let(:cs_committee_type) { {} }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is garbage' do
      let(:cs_committee_type) { 'GARBAGE' }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is QE' do
      let(:cs_committee_type) { 'QE' }
      it 'returns true' do
        expect(subject).to eq 'Qualifying Exam Committee'
      end
    end
    context 'when committeeType is PLN1MASTER' do
      let(:cs_committee_type) { 'PLN1MASTER' }
      it 'returns false' do
        expect(subject).to eq 'Master\'s Thesis Committee'
      end
    end
    context 'when committeeType is DOCTORAL' do
      let(:cs_committee_type) { 'DOCTORAL' }
      it 'returns true' do
        expect(subject).to eq 'Dissertation Committee'
      end
    end
  end

  describe '#qualifying_exam?' do
    subject { described_class.qualifying_exam?(cs_committee) }

    context 'when committeeType is nil' do
      let(:cs_committee_type) { nil }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is not a string' do
      let(:cs_committee_type) { 123 }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is garbage' do
      let(:cs_committee_type) { 'GARBAGE' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is a valid non-QE type' do
      let(:cs_committee_type) { 'PLN1MASTER' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is QE' do
      let(:cs_committee_type) { 'QE' }
      it 'returns true' do
        expect(subject).to be true
      end
    end
  end

  describe '#format_member_service_dates' do
    subject { described_class.format_member_service_dates(committee_member) }

    context 'when committee member is nil' do
      let(:committee_member) { nil }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when committee member service start and end dates are missing' do
      let(:committee_member) do
        {
          memberEndDate: nil,
          memberStartDate: nil
        }
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when one of the committee member service dates is missing' do
      let(:committee_member) do
        {
          memberEndDate: '2016-01-01',
          memberStartDate: nil
        }
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when committee member service start and end dates are populated' do
      let(:committee_member) do
        {
          memberEndDate: '2016-01-01',
          memberStartDate: '2015-01-01'
        }
      end
      it 'returns a formatted date range' do
        expect(subject).to eq 'Jan 01, 2015 - Jan 01, 2016'
      end
    end
  end

  describe '#member_active?' do
    subject { described_class.member_active?(committee_member) }

    context 'when committee member is nil' do
      let(:committee_member) { nil }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committee member service end date is missing' do
      let(:committee_member) do
        {
          csMemberEndDate: nil,
        }
      end
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committee member service end date is malformed' do
      let(:committee_member) do
        {
          csMemberEndDate: 'Present',
        }
      end
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committee member service end date is in the past' do
      let(:committee_member) do
        {
          csMemberEndDate: '2009-01-01',
        }
      end
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committee member service end date is today' do
      let(:committee_member) do
        {
          csMemberEndDate: DateTime.now.to_date.strftime('%F'),
        }
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committee member service end date is in the future' do
      let(:committee_member) do
        {
          csMemberEndDate: '2999-01-01',
        }
      end
      it 'returns true' do
        expect(subject).to be true
      end
    end

    describe '#format_date' do
      subject { described_class.format_date(date, replace_future) }
      let(:replace_future) { nil }

      context 'when date is missing' do
        let(:date) { nil }
        it 'returns empty string' do
          expect(subject).to eq ''
        end
      end
      context 'when date is in the future' do
        let(:date) { '2900-10-01' }

        it 'returns a formatted date' do
          expect(subject).to eq 'Oct 01, 2900'
        end
        context 'when replacing future dates with text' do
          let(:replace_future) { true }
          it 'returns Present' do
            expect(subject).to eq 'Present'
          end
        end
      end
      context 'when date is in the past' do
        let(:date) { '2008-12-31' }
        it 'returns a formatted date' do
          expect(subject).to eq 'Dec 31, 2008'
        end
        context 'when replacing future dates with text' do
          let(:replace_future) { true }
          it 'returns a formatted date' do
            expect(subject).to eq 'Dec 31, 2008'
          end
        end
      end
    end
  end
end
