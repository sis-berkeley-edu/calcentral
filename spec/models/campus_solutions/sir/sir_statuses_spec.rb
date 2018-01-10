describe CampusSolutions::Sir::SirStatuses do

  let(:uid) { 61889 }
  let(:proxy) { CampusSolutions::Sir::SirStatuses }

  let(:checklist_response_ugrd) {
    {
      feed: {
        checkListItems: [{
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            acadCareer: 'UGRD'
          },
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

  let(:checklist_response_ugrd_completed) {
    {
      feed: {
        checkListItems: [{
           chklstItemCd: 'AUSIRF',
           checkListMgmtAdmp: {
             acadCareer: 'UGRD'
           },
           itemStatus: 'Completed',
           itemStatusCode: 'C',
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
          },
          {
          chklstItemCd: 'AUSIRF',
          itemStatus: 'Completed',
          itemStatusCode: 'C',
          adminFunc: 'ADMP'
          }
        ]
      }
    }
  }

  let(:deposit_due_response) {
    {
      feed: {
        depositResponse: {
          deposit: {
            emplid: '12345678',
            admApplNbr: '11223345',
            dueDt: '2018-05-01',
            dueAmt: 250.0
          }
        }
      }
    }
  }

  let(:deposit_none_response) {
    {
      feed: {
        depositResponse: {
          deposit: {
            emplid: '12345678',
            admApplNbr: '11223345',
            dueDt: nil,
            dueAmt: 0.0
          }
        }
      }
    }
  }

  let(:new_admit_attributes_freshman_pathway) {
    {
      'applicant_program' => 'UCLS',
      'applicant_program_descr' => 'College of Letters and Science',
      'admit_status' => 'AD',
      'admit_term' => '2178',
      'admit_type' => 'FYR',
      'admit_type_desc' => 'First Year Student',
      'athlete' => 'N'
    }
  }

  let(:new_admit_attributes_transfer) {
    {
      'applicant_program' => 'UCLS',
      'applicant_program_descr' => 'College of Letters and Science',
      'admit_status' => 'APP',
      'admit_term' => '2165',
      'admit_type' => 'TRN',
      'admit_type_desc' => 'Transfer',
      'athlete' => 'N'
    }
  }

  let(:link_api_response) {
    {
      url: true
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
    context 'deposit due' do
      before do
        CampusSolutions::Sir::MyDeposit.stub_chain(:new, :get_feed).and_return  deposit_due_response
      end
      it 'correctly parses and adds deposit information' do
        expect(subject[0][:deposit]).to be
        expect(subject[0][:deposit][:required]).to be_truthy
        expect(subject[0][:deposit][:dueAmt]).to eq(250.0)
      end
    end
    context 'no deposit due' do
      before do
        CampusSolutions::Sir::MyDeposit.stub_chain(:new, :get_feed).and_return  deposit_none_response
      end
      it 'correctly parses and adds deposit information' do
        expect(subject[0][:deposit]).to be
        expect(subject[0][:deposit][:required]).to be_falsey
      end
    end
  end

  describe 'attempting to view SIR offer' do

    context 'as an undergraduate student' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_ugrd
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_ugrd
        EdoOracle::Queries.stub(:get_new_admit_status) { new_admit_attributes_freshman_pathway }
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }

      it_behaves_like 'a proper sir status'

      it 'returns an undergraduate sir application' do
        expect(subject[0][:chklstItemCd]).to eql('AUSIRF')
      end

      it 'includes new admit roles' do
        expect(subject[0][:newAdmitAttributes][:roles][:firstYearFreshman]).to eq true
        expect(subject[0][:newAdmitAttributes][:roles][:transfer]).to eq false
        expect(subject[0][:newAdmitAttributes][:roles][:athlete]).to eq false
        expect(subject[0][:newAdmitAttributes][:roles][:firstYearPathway]).to eq true
      end

      it 'includes admit term and its correct type' do
        expect(subject[0][:newAdmitAttributes][:admitTerm][:term]).to eq '2178'
        expect(subject[0][:newAdmitAttributes][:admitTerm][:type]).to eq 'Fall'
      end
    end

    context 'as an undergraduate student with an already-completed offer' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_ugrd_completed
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_ugrd
        EdoOracle::Queries.stub(:get_new_admit_status) { new_admit_attributes_freshman_pathway }
        Settings.stub(:new_admit_expiration_date).and_return('2018-02-22 12:00:00 -0700')
        DateTime.stub(:now).and_return('2018-02-21 12:00:00 -0700')

        allow_any_instance_of(LinkFetcher).to receive(:fetch_link).and_return link_api_response
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses]}

      it 'does not query for a deposit due' do
        expect(subject[0][:deposit][:required]).to be_falsey
        expect(subject[0][:deposit][:dueAmt]).to be_nil
      end

      it 'correctly sets the visibility flag' do
        expect(subject[0][:newAdmitAttributes][:visible]).to be_truthy
      end

      context 'as a freshman eligible for first year pathway' do
        it 'adds the correct links to the status' do
          expect(subject[0][:newAdmitAttributes][:links][:coaFreshmanLink][:url]).to be_truthy
          expect(subject[0][:newAdmitAttributes][:links][:firstYearPathwayLink][:url]).to be_truthy
          expect(subject[0][:newAdmitAttributes][:links][:coaTransferLink]).to be_falsey
        end
      end

      context 'as a transfer student' do
        before do
          EdoOracle::Queries.stub(:get_new_admit_status) { new_admit_attributes_transfer }
        end
        subject { (proxy.new(uid).get_feed)[:sirStatuses]}
        it 'adds the correct links to the status' do
          expect(subject[0][:newAdmitAttributes][:links][:coaFreshmanLink]).to be_falsey
          expect(subject[0][:newAdmitAttributes][:links][:firstYearPathwayLink]).to be_falsey
          expect(subject[0][:newAdmitAttributes][:links][:coaTransferLink][:url]).to be_truthy
        end
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
        expect(subject).to have(3).items
      end
    end

  end
end
