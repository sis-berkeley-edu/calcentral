describe Concerns::LoanHistoryModule do
  describe '.calculate_estimated_monthly_payment' do
    let(:annual_interest_rate) { 5 }
    let(:principal_value) { 2000 }
    let(:repayment_period) { 120 }
    let(:result) do
      described_class.calculate_estimated_monthly_payment(annual_interest_rate, principal_value, repayment_period)
    end
    context 'when principal value is zero' do
      let(:principal_value) { 0 }
      it 'returns returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when principal value is not zero' do
      let(:principal_value) { 2567 }
      it 'returns estimated monthly payment' do
        expect(result).to eq 27.227017761870687
      end
    end
    context 'when annual interest rate is a float' do
      let(:annual_interest_rate) { BigDecimal.new('4.45') }
      it 'returns value' do
        expect(result).to eq 20.679511250615757
      end
    end
    context 'when annual interest rate is zero' do
      let(:annual_interest_rate) { 0 }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
  end
end
