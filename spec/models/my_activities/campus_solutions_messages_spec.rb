describe MyActivities::CampusSolutionsMessages do
  let(:user_id) { random_id }
  let(:activities) { [] }

  context 'with a fake pending messages feed' do
    before do
      allow(CampusSolutions::PendingMessages).to receive(:new).and_return(CampusSolutions::PendingMessages.new(fake: true))
    end
    subject { MyActivities::CampusSolutionsMessages.append!(user_id, activities) }
    it 'should be able to process activities from a fake pending messages feed' do
      expect(subject[0][:emitter]).to eq 'Campus Solutions'
      expect(subject[0][:linkText]).to eq 'Read more'
      expect(subject[0][:date][:epoch]).to eq 1449007744
      expect(subject[0][:date][:dateString]).to eq '12/01'
      expect(subject[0][:cs][:isFinaid]).to be_truthy
      expect(subject[0][:cs][:finaidYearId]).to eq '2016'
    end
  end

end
