describe User::Academics::TermPlans::Queries do
  describe ".get_student_term_cpp" do
    let(:result) { described_class.get_student_term_cpp(student_id) }
    context "when valid uid" do
      let(:student_id) { "10167763" }
      it "should return term cpp records" do
        expect(result.count).to eq 8
        expect(result[0]).to have_keys(["term_id", "acad_career", "acad_career_descr", "acad_program", "acad_plan"])
      end
    end
  end
end
