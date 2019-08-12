describe User::HasStudentHistory do
  let(:uid) { '2050' }

  describe 'has_student_history?' do
    let(:sisedo_term) { double(:term, :legacy? => true) }
    let(:current_terms) { [sisedo_term] }
    let(:is_sisedo_student) { false }
    before do
      allow(EdoOracle::Queries).to receive(:has_student_history?).and_return(is_sisedo_student)
    end
    subject { described_class.new(uid).has_student_history?(current_terms) }

    context 'when user is not a student in legacy or sisedo systems' do
      it {should eq false}
    end

    context 'when user is a student in sisedo system' do
      let(:is_sisedo_student) { true }
      it {should eq true}
    end
  end

end
