describe Textbooks::Proxy do
  let(:course_catalog) { '1AX' }
  let(:slug) { 'fall-2020' }
  let(:department) { 'KOREAN' }
  let(:section_numbers) { ['22117'] }
  let(:options) do
    {
      course_catalog: course_catalog,
      slug: slug,
      dept: department,
      section_numbers: section_numbers
    }
  end
  subject { described_class.new(options) }

  let(:campus_terms) { {slug => double(:legacy? => term_is_legacy)} }
  let(:term_is_legacy) { false }
  let(:fetched_terms) { double(campus: campus_terms) }

  before do
    allow(Berkeley::Terms).to receive(:fetch).and_return(fetched_terms)
  end

  describe '#format_course_catalog' do
    context 'when slug term is not legacy' do
      let(:slug) { 'fall-2020' }
      let(:term_is_legacy) { false }
      it 'returns course catalog without formatting' do
        expect(subject.format_course_catalog(course_catalog)).to eq '1AX'
      end
    end
    context 'when slug term is legacy' do
      let(:slug) { 'fall-2015' }
      let(:term_is_legacy) { true }
      it 'returns course catalog without formatting' do
        expect(subject.format_course_catalog(course_catalog)).to eq '1AX'
      end
    end
  end

  describe '#get_term' do
    let(:slug) { 'fall-2020' }
    it 'converts slug to term' do
      expect(subject.get_term(slug)).to eq 'FALL 2020'
    end
  end

  describe '#bookstore_link' do
    it 'returns formatted course catalog' do
      result = subject.bookstore_link(section_numbers)
      expect(result).to eq 'https://calstudentstore.berkeley.edu/course-info?courses=%5B%7B%22dept%22:%22KOREAN%22,%22course%22:%221AX%22,%22section%22:%2222117%22,%22term%22:%22FALL%202020%22%7D%5D'
    end

    it 'encodes section json properly' do
      # this is used to troubleshoot / detect an issue with urlencoding
      params = [
        {
          'dept' => 'KOREAN',
          'course' => '1AX',
          'section' => '22117',
          'term' => 'FALL 2020'
        }
      ]
      result = Addressable::URI.encode_component(params.to_json, Addressable::URI::CharacterClasses::QUERY)
      expect(result).to eq "%5B%7B%22dept%22:%22KOREAN%22,%22course%22:%221AX%22,%22section%22:%2222117%22,%22term%22:%22FALL%202020%22%7D%5D"
    end
  end
end
