describe Concerns::LoanHistoryModule do

  describe '#calculate_estimated_monthly_payment' do
    let(:interest_rate) { 4.5 }
    let(:principal_value) { 18000 }
    let(:repayment_period) { nil }
    subject { described_class.calculate_estimated_monthly_payment(interest_rate, principal_value, repayment_period) }

    context 'when only given some of the parameters' do
      it 'returns nil' do
        expect(subject).to eql(nil)
      end
    end

    context 'when given all required parameters' do
      let(:repayment_period) { 120 }
      it 'returns the expected value' do
        expect(subject.to_f.round(2)).to eql(186.55)
      end
    end

    context 'when given an interest of zero' do
      let(:interest_rate) { 0 }
      let(:repayment_period) { 120 }
      it 'returns nil' do
        expect(subject).to eql(nil)
      end
    end
  end

  describe '#choose_monthly_payment' do
    let(:estimated) { nil }
    let(:minimum) { 50 }
    let(:total_amount_owed) { 15000 }
    subject { described_class.choose_monthly_payment(estimated, minimum, total_amount_owed) }

    context 'when only given some of the parameters' do
      it 'returns nil' do
        expect(subject).to eql(nil)
      end
    end

    context 'when given all the required parameters' do
      context 'when estimated < monthly' do
        let(:estimated) { 25 }
        it 'returns the monthly value' do
          expect(subject).to eql(50)
        end
      end

      context 'when estimated > monthly' do
        let(:estimated) { 100 }
        it 'returns the estimated value' do
          expect(subject).to eql(100)
        end
      end

      context 'when total amount owed < minimum monthly payment' do
        let(:estimated) { 45 }
        let(:total_amount_owed) { 1 }
        it 'returns the total amount owed as the minimum monthly payment' do
          expect(subject).to eql(1)
        end
      end
    end
  end

  describe '#enrolled_pre_fall_2016?' do
    let(:enrolled_prior_to_fall_2016_cs_id) { 11667051 }
    let(:not_enrolled_prior_to_fall_2016_cs_id) { 22778162 }
    subject { described_class.enrolled_pre_fall_2016?(cs_id) }

    context 'when user was enrolled prior to Fall 2016' do
      let(:cs_id) { enrolled_prior_to_fall_2016_cs_id }
      it 'returns true' do
        expect(subject).to eql(true)
      end
    end

    context 'when user was not enrolled prior to Fall 2016' do
      let(:cs_id) { not_enrolled_prior_to_fall_2016_cs_id }
      it 'returns false' do
        expect(subject).to eql(false)
      end
    end
  end

  describe '#is_loan_history_active?' do
    let(:loan_history_active_cs_id) { 11667051 }
    let(:loan_history_inactive_cs_id) { 33889273 }
    subject { described_class.is_loan_history_active?(cs_id) }

    context 'when user is loan history active' do
      let(:cs_id) { loan_history_active_cs_id }
      it 'returns true' do
      expect(subject).to eql(true)
      end
    end

    context 'when user is not loan history active' do
      let(:cs_id) { loan_history_inactive_cs_id }
      it 'returns false' do
        expect(subject).to eql(false)
      end
    end
  end

  describe '#parse_edo_response_with_sequencing' do
    subject { described_class.parse_edo_response_with_sequencing(input) }

    context 'when given an edodb-like array with `sequence` as one of the properties' do
      let(:input) { [10.0, 20.0, 30.0].map { |num| {'sequence' => num, 'some_other_property' => 'abc'} } }

      it 'returns a camelized response' do
        expect(subject[0]).to include :sequence and :someOtherProperty
      end

      it 'keeps the sequencing intact' do
        expect(subject[0][:sequence]).to eql(10)
        expect(subject[1][:sequence]).to eql(20)
        expect(subject[2][:sequence]).to eql(30)
      end
    end

    context 'when given an input that is not an array' do
      let(:input) { { 'property_one' => 1, 'property_two' => 2 } }
      it 'returns the input unchanged' do
        expect(subject).to eql(input)
      end
    end
  end

  describe '#parse_owed_value' do
    subject { described_class.parse_owed_value(value) }

    context 'when given a value with lots of trailing numbers' do
      let(:value) { 164857.33333354787 }

      it 'returns a float with decimal values up to the hundredths place' do
        expect(subject).to be_an_instance_of(Float)
        expect(subject).to eql(164857.33)
      end
    end

    context 'when given an integer' do
      let(:value) { 16 }

      it 'returns a float' do
        expect(subject).to be_an_instance_of(Float)
        expect(subject).to eql(16.00)
      end
    end

    context 'when given something that is not a number' do
      let(:value) { 'Hiya Buddy' }

      it 'returns zero' do
        expect(subject).to eql(0)
      end
    end
  end

end
