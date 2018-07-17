describe Financials::LoanHistory::LoansCumulative do

  let(:uid) { 61889 }
  let(:proxy) { described_class }

  let(:enrolled_pre_2168_cs_id)     { 11667051 }
  let(:not_enrolled_pre_2168_cs_id) { 22778162 }
  let(:loan_history_inactive_cs_id) { 33889273 }

  describe 'making a call to the LoansCumulative API' do

    context 'loan history inactive' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return loan_history_inactive_cs_id
      end
      subject { proxy.new(uid).get_feed }

      it 'should return the expected structure' do
        expect(subject).to include :loans and :loansSummary
        expect(subject[:loans]).to be_falsey
        expect(subject[:loansSummary]).to be_falsey
      end
    end

    context 'loan history active, enrolled pre-Fall 2016' do
      context 'enrolled pre-Fall 2016' do
        before do
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return enrolled_pre_2168_cs_id
        end
        subject { proxy.new(uid).get_feed }

        context 'correctly parse each available loan' do
          it 'should return the expected structure' do
            expect(subject[:loans]).to be_an_instance_of(Array)
            expect(subject[:loans]).to have(4).items
            expect(subject[:loansSummary]).to be_an_instance_of(Hash)
            expect(subject[:loansSummary]).to include :amountOwed and :estMonthlyPayment
          end

          it 'correctly parses the loan description data' do
            expect(subject[:loans][0][:category]).to eql('Federal Direct Loans')
            expect(subject[:loans][1][:category]).to eql('Federal Perkins Loan')
            expect(subject[:loans][2][:category]).to eql('State and Institutional Loans')
            expect(subject[:loans][3][:category]).to eql('Private Loans')
          end

          it 'correctly calculates the loan category totals' do
            federal_direct_amt =  subject[:loans][0][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            federal_perkins_amt = subject[:loans][1][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            state_amt =           subject[:loans][2][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            private_amt =         subject[:loans][3][:loans].reduce(0) { |memo, loan| memo = memo + loan[:amountOwed] }
            expect(subject[:loans][0][:totals][:amountOwed]).to eql(federal_direct_amt)
            expect(subject[:loans][1][:totals][:amountOwed]).to eql(federal_perkins_amt)
            expect(subject[:loans][2][:totals][:amountOwed]).to eql(state_amt)
            expect(subject[:loans][3][:totals][:amountOwed]).to eql(private_amt)
          end

          it 'correctly calculates the cumulative totals' do
            cumulative_total =           subject[:loans].reduce(0) { |memo, loan| memo = memo + loan[:totals][:amountOwed] }
            cumulative_monthly_payment = subject[:loans].reduce(0) { |memo, loan| memo = memo + loan[:totals][:estMonthlyPayment] }
            expect(subject[:loansSummary][:amountOwed]).to eql(cumulative_total)
            expect(subject[:loansSummary][:estMonthlyPayment]).to eql(cumulative_monthly_payment)
          end

          it 'adds pre-Fall 2016 messaging to loan descriptions' do
            expect(subject[:loans][0][:descr]).to eql('View your Federal Loan Details. Please visit Federal Loan Details to view Federal Direct Loans borrowed prior to Fall 2016.')
          end
        end

        context 'when loan amount data is missing from the database' do
          it 'still includes the loan data with a zero value' do
            expect(subject[:loans][0][:loans][2][:loanType]).to eql('Grad PLUS')
            expect(subject[:loans][0][:loans][2][:amountOwed]).to eql(0)
            expect(subject[:loans][0][:loans][2][:estMonthlyPayment]).to eql(0)
            expect(subject[:loans][0][:loans][2][:estMonthlyPayment]).to be
          end
        end
      end

      context 'not enrolled pre-Fall 2016' do
        before do
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return not_enrolled_pre_2168_cs_id
        end
        subject { proxy.new(uid).get_feed }

        it 'does not add pre-Fall 2016 messaging to loan descriptions' do
          expect(subject[:loans][0][:descr]).to eql('View your Federal Loan Details.')
        end
      end
    end
  end

end
