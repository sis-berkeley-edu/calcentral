require 'spec_helper'

describe HubTerm::Proxy do
  context 'recorded proxy' do
    context 'Successful fetch of current term' do
      subject { HubTerm::Proxy.new(fake: true, temporal_position: HubTerm::Proxy::CURRENT_TERM) }
      it 'returns the expected format' do
        response = subject.get
        expect(response['apiResponse']['httpStatus']['code'].to_i).to eq 200
        expect(response['apiResponse']['response']['terms'][0]['id']).to be_present
        expect(response['apiResponse']['response']['terms'][0]['name']).to be_present
        expect(response['apiResponse']['response']['terms'][0]['temporalPosition']).to eq 'Current'
      end
      it 'extracts the kernel from the shell' do
        feed = subject.get_term
        expect(feed[0]['temporalPosition']).to eq 'Current'
      end
    end
    context 'Failed fetch of current term between semesters' do
      subject { HubTerm::Proxy.new(fake: true, temporal_position: HubTerm::Proxy::CURRENT_TERM, as_of_date: '2016-08-13') }
      it 'gets the expected message' do
        response = subject.get
        expect(response['apiResponse']['httpStatus']['code'].to_i).to eq 404
        expect(response['apiResponse']['response']).to be_nil
        expect(response['apiResponse']['message']['description']).to eq 'No term found for the given date'
      end
      it 'extracts nothing' do
        feed = subject.get_term
        expect(feed).to be_nil
      end
    end
  end
end
