describe HubEdos::ClassesApi::V1::Sections do
  let(:term_id) { '2208' }
  let(:course_id) { '1234567' }
  let(:sections_present_response) do
    {
      feed: {
        'classSections' => [
          {
            'id' => 15476,
            'number' => '001',
            'component' => {},
            'displayName' => '2021 Spring ECON H195B 001 IND 001',
            'instructionMode' => {},
            'type' => {},
            'academicOrganization' => {},
            'academicGroup' => {},
            'startDate' => '2021-01-19',
            'endDate' => '2021-05-07',
            'status' => {},
            'association' => {},
            'enrollmentStatus' => [],
            'printInScheduleOfClasses' => true,
            'addConsentRequired' => {},
            'dropConsentRequired' => {},
            'graded' => true,
            'feesExist' => false,
            'roomShare' => false,
            'sectionAttributes' => [],
            'meetings' => [],
            'class' => {},
          }
        ]
      },
      statusCode: 200,
    }
  end
  let(:sections_not_found_response) do
    {
      statusCode: 404,
      feed: {}
    }
  end

  let(:sections_proxy_response) { sections_present_response }
  let(:sections_proxy) { double(get: sections_proxy_response) }
  before do
    allow(HubEdos::ClassesApi::V1::Feeds::SectionsProxy).to receive(:new).and_return(sections_proxy)
  end

  subject { described_class.new(term_id, course_id) }

  describe '#all' do
    context 'when api returns sections' do
      let(:sections_proxy_response) { sections_present_response }
      it 'returns array of section objects' do
        expect(subject.all).to be_an_instance_of Array
        expect(subject.all.count).to eq 1
        expect(subject.all.first).to be_an_instance_of HubEdos::ClassesApi::V1::Section
      end
    end
    context 'when api returns 404 response' do
      let(:sections_proxy_response) { sections_not_found_response }
      it 'returns empty array' do
        expect(subject.all).to be_an_instance_of Array
        expect(subject.all.count).to eq 0
      end
    end
  end
end
