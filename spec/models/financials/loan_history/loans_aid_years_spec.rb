describe Financials::LoanHistory::LoansAidYears do

  let(:uid) { 61889 }
  let(:proxy) { described_class }

  let(:loan_history_active_cs_id) { 11667051 }
  let(:not_enrolled_pre_2168_cs_id) { 22778162 }
  let(:loan_history_inactive_cs_id) { 33889273 }

  describe 'making a call to the LoansAidYears API' do

    context 'loan history inactive' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_inactive_cs_id
      end
      subject { proxy.new(uid).get_feed }

      it 'should return the expected structure' do
        expect(subject).to include :aidYears
        expect(subject[:aidYears]).to be_falsey
      end
    end

    context 'loan history active' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_active_cs_id
      end
      subject { proxy.new(uid).get_feed }

      context 'correctly parse each available loan' do

        context 'should return the expected structure' do
          it 'separates loans by aid year' do
            expect(subject[:aidYears][0][:aidYear]).to eql('2018')
            expect(subject[:aidYears][1][:aidYear]).to eql('2017')
          end

          it 'does not include loans without an amount owed' do
            loans_2018 = subject[:aidYears][0][:loans]
            loans_2017 = subject[:aidYears][1][:loans]
            expect(loans_2018.any? { |loan| loan.try(:[], :loanCategory) == 'Institutional' }).to eql(false)
            expect(loans_2017.any? { |loan| loan.try(:[], :loanCategory) == 'Institutional' }).to eql(false)
          end

          it 'formats the aid year for front-end consumption' do
            expect(subject[:aidYears][0][:aidYearFormatted]).to eql('2018 - 2019')
            expect(subject[:aidYears][1][:aidYearFormatted]).to eql('2017 - 2018')
          end

          it 'correctly calculates the total amount owed for each aid year' do
            loans_2018_total = subject[:aidYears][0][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            loans_2017_total = subject[:aidYears][1][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            expect(subject[:aidYears][0][:totalAmountOwed]).to eql(loans_2018_total)
            expect(subject[:aidYears][1][:totalAmountOwed]).to eql(loans_2017_total)
          end

          it 'hides the interest rate for private loans' do
            loans_2018 = subject[:aidYears][0][:loans]
            private_loan = loans_2018.find { |loan| loan[:loanCategory] == 'Private' }
            expect(private_loan[:interestRate]).to eql(nil)
          end

          context 'using the correct interest rate' do
            it 'uses the interest rate provided by the config view if the detailed view interest rate is CONFIG or UNK' do
              expect(subject[:aidYears][0][:loans][0][:interestRate]).to eql(5.0)
              expect(subject[:aidYears][1][:loans][0][:interestRate]).to eql(5.0)
              expect(subject[:aidYears][1][:loans][1][:interestRate]).to eql(5.0)
            end

            it 'uses the interest rate provided by the detailed view if it is not CONFIG or UNK' do
              expect(subject[:aidYears][0][:loans][1][:interestRate]).to eql(4.45)
              expect(subject[:aidYears][1][:loans][2][:interestRate]).to eql(3.76)
            end
          end
        end
      end
    end
  end
end
