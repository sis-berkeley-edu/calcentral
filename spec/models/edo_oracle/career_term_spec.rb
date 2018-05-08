describe EdoOracle::CareerTerm, testext: false do

  describe '#term_summary' do
    subject { described_class.new({user_id: uid}).term_summary(academic_careers, term_id) }
    let(:uid) { 799934 }
    let(:academic_careers) { ['UGRD'] }
    let(:term_id) { 2178 }

    it 'returns information about the specified term for the specified careers' do
      expect(subject.count).to be 5
      expect(subject[:total_enrolled_units]).to eq 6
      expect(subject[:total_earned_units]).to eq 96.67
      expect(subject[:grading_complete]).to eq true
      expect(subject[:total_enrolled_law_units]).to be nil
      expect(subject[:total_earned_law_units]).to be nil
    end

    context 'when no data found for term' do
      let(:term_id) { 2150 }
      it 'returns a hash with empty keys' do
        expect(subject.count).to be 5
        expect(subject[:total_enrolled_units]).to be nil
        expect(subject[:total_earned_units]).to be nil
        expect(subject[:grading_complete]).to be_falsey
        expect(subject[:total_enrolled_law_units]).to be nil
        expect(subject[:total_earned_law_units]).to be nil
      end
    end

    context 'when student has a LAW career term' do
      let(:uid) { 490452 }
      let(:academic_careers) { ['LAW'] }
      let(:term_id) { 2185 }
      it 'returns information about the specified term for the specified careers' do
        expect(subject.count).to be 5
        expect(subject[:total_enrolled_units]).to eq 0
        expect(subject[:total_earned_units]).to eq 0
        expect(subject[:grading_complete]).to eq false
        expect(subject[:total_enrolled_law_units]).to eq 16
        expect(subject[:total_earned_law_units]).to eq 0
      end
    end

    context 'when student has a concurrent GRAD + LAW career term' do
      let(:uid) { 300216 }
      let(:academic_careers) { %w(GRAD LAW) }
      let(:term_id) { 2172 }
      it 'returns information about the specified term for the specified careers' do
        expect(subject.count).to be 5
        expect(subject[:total_enrolled_units]).to eq 17
        expect(subject[:total_earned_units]).to eq 16
        expect(subject[:grading_complete]).to eq true
        expect(subject[:total_enrolled_law_units]).to eq 18
        expect(subject[:total_earned_law_units]).to eq 15
      end
    end
  end
end
