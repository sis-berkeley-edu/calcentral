describe HubEdos::V1::MyStudent do
  subject {
    proxy = HubEdos::V1::MyStudent.new(random_id, options)
    proxy.get_feed_internal
  }
  before do
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_PROFILE', anything).and_return('edit profile link')
    allow_any_instance_of(User::AggregatedAttributes).to receive(:get_feed).and_return(user_attributes)
  end
  let(:options) { {} }
  let(:user_attributes) do
    {
      roles: {
        student: is_student,
        applicant: is_applicant,
        releasedAdmit: is_released_admit
      }
    }
  end
  let(:is_student) { false }
  let(:is_applicant) { false }
  let(:is_released_admit) { false }

  context 'mock proxy' do
    it 'should return unfiltered feed' do
      expect(subject[:statusCode]).to eq 200
      # Verify preferred name
      expect(subject[:feed][:student]['names'][0]['type']['code']).to eq 'PRF'
    end
    context 'view-as session' do
      let(:fields) { %w(affiliations identifiers) }
      let(:options) { { include_fields: fields } }
      it 'should return filtered feed' do
        expect(subject[:statusCode]).to eq 200
        student = subject[:feed][:student]
        expect(student).to have(2).items
        expect(student).to include *fields
        expect(student['affiliations'][0]['status']['code']).to_not be_nil
      end
    end
    context 'when user is not a student or new admit' do
      it 'should not include the edit profile link' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:editProfile]).to be nil
      end
    end
    context 'when user is a student' do
      let(:is_student) { true }
      it 'should include the edit profile link' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:editProfile]).to eq 'edit profile link'
      end
    end
    context 'when user is an applicant' do
      let(:is_applicant) { true }
      it 'should include the edit profile link' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:editProfile]).to eq 'edit profile link'
      end
    end
    context 'when user is a released admit' do
      let(:is_released_admit) { true }
      it 'should include the edit profile link' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:editProfile]).to eq 'edit profile link'
      end
    end
  end
end
