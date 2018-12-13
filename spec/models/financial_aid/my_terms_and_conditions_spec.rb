describe FinancialAid::MyTermsAndConditions do
  before do
    allow_any_instance_of(FinancialAid::MyAidYears).to receive(:default_aid_year).and_return '2019'
  end

  describe '#get_feed' do
    subject { described_class.new(uid, {aid_year: aid_year}).get_feed }
    let(:uid) { 61889 }
    let(:aid_year) { 2018 }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:termsAndConditions]).to be
      expect(subject[:termsAndConditions].count).to eq 7
      expect(subject[:termsAndConditions][:aidYear]). to eq '2018'
      expect(subject[:termsAndConditions][:approved]).to eq true
      expect(subject[:termsAndConditions][:responseDescr]).to eq 'Accepted'
      expect(subject[:termsAndConditions][:mainHeader]).to eq 'main_header'
      expect(subject[:termsAndConditions][:mainBody]).to eq 'main_body'
      expect(subject[:termsAndConditions][:dynamicHeader]).to eq 'dynamic_header'
      expect(subject[:termsAndConditions][:dynamicBody]).to eq nil
    end

    context 'when no terms and conditions data exists for aid year' do
      let(:uid) { 61889 }
      let(:aid_year) { '1999' }
      it 'returns an empty terms list' do
        expect(subject).to be
        expect(subject[:termsAndConditions]).to eq nil
      end
    end

    context 'when no aid year is provided' do
      let(:uid) { 61889 }
      let(:aid_year) { nil }
      it 'assumes the default aid year' do
        expect(subject).to be
        expect(subject[:termsAndConditions]).to be
        expect(subject[:termsAndConditions].count).to eq 7
        expect(subject[:termsAndConditions][:aidYear]). to eq '2019'
        expect(subject[:termsAndConditions][:approved]).to eq false
        expect(subject[:termsAndConditions][:responseDescr]).to eq 'Not Accepted'
        expect(subject[:termsAndConditions][:mainHeader]).to eq 'main_header'
        expect(subject[:termsAndConditions][:mainBody]).to eq 'main_body'
        expect(subject[:termsAndConditions][:dynamicHeader]).to eq 'dynamic_header'
        expect(subject[:termsAndConditions][:dynamicBody]).to eq 'dynamic_body'
      end
    end

  end


end
