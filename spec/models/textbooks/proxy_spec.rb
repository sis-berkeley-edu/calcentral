describe Textbooks::Proxy do

  # We do not use shared_examples so as to avoid hammering an external data source
  # with redundant requests.
  def it_is_a_normal_server_response
    expect(subject[:statusCode]).to be_blank
    expect(subject[:books][:items]).to be_an_instance_of Array
  end
  def it_has_at_least_one_title
    feed = subject[:books]
    expect(feed[:items]).to be_an_instance_of Array
    expect(feed[:items].length).to be > 1
    first_book = feed[:items][0]
    expect(first_book[:title]).to be_present
    expect(first_book[:author]).to be_present
  end

  let(:course_catalog) { '109G' }
  let(:dept) { 'POL SCI' }
  let(:section_numbers) { ['001'] }
  let(:slug) { 'fall-2013' }
  let(:proxy) do
    Textbooks::Proxy.new(
      course_catalog: course_catalog,
      dept: dept,
      fake: fake,
      section_numbers: section_numbers,
      slug: slug
    )
  end

  describe '#get' do
    subject { proxy.get }

    context 'fake proxy' do
      let(:fake) { true }

      context 'good fixture data' do
        it 'properly transforms bookstore feed' do
          it_is_a_normal_server_response
          it_has_at_least_one_title
          items = subject[:books][:items]
          expect(items[1][:author]).to eq 'SIDES'
          expect(items[1][:title]).to eq 'CAMPAIGNS+ELECTIONS 2012 ELECTION UPD. (Required)'
        end
      end

      context 'feed including malformed item' do
        before do
          proxy.override_json do |json|
            json.first['materials'][3] = {
              ean: 'No Number Nonsense',
              title: ' ()',
              author: nil
            }
          end
        end
        it 'logs error and skips bad entry' do
          expect(Rails.logger).to receive(:error).with /invalid ISBN/
          it_is_a_normal_server_response
          expect(subject[:books][:items]).to have(3).items
        end
      end

      context 'course catalog with fewer than three characters' do
        before do
          allow(Settings.features).to receive(:hub_term_api).and_return false
          allow(Settings.terms).to receive(:legacy_cutoff).and_return(legacy_terms_cutoff)
        end
        let(:course_catalog) { '1A' }
        let(:url) { proxy.bookstore_link section_numbers }

        def encoded_course_param(value)
          "%22course%22:%22#{value}%22"
        end

        context 'legacy term' do
          let(:legacy_terms_cutoff) { 'summer-2016' }
          it 'does not zero-pad course catalog' do
            expect(url).to include encoded_course_param('1A')
          end
        end
        context 'Campus Solutions term' do
          let(:legacy_terms_cutoff) { 'summer-2013' }
          it 'zero-pads course catalog' do
            expect(url).to include encoded_course_param('01A')
          end
        end
      end
    end
  end

  describe '#get_as_json' do
    include_context 'it writes to the cache at least once'
    let(:fake) { false }
    let(:json) { proxy.get_as_json }
    it 'returns proper JSON' do
      expect(json).to be_present
      parsed = JSON.parse(json)
      expect(parsed).to be
      unless parsed['statusCode'] && parsed['statusCode'] >= 400
        expect(parsed['books']).to be
      end
    end
    context 'when the bookstore server has problems' do
      before do
        stub_request(:any, /#{Regexp.quote(Settings.textbooks_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      end
      it 'returns a error status code and message' do
        parsed = JSON.parse(json)
        expect(parsed['statusCode']).to be >= 400
        expect(parsed['body']).to be_present
      end
    end

    it_should_behave_like 'a proxy logging errors' do
      subject { json }
    end
  end

end
