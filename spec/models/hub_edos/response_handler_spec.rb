describe HubEdos::ResponseHandler do

  class Worker
    include HubEdos::ResponseHandler

    def fetch_first_postal_code(parsed_response)
      unwrapped = unwrap_response(parsed_response)
      if unwrapped.present?
        {
          postalCode: unwrapped['addresses'][0]['postalCode']
        }
      else
        {}
      end
    end
  end

  subject { Worker.new.fetch_first_postal_code parsed_response }

  context 'GL5 wrapper format' do
    let(:parsed_response) {
      {
        'apiResponse' => {
          'response' => {
            'any' => {
              'addresses' => [
                {
                  'postalCode' => '454554',
                  'countryCode' => 'USA'
                }
              ]
            }
          }
        }
      }
    }
    it 'should find postal code' do
      expect(subject).to eq({ postalCode: '454554' })
    end
  end

  context 'unsuccessful fetch' do
    context 'nil response' do
      let(:parsed_response) { nil }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'empty response' do
      let(:parsed_response) { {} }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'incomplete response' do
      let(:parsed_response) {
        {
          'apiResponse' => {
            'response' => {
              'notTheDroids' => 'you are looking for!'
            }
          }
        }
      }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'any element does not respond_to? :each' do
      let(:parsed_response) {
        {
          'apiResponse' => {
            'response' => {
              'any' => 'this string is supposed to be a hash'
            }
          }
        }
      }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end
  end
end
