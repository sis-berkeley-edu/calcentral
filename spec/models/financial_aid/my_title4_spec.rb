describe FinancialAid::MyTitle4 do

  describe '#get_feed' do
    subject { described_class.new(uid).get_feed }
    let(:uid) { 61889 }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:title4]).to be
      expect(subject[:title4].count).to eq 9
      expect(subject[:title4][:hasFinaid]).to eq true
      expect(subject[:title4][:approved]).to eq true
      expect(subject[:title4][:responseDescr]).to eq 'Accepted'
      expect(subject[:title4][:longTitle]).to eq 'main_header'
      expect(subject[:title4][:longMessage]).to eq 'main_body'
      expect(subject[:title4][:dynamicHeader]).to eq 'dynamic_header'
      expect(subject[:title4][:dynamicBody]).to eq 'dynamic_body'
      expect(subject[:title4][:dynamicLabel]).to eq 'dynamic_label'
      expect(subject[:title4][:contactText]).to eq 'contact_text'
    end
  end
end
