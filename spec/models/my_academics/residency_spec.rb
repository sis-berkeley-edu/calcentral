require 'spec_helper'

describe MyAcademics::Residency do
  let(:feed) { described_class.new(uid).get_feed }

  let(:uid) { '61889' }
  # As deciphered by ResidencyMessageCode
  let(:message_nbr) { '2005' }
  let(:fake_demographics_proxy) { HubEdos::Demographics.new(fake: true, user_id: uid) }
  let(:fake_residency_message_proxy) { CampusSolutions::ResidencyMessage.new(fake: true, messageNbr: message_nbr) }

  context 'fake data' do
    before do
      allow(HubEdos::Demographics).to receive(:new).with(user_id: uid).and_return fake_demographics_proxy
      allow(CampusSolutions::ResidencyMessage).to receive(:new).with({messageNbr: message_nbr}).and_return fake_residency_message_proxy
    end
    it 'contains the expected data' do
      residency = feed[:residency]
      expect(residency[:official][:code]).to eq 'NON'
      expect(residency[:fromTerm][:label]).to eq 'Summer 2014'
      expect(residency[:message][:code]).to eq '2005'
      expect(residency[:message][:label]).to eq 'Submitted & Completed & Non-Resident & Excs'
      expect(residency[:message][:description]).to be_present
    end
    context 'Resident without statementOfLegalResidenceStatus' do
      let(:message_nbr) {'2003'}
      before do
        allow(fake_demographics_proxy).to receive(:get).and_return(
          {:feed=> {'student' => {'residency'=>
            {'source'=>{'code'=>'Official'},
              'fromTerm'=>{'id'=>'2158', 'name'=>'2015 Fall'},
              'fromDate'=>'2015-08-19',
              'official'=>{'code'=>'RES', 'description'=>'Resident'},
              'financialAid'=>{'code'=>'RES', 'description'=>'Resident'},
              'tuition'=>{'code'=>'RES', 'description'=>'Resident'},
              'county'=>'',
              'stateCode'=>'',
              'countryCode'=>'USA',
              'postalCode'=>'',
              'comments'=>''}
          }}}
        )
        allow(fake_residency_message_proxy).to receive(:get).and_return(
          {:statusCode=>200, :feed=> {:root=>
            {:getMessageCatDefn=>
              {:messageSetNbr=>'28001',
                :messageNbr=>'2003',
                :messageText=>'no text',
                :msgSeverity=>'M',
                :descrlong=>nil}}
          }}
        )
      end
      it 'quietly confirms residency' do
        residency = feed[:residency]
        expect(residency[:official][:code]).to eq 'RES'
        expect(residency[:fromTerm][:label]).to eq 'Fall 2015'
        expect(residency[:message][:code]).to eq '2003'
        expect(residency[:message][:label]).to eq 'no text'
        expect(residency[:message][:description]).to be_blank
      end
    end

    context 'when residency message code params are not recognized' do
      before do
        allow(fake_residency_message_proxy).to receive(:get).and_return(
          {:feed=> {:root=> nil}}
        )
      end

      it 'should not bonk out' do
        expect(feed[:residency]).to be
      end
    end
  end

end
