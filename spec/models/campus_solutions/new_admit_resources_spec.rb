describe CampusSolutions::NewAdmitResources do

  let(:uid) { 61889 }
  let(:proxy) { CampusSolutions::NewAdmitResources }
  let(:link_api_response) { {url: true} }
  before(:each) do
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).and_return link_api_response
  end

  let(:sir_statuses_incomplete_base_response) {
    {
      sirStatuses: [
        {
          checkListMgmtAdmp: {
            acadCareer: 'UGRD',
            admApplNbr: '00111591'
          },
          isUndergraduate: true,
          itemStatusCode: 'I'
        }
      ]
    }
  }

  let(:sir_statuses_complete_base_response) {
    {
      sirStatuses: [
        {
          checkListMgmtAdmp: {
            acadCareer: 'UGRD',
            admApplNbr: '00111591'
          },
          isUndergraduate: true,
          itemStatusCode: 'C'
        }
      ]
    }
  }

  let(:new_admit_attributes_freshman) {
    {
      newAdmitAttributes: {
        roles: {
          athlete: false,
          firstYearFreshman: true,
          firstYearPathway: false,
          preMatriculated: true,
          transfer: false
        },
        admitTerm: {
          term: 2165,
          type: 'Fall'
        },
        visible: true
      }
    }
  }

  let(:new_admit_attributes_transfer) {
    {
      newAdmitAttributes: {
        roles: {
          athlete: false,
          firstYearFreshman: false,
          firstYearPathway: false,
          preMatriculated: true,
          transfer: true
        },
        admitTerm: {
          term: 2178,
          type: 'Spring'
        },
        visible: true
      }
    }
  }

  let(:new_admit_attributes_first_year_pathway) {
    {
      newAdmitAttributes: {
        roles: {
          athlete: false,
          firstYearFreshman: true,
          firstYearPathway: true,
          preMatriculated: false,
          transfer: false
        },
        admitTerm: {
          term: 2165,
          type: 'Fall'
        },
        visible: true
      }
    }
  }

  let(:new_admit_attributes_expired) {
    {
      newAdmitAttributes: {
        roles: {
          athlete: false,
          firstYearFreshman: true,
          firstYearPathway: true,
          preMatriculated: true,
          transfer: false
        },
        admitTerm: {
          term: 2178,
          type: 'Spring'
        },
        visible: false
      }
    }
  }

  let(:evaluator_response) {
    {
      'evaluator_name' => 'James P. Sullivan',
      'evaluator_email' => 'sully@monsters.inc'
    }
  }

  let(:evaluator_response_empty) {
    {
      'evaluator_name' => nil,
      'evaluator_email' => nil
    }
  }

  shared_examples 'a general response' do
    it 'has all link sections attached' do
      expect(subject[:links][:map]).to be
      expect(subject[:links][:finAid]).to be
      expect(subject[:links][:admissions]).to be
      expect(subject[:links][:firstYearPathways]).to be
      expect(subject[:links][:general]).to be
    end

    it 'has all non-dependent links attached' do
      expect(subject[:links][:map][:status][:url]).to be_truthy
      expect(subject[:links][:finAid][:finAidAwards][:url]).to be_truthy
      expect(subject[:links][:finAid][:fasoFaq][:url]).to be_truthy
      expect(subject[:links][:finAid][:summerFinAid][:url]).to be_truthy
      expect(subject[:links][:admissions][:deferral][:url]).to be_truthy
      expect(subject[:links][:general][:admissionsFaq][:url]).to be_truthy
      expect(subject[:links][:general][:calStudentCentral][:url]).to be_truthy
      expect(subject[:links][:general][:contactUgrdAdmissions][:url]).to be_truthy
    end
  end

  describe 'attempting to view new admit resources' do

    context 'as an incomplete new admit' do
      context 'as a pre-matriculated non-first-year pathway freshman with an admissions evaluator' do
        before do
          sir_statuses_incomplete_base_response[:sirStatuses][0].merge!(new_admit_attributes_freshman)
          CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_incomplete_base_response
          EdoOracle::Queries.stub(:get_new_admit_evaluator) { evaluator_response }
        end
        subject { proxy.new(uid).get_feed }
        it_behaves_like 'a general response'
        it 'removes all irrelevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsTransfer]).to be_falsey
          expect(subject[:links][:admissions][:withdrawAfterMatric]).to be_falsey
          expect(subject[:links][:firstYearPathways]).to be_empty
        end
        it 'adds all relevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsFreshman]).to be_truthy
        end
        it 'contains admissions evaluator information' do
          expect(subject[:admissionsEvaluator][:name]).to eq 'James P. Sullivan'
          expect(subject[:admissionsEvaluator][:email]).to eq 'sully@monsters.inc'
        end
      end

      context 'as a matriculated first-year pathway freshman without an admissions evaluator admitted in Fall' do
        before do
          sir_statuses_incomplete_base_response[:sirStatuses][0].merge!(new_admit_attributes_first_year_pathway)
          CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_incomplete_base_response
          EdoOracle::Queries.stub(:get_new_admit_evaluator) { evaluator_response_empty }
        end
        subject { proxy.new(uid).get_feed }
        it_behaves_like 'a general response'
        it 'removes all irrelevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsTransfer]).to be_falsey
          expect(subject[:links][:admissions][:withdrawBeforeMatric]).to be_falsey
        end
        it 'adds all relevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsFreshman]).to be_truthy
          expect(subject[:links][:admissions][:withdrawAfterMatric]).to be_truthy
          expect(subject[:links][:firstYearPathways][:selectionForm][:url]).to be_truthy
          expect(subject[:links][:firstYearPathways][:pathwaysFinAid][:url]).to be_truthy
        end
        it 'shows the fall-admit first-year-pathway financial aid link' do
          expect(subject[:links][:firstYearPathways][:pathwaysFinAid][:url]).to eq '/finances'
        end
        it 'does not contain admissions evaluator information' do
          expect(subject[:admissionsEvaluator][:name]).to be_nil
          expect(subject[:admissionsEvaluator][:email]).to be_nil
        end
      end
    end

    context 'as a completed new admit' do
      context 'as a student whose SIR card has expired' do
        before do
          sir_statuses_complete_base_response[:sirStatuses][0].merge!(new_admit_attributes_expired)
          CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_complete_base_response
          EdoOracle::Queries.stub(:get_new_admit_evaluator) { evaluator_response_empty }
        end
        subject { proxy.new(uid).get_feed }
        it 'returns a simple response indicating expiration of the card' do
          expect(subject[:visible]).to eq false
        end
      end

      context 'as a transfer student whose SIR card has not expired' do
        before do
          sir_statuses_complete_base_response[:sirStatuses][0].merge!(new_admit_attributes_transfer)
          CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_complete_base_response
          EdoOracle::Queries.stub(:get_new_admit_evaluator) { evaluator_response_empty }
        end
        subject { proxy.new(uid).get_feed }
        it_behaves_like 'a general response'
        it 'removes irrelevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsFreshman]).to be_falsey
        end
        it 'adds relevant links' do
          expect(subject[:links][:admissions][:admissionsConditionsTransfer]).to be_truthy
        end
      end

    end
  end

end
