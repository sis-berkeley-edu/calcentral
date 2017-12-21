describe CampusSolutions::Sir::SirStatuses do

  let(:uid) { 61889 }
  let(:proxy) { CampusSolutions::Sir::SirStatuses }

  let(:checklist_response_ugrd) {
    {
      feed: {
        checkListItems: [{
          chklstItemCd: 'AUSIRF',
          itemStatus: 'Initiated',
          itemStatusCode: 'I',
          adminFunc: 'ADMP'
        },
        {
          someNonsense: true,
          someMoreNonsense: false
        }]
      }
    }
  }

  let(:checklist_response_law) {
    {
      feed: {
        checkListItems: [{
          chklstItemCd: 'AL0007',
          itemStatus: 'Initiated',
          itemStatusCode: 'I',
          adminFunc: 'ADMP'
        }]
      }
    }
  }

  let(:checklist_response_multiple) {
    {
      feed: {
        checkListItems: [{
           chklstItemCd: 'AL0007',
           itemStatus: 'Initiated',
           itemStatusCode: 'I',
           adminFunc: 'ADMP'
          },
          {
          chklstItemCd: 'AUSIRF',
          itemStatus: 'Initiated',
          itemStatusCode: 'I',
          adminFunc: 'ADMP'
        }]
      }
    }
  }

  let(:sir_config_response_ugrd) {
    {
      feed: {
        sirConfig: {
          sirForms: [{
           institution: 'UCB01',
           acadCareer: 'UGRD',
           ucSirFormCd: 'FRESH',
           descrProgram: 'Freshman Generic',
           descrProgramLong: 'Undergraduate Offer of Admission',
           ucSirImageCd: 'UGRD',
           descrLong: 'This is UC Berkeley\'s to indicate your Statement of Intent to Register (SIR). The process should take less than 5 minutes, and you\'ll be on your way to being a Cal Golden Bear!',
           chklstItemCd: 'AUSIRF',
           sirConditions: [1, 2, 3, 4, 5, 6, 7],
           sirOptions: ['array', 'of', 'options']
         },
         {
           institution: 'UCB01',
           acadCareer: 'PIRATE',
           chklstItemCd: 'ASDFJKL'
         }],
          responseReasons: []
        }
      }
    }
  }

  let(:sir_config_response_law) {
    {
      feed: {
        sirConfig: {
          sirForms: [{
           institution: 'UCB01',
           acadCareer: 'LAW',
           ucSirFormCd: 'ALLM02',
           descrProgram: 'Law LLM Professional',
           descrProgramLong: 'Berkeley Law LL.M.',
           ucSirImageCd: 'LAW',
           descrLong: 'Congratulations on your admission to Berkeley Law LL.M. professional track! If you have any questions, please contact the Advanced Degree Programs Office.',
           chklstItemCd: 'AL0007',
           sirConditions: [1, 2, 3, 4, 5, 6, 7],
           sirOptions: ['array', 'of', 'options']
         },
         {
           institution: 'UCB01',
           acadCareer: 'SALESMAN',
           chklstItemCd: 'SOMETHING'
         }],
          responseReasons: [{
            institution: 'UCB01',
            acadCareer: 'LAW',
            responseReason: 'SCHL',
            descr: 'Attending another school'
          },
          {
            institution: 'UCB01',
            acadCareer: 'LAW',
            responseReason: 'MIL',
            descr: 'Military'
          },
          {
            institution: 'UCB01',
            acadCareer: 'GRAD',
            responseReason: 'SCHL',
            descr: 'Attending another school'
          }]
        }
      }
    }
  }

  let(:sir_config_response_multiple) {
    {
      feed: {
        sirConfig: {
          sirForms: [{
             institution: 'UCB01',
             acadCareer: 'UGRD',
             ucSirFormCd: 'FRESH',
             descrProgram: 'Freshman Generic',
             descrProgramLong: 'Undergraduate Offer of Admission',
             ucSirImageCd: 'UGRD',
             descrLong: 'This is UC Berkeley\'s to indicate your Statement of Intent to Register (SIR). The process should take less than 5 minutes, and you\'ll be on your way to being a Cal Golden Bear!',
             chklstItemCd: 'AUSIRF',
             sirConditions: [1, 2, 3, 4, 5, 6, 7],
             sirOptions: ['array', 'of', 'options']
            },
            {
            institution: 'UCB01',
            acadCareer: 'LAW',
            ucSirFormCd: 'ALLM02',
            descrProgram: 'Law LLM Professional',
            descrProgramLong: 'Berkeley Law LL.M.',
            ucSirImageCd: 'LAW',
            descrLong: 'Congratulations on your admission to Berkeley Law LL.M. professional track! If you have any questions, please contact the Advanced Degree Programs Office.',
            chklstItemCd: 'AL0007',
            sirConditions: [1, 2, 3, 4, 5, 6, 7],
            sirOptions: ['array', 'of', 'options']
            }],
          responseReasons: []
        }
      }
    }
  }

  shared_examples 'a proper sir status' do
    it 'returns an actual SIR status' do
      expect(subject).to have(1).items
    end
    it 'returns the relevant checklist items, and filters out the irrelevant' do
      expect(subject[0][:adminFunc]).to eql('ADMP')
    end
    it 'maps to the correct sir configuration item' do
      expect(subject[0][:chklstItemCd]). to eql(subject[0][:config][:chklstItemCd])
    end
    it 'attaches header info' do
      expect(subject[0][:header]).to be
    end
  end

  describe 'attempting to view SIR offer' do

    context 'as an undergraduate student' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_ugrd
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_ugrd
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }

      it_behaves_like 'a proper sir status'

      it 'returns an undergraduate sir application' do
        expect(subject[0][:chklstItemCd]).to eql('AUSIRF')
      end
    end

    context 'as a law student' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_law
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_law
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }
      it_behaves_like 'a proper sir status'

      it 'returns a law sir application' do
        expect(subject[0][:chklstItemCd]).to eql('AL0007')
      end

      it 'maps to the correct response reasons, and filters out the irrelevant' do
        expect(subject[0][:responseReasons]).to have(2).items
        expect(subject[0][:responseReasons][0][:acadCareer]).to eql('LAW')
        expect(subject[0][:responseReasons][1][:acadCareer]).to eql('LAW')
      end
    end

    context 'as a student with multiple offers' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_multiple
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_multiple
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }
      it 'returns multiple sir applications' do
        expect(subject).to have(2).items
      end
    end

  end



end
