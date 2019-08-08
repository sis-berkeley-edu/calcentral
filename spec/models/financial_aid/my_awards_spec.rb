describe FinancialAid::MyAwards do
  let(:uid) { 61889 }
  let(:aid_year) { 2020 }

  before do
    allow_any_instance_of(FinancialAid::MyAidYears).to receive(:default_aid_year).and_return '2020'
  end

  describe '#get_feed' do
    subject { described_class.new(uid, {aid_year: aid_year}).get_feed }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      puts subject
      expect(subject).to be
      expect(subject[:awards]).to be
      expect(subject[:awards].count).to eq 10
      expect(subject[:messages]).to be
      expect(subject[:messages][:messageInfo]).to be
      expect(subject[:messages][:messageEstDisbursements]).to be
      expect(subject[:errored]).to be_falsey
    end
  end
end
