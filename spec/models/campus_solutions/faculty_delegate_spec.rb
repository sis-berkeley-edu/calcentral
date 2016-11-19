describe CampusSolutions::FacultyDelegate do

  let(:term_id) { random_id }
  let(:course_id) { random_id }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucSrFacultyDelegates]).to be
      expect(subject[:feed][:ucSrFacultyDelegates][:ucSrFacultyDelegate]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::FacultyDelegate.new(term_id: term_id, course_id: course_id, fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

end
