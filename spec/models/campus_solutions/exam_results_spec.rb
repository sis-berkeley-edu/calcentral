describe CampusSolutions::ExamResults do

  let(:uid) { 61889 }
  let(:test_csid_no_data) { 19191919 }
  let(:test_csid_without_tc_date) { 1234 }
  let(:test_csid_with_tc_date) { 11667051 }
  let(:proxy) { described_class }

  describe 'making a call to the exam_results API' do

    context 'as a student with exam results data, outside of the transfer credit review period' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return test_csid_without_tc_date }
      subject { proxy.new(uid).get_feed }

      it 'should return data in the expected structure' do
        expect(subject).to include(:exams, :review)
        expect(subject[:exams].length).to eql(6)
        expect(subject[:exams][0]).to include(:id, :descr, :score, :taken)
        expect(subject[:review]).to include(:isPending, :displayMonth)
      end

      it 'should not have any data related to the transfer credit review period' do
        expect(subject[:review][:isPending]).to be_nil
        expect(subject[:review][:displayMonth]).to be_nil
      end
    end

    context 'as a student with exam results data, within the transfer credit review period' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return test_csid_with_tc_date }
      subject { proxy.new(uid).get_feed }

      it 'should return data related to the transfer credit review period' do
        expect(subject[:review][:isPending]).to be_truthy
        expect(subject[:review][:displayMonth]).to eql ('October')
      end
    end

    context 'as a student with no exam results data' do
      before { allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return test_csid_no_data }
      subject { proxy.new(uid).get_feed }

      it 'should still return the expected structure' do
        expect(subject[:exams]).to be_a(Array)
        expect(subject[:review]).to include(:isPending, :displayMonth)
      end
    end
  end
end
