describe DegreeProgress::MyGraduateMilestones do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }

  before do
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_view_as?).and_return(can_view_as)
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:graduate_student?).and_return(graduate_student)
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:law_student?).and_return(law_student)
  end

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    context 'when user is a graduate student' do
      let(:can_view_as) { false }
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
      let(:can_view_as) { false }
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

    context 'when user has view-as privilege' do
      let(:can_view_as) { true }
      let(:graduate_student) { false }
      let(:law_student) { false }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'

      it 'includes links in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:advancementFormSubmit]).to be
        expect(subject[:feed][:links][:advancementFormView]).to be
      end
    end

    context 'when user is not authorized' do
      let(:can_view_as) { false }
      let(:graduate_student) { false }
      let(:law_student) { false }

      it 'returns an empty response' do
        expect(subject).to eq({})
      end
    end
  end
end
