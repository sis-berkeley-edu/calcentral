describe DegreeProgress::MyGraduateMilestones do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }
  let(:user_attributes) do
    {
      roles: {student: true, graduate: graduate_student, law: law_student}
    }
  end

  before do
    allow(User::AggregatedAttributes).to receive(:new).with(user_id).and_return double(get_feed: user_attributes)
  end

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    context 'when user is a graduate student' do
      let(:graduate_student) { true }
      let(:law_student) { false }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'

      it 'includes links in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:advancementFormSubmit]).to be
        expect(subject[:feed][:links][:advancementFormView]).to be
      end
    end

    context 'when user is a law student' do
      let(:graduate_student) { false }
      let(:law_student) { true }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'

      it 'includes links in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:advancementFormSubmit]).to be
        expect(subject[:feed][:links][:advancementFormView]).to be
      end
    end

    context 'when user is neither Graduate nor Law' do
      let(:graduate_student) { false }
      let(:law_student) { false }

      it 'returns an empty response' do
        expect(subject).to eq({})
      end
    end
  end
end
