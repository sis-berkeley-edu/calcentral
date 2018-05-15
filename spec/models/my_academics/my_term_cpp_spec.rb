describe MyAcademics::MyTermCpp do
  let(:stubbed_cpp_data) do
    [
      {"term_id"=>"2158", "acad_career"=>"UGRD", "acad_program"=>"UCNR", "acad_plan"=>"04606U"},
      {"term_id"=>"2162", "acad_career"=>"UGRD", "acad_program"=>"UCNR", "acad_plan"=>"04606U"},
      {"term_id"=>"2168", "acad_career"=>"UGRD", "acad_program"=>"UCNR", "acad_plan"=>"04606U"},
      {"term_id"=>"2172", "acad_career"=>"UGRD", "acad_program"=>"UCNR", "acad_plan"=>"04606U"},
      {"term_id"=>"2175", "acad_career"=>"UGRD", "acad_program"=>"UCNR", "acad_plan"=>"04606U"},
      {"term_id"=>"2178", "acad_career"=>"UGRD", "acad_program"=>"UCLS", "acad_plan"=>"25971U"},
      {"term_id"=>"2182", "acad_career"=>"UGRD", "acad_program"=>"UCLS", "acad_plan"=>"25971U"},
      {"term_id"=>"2185", "acad_career"=>"UGRD", "acad_program"=>"UCLS", "acad_plan"=>"25971U"},
    ]
  end
  let(:student_id) { '123456' }
  before do
    allow(EdoOracle::Queries).to receive(:get_student_term_cpp).and_return(stubbed_cpp_data)
    allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return(student_id)
  end

  let(:described_class_instance) { described_class.new(random_id) }

  describe '#get_feed_internal' do
    subject { described_class_instance.get_feed_internal }
    context 'student id found' do
      it 'provides a set of roles based on the user\'s academic status' do
        expect(subject).to be
        expect(subject.count).to eq 8
        subject.each do |plan|
          expect(plan).to have_keys(["term_id", "acad_career", "acad_program", "acad_plan"])
        end
      end
    end
  end
end
