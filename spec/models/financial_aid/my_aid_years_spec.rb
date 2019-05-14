describe FinancialAid::MyAidYears do

  describe '#get_feed' do
    subject { described_class.new(uid).get_feed }
    let(:uid) { 61889 }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:aidYears]).to be
      expect(subject[:aidYears].count).to eq 2
      expect(subject[:aidYears][0].count).to eq 4
      expect(subject[:aidYears][0][:id]).to eq '2019'
      expect(subject[:aidYears][0][:name]).to eq '2018-2019'
      expect(subject[:aidYears][0][:defaultAidYear]).to be_truthy
      expect(subject[:aidYears][0][:availableSemesters]).to eq ['Fall', 'Spring']

      expect(subject[:aidYears][1][:id]).to eq '2018'
      expect(subject[:aidYears][1][:name]).to eq '2017-2018'
      expect(subject[:aidYears][1][:defaultAidYear]).to be_falsey
      expect(subject[:aidYears][1][:availableSemesters]).to eq ['Fall', 'Spring', 'Summer']


    end
  end

  describe '#default_aid_year' do
    subject { described_class.new(uid).default_aid_year }
    let(:uid) { 61889 }

    context 'when feature flag is off' do
      before do
        allow(Settings.features).to receive(:cs_fin_aid).and_return(false)
      end

      it 'should return a nil feed' do
        expect(subject).to be_nil
      end
    end

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject).to eq '2019'
    end
  end
end
