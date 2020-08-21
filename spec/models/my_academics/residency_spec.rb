require 'spec_helper'

describe MyAcademics::Residency do
  subject { described_class.new(uid) }
  let(:feed) { subject.get_feed }

  let(:uid) { '61889' }
  let(:message_nbr) { '2000' }
  let(:fake_residency_message_proxy) { CampusSolutions::ResidencyMessage.new(fake: true, messageNbr: message_nbr) }

  describe '#get_feed_internal' do
    let(:residency_message_code) { nil }
    let(:residency_message) { nil }
    let(:hub_residency) do
      {
        fromTerm: {
          id: '2172',
          name: '2017 Spring',
          label: 'Spring 2017',
        },
        official: {
          code: 'NON',
          description: 'Non-Resident',
        },
        statementOfLegalResidenceStatus: {
          code: 'D',
          description: 'Auto Residency Determined'
        }
      }
    end
    let(:residency_message_model) { double(:residency_message_model, get: residency_message) }
    let(:result) { subject.get_feed_internal }
    before do
      allow(subject).to receive(:get_hub_residency).and_return(hub_residency)
      allow(subject).to receive(:get_residency_message_code).and_return(residency_message_code)
      allow(CampusSolutions::ResidencyMessage).to receive(:new).with({messageNbr: residency_message_code}).and_return(residency_message_model)
    end
    context 'when no hub residency resturned' do
      let(:hub_residency) { nil }
      it 'returns empty residency hash' do
        expect(result).to eq({residency: nil})
      end
    end
    context 'when no message code returned' do
      let(:residency_message_code) { nil }
      it 'returns residency without message details' do
        expect(result[:residency][:fromTerm][:id]).to eq '2172'
        expect(result[:residency][:official][:code]).to eq 'NON'
        expect(result[:residency][:statementOfLegalResidenceStatus][:code]).to eq 'D'
      end
    end
    context 'when message code returned' do
      let(:residency_message_code) { '2003' }
      it 'returns residency' do
        expect(result[:residency][:fromTerm][:id]).to eq '2172'
        expect(result[:residency][:official][:code]).to eq 'NON'
        expect(result[:residency][:statementOfLegalResidenceStatus][:code]).to eq 'D'
      end
      it 'includes message code' do
        expect(result[:residency][:message][:code]).to eq residency_message_code
      end
      context 'when message definition present' do
        let(:residency_message) do
          {
            statusCode: 200,
            feed: {
              root: {
                getMessageCatDefn: {
                  messageNbr: '2005',
                  messageSetNbr: '28001',
                  messageText: 'Message text',
                  descrlong: 'Long description',
                }
              }
            }
          }
        end
        it 'includes message details' do
          expect(result[:residency][:message][:description]).to eq 'Long description'
          expect(result[:residency][:message][:label]).to eq 'Message text'
          expect(result[:residency][:message][:setNumber]).to eq '28001'
        end
      end
      context 'when message definition not present' do
        let(:residency_message) { nil }
        it 'does not include message details' do
          expect(result[:residency][:message].has_key?(:description)).to eq false
          expect(result[:residency][:message].has_key?(:label)).to eq false
          expect(result[:residency][:message].has_key?(:setNumber)).to eq false
        end
      end
    end
  end

  describe '#get_hub_residency' do
    let(:result) { subject.get_hub_residency }
    let(:demographics_proxy) { double(:demographics_proxy, :get => demographics_proxy_response) }
    let(:demographics_proxy_response) { {statusCode: 200, feed: demographics_feed, studentNotFound: nil} }
    let(:demographics_feed) { {'residency' => residency_hash} }
    let(:residency_hash) do
      {
        'fromTerm' => residency_from_term,
        'official' => {
          'code' => 'NON',
          'description' => 'Non-Resident'
        },
        'statementOfLegalResidenceStatus' => {
          'code' => 'D',
          'description' => 'Auto Residency Determined',
        }
      }
    end
    let(:residency_from_term) { {'id' => '2172', 'name' => '2017 Spring'} }
    before do
      allow(HubEdos::StudentApi::V2::Feeds::Demographics).to receive(:new).with(user_id: uid).and_return(demographics_proxy)
      allow(Berkeley::TermCodes).to receive(:normalized_english).with('2017 Spring').and_return('Spring 2017')
    end
    context 'when residency is blank' do
      let(:residency_hash) { nil }
      it 'returns empty hash' do
        expect(result).to eq({})
      end
    end
    context 'when residency fromTerm is blank' do
      let(:residency_from_term) { nil }
      it 'returns empty hash' do
        expect(result).to eq({})
      end
    end
    context 'when residency fromTerm is present' do
      it 'returns residency hash with symbolized keys' do
        expect(result[:fromTerm][:id]).to eq '2172'
        expect(result[:fromTerm][:name]).to eq '2017 Spring'
        expect(result[:official][:code]).to eq 'NON'
        expect(result[:official][:description]).to eq 'Non-Resident'
        expect(result[:statementOfLegalResidenceStatus][:code]).to eq 'D'
        expect(result[:statementOfLegalResidenceStatus][:description]).to eq 'Auto Residency Determined'
      end
      it 'includes fromTerm label' do
        expect(result[:fromTerm][:label]).to eq 'Spring 2017'
      end
    end
  end

  describe '#get_residency_message_code' do
    let(:residency) do
      {
        statementOfLegalResidenceStatus: {
          code: 'D',
          description: 'Auto Residency Determined'
        },
        official: {
          code: 'NON',
          description: 'Non-resident'
        },
        tuitionException: {
          code: 'RV',
          description: 'Veteran/Dependent of Veteran'
        }
      }
    end
    let(:result) { subject.get_residency_message_code(residency) }
    before { allow(Berkeley::ResidencyMessageCode).to receive(:residency_message_code).and_return('2003') }
    it 'sends statuses and tuition exception to Berkeley::ResidencyMessageCode' do
      expect(Berkeley::ResidencyMessageCode).to receive(:residency_message_code).with('D', 'NON', 'RV').and_return('2005')
      expect(result).to eq '2005'
    end
    it 'returns residency message code' do
      expect(result).to eq '2003'
    end
  end
end
