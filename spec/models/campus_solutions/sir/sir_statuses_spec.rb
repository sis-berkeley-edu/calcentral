describe CampusSolutions::Sir::SirStatuses do
  let(:uid) { 61889 }
  let(:proxy) { CampusSolutions::Sir::SirStatuses }

  let(:checklist_response_ugrd) {
    {
      feed: {
        checkListItems: [{
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            acadCareer: 'UGRD',
            admApplNbr: '00157689'
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
          checkListMgmtAdmp: {
            acadCareer: 'LAW',
            admApplNbr: '00157689'
          },
          itemStatus: 'Initiated',
          itemStatusCode: 'I',
          adminFunc: 'ADMP'
        }]
      }
    }
  }

  let(:checklist_response_law_completed) {
    {
      feed: {
        checkListItems: [{
         chklstItemCd: 'AL0007',
         checkListMgmtAdmp: {
           acadCareer: 'LAW',
           admApplNbr: '00157692'
         },
         itemStatus: 'Initiated',
         itemStatusCode: 'C',
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
             acadCareer: 'UGRD',
             admApplNbr: '00157689'
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
           checkListMgmtAdmp: {
             acadCareer: 'UGRD',
             admApplNbr: '00157689'
           },
           itemStatus: 'Initiated',
           itemStatusCode: 'I',
           adminFunc: 'ADMP'
          },
          {
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            acadCareer: 'UGRD',
            admApplNbr: '00157690'
          },
          itemStatus: 'Initiated',
          itemStatusCode: 'I',
          adminFunc: 'ADMP'
          },
         {
           chklstItemCd: 'AL0007',
           checkListMgmtAdmp: {
             acadCareer: 'LAW',
             admApplNbr: '00157695'
           },
           itemStatus: 'Initiated',
           itemStatusCode: 'I',
           adminFunc: 'ADMP'
         },
          {
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            acadCareer: 'UGRD',
            admApplNbr: '00157691'
          },
          itemStatus: 'Completed',
          itemStatusCode: 'C',
          adminFunc: 'ADMP'
          }
        ]
      }
    }
  }

  let(:checklist_response_duplicate_ugrd) {
    {
      feed: {
        checkListItems: [
          {
           chklstItemCd: 'AUSIRF',
           checkListMgmtAdmp: {
             acadCareer: 'UGRD',
             admApplNbr: '00157689'
           },
           itemStatus: 'Completed',
           itemStatusCode: 'C',
           adminFunc: 'ADMP',
           checklistSeq: 100
          },
          {
            chklstItemCd: 'AUSIRF',
            checkListMgmtAdmp: {
              acadCareer: 'UGRD',
              admApplNbr: '00157689'
            },
            itemStatus: 'Completed',
            itemStatusCode: 'C',
            adminFunc: 'ADMP',
            checklistSeq: 200
          }
        ]
      }
    }
  }

  let(:checklist_response_duplicate_law) {
    {
      feed: {
        checkListItems: [
          {
            chklstItemCd: 'AL0007',
            checkListMgmtAdmp: {
              acadCareer: 'LAW',
              admApplNbr: '00157695'
            },
            itemStatus: 'Completed',
            itemStatusCode: 'C',
            adminFunc: 'ADMP',
            checklistSeq: 100
          },
          {
            chklstItemCd: 'AL0007',
            checkListMgmtAdmp: {
              acadCareer: 'LAW',
              admApplNbr: '00157695'
            },
            itemStatus: 'Completed',
            itemStatusCode: 'C',
            adminFunc: 'ADMP',
            checklistSeq: 200
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

  let(:new_admit_attributes_freshman_pathway_sid) { 12345678 }
  let(:new_admit_attributes_freshman_pathway_gep_sid) { 12345679 }
  let(:new_admit_attributes_transfer_sid) { 12345680 }
  let(:multiple_sir_offers_sid) { 12345681 }
  let(:new_admit_attributes_law_completed_sid) { 12345682 }

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
           sirOptions: [{ progAction: 'WAPP', messageText: 'Here is the wrong law message' }, { progAction: 'DEIN', messageText: 'Here is the law message!' }]
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

  let(:before_expiration_date) { DateTime.parse('1901-01-01 00:00:00 -0700') }
  let(:after_expiration_date) { DateTime.parse('2099-01-01 00:00:00 -0700') }

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
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }

      context 'when edodb is unavailable' do
        before do
          allow(EdoOracle::Queries).to receive(:get_new_admit_data).and_return nil
        end

        it 'returns an empty array' do
          expect(subject).to eql([])
        end
      end

      context 'when new admit status is provided' do
        before do
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_freshman_pathway_sid
        end

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
          expect(subject[0][:newAdmitAttributes][:admitTerm][:term]).to eq '2185'
          expect(subject[0][:newAdmitAttributes][:admitTerm][:type]).to eq 'Summer'
        end
      end
    end

    context 'as an undergraduate student with an already-completed offer' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_ugrd_completed
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_ugrd
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_freshman_pathway_sid
        allow(Settings.terms).to receive(:fake_now).and_return before_expiration_date
        allow_any_instance_of(LinkFetcher).to receive(:fetch_link).and_return link_api_response
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses]}

      it 'does not query for a deposit due' do
        expect(subject[0][:deposit][:required]).to be_falsey
        expect(subject[0][:deposit][:dueAmt]).to be_nil
      end

      context 'as a freshman eligible for first year pathway' do
        it 'adds the correct links to the status' do
          expect(subject[0][:newAdmitAttributes][:links][:coaFreshmanLink][:url]).to be_truthy
          expect(subject[0][:newAdmitAttributes][:links][:firstYearPathwayLink][:url]).to be_truthy
          expect(subject[0][:newAdmitAttributes][:links][:coaTransferLink]).to be_falsey
        end
      end

      context 'as a freshman eligible for first year pathway admitted to the Global Edge Program' do
        before do
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_freshman_pathway_gep_sid
        end
        subject { (proxy.new(uid).get_feed)[:sirStatuses] }
        it 'denies first year pathway status due to GEP' do
          expect(subject[0][:newAdmitAttributes][:roles][:firstYearPathway]).to be_falsey
        end
        it 'adds the correct links to the status' do
          expect(subject[0][:newAdmitAttributes][:links][:coaFreshmanLink][:url]).to be_truthy
          expect(subject[0][:newAdmitAttributes][:links][:firstYearPathwayLink]).to be_falsey
          expect(subject[0][:newAdmitAttributes][:links][:coaTransferLink]).to be_falsey
        end
      end

      context 'as a transfer student' do
        before do
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_transfer_sid
        end
        subject { (proxy.new(uid).get_feed)[:sirStatuses] }
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

    context 'as a law student with a completed offer' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_law_completed
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_law
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_law_completed_sid
      end
      subject { (proxy.new(uid).get_feed[:sirStatuses]) }

      it 'adds sirCompletedAction and sirCompletedMessage properties to the status' do
        expect(subject[0][:sirCompletedAction]).to eql('DEIN')
        expect(subject[0][:sirCompletedMessage]).to eql('Here is the law message!')
      end
      it 'does not make the MyDeposit proxy call' do
        expect(CampusSolutions::Sir::MyDeposit).not_to receive(:new)
      end
    end

    context 'as a student with multiple offers' do
      before do
        CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_multiple
        CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_multiple
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return multiple_sir_offers_sid
      end
      subject { (proxy.new(uid).get_feed)[:sirStatuses] }
      it 'returns multiple sir applications' do
        expect(subject).to have(4).items
      end
    end

    context 'as a student with duplicate offers' do
      context 'duplicate law offers' do
        before do
          CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_duplicate_law
          CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_law
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return multiple_sir_offers_sid
        end
        subject { (proxy.new(uid).get_feed[:sirStatuses]) }
        it 'removes duplicate checklist items' do
          expect(subject).to have(1).items
        end
        it 'keeps the item with the highest checklist_seq' do
          expect(subject[0][:checklistSeq]).to eql(200)
        end
      end

      context 'duplicate non-law offers' do
        before do
          CampusSolutions::MyChecklist.stub_chain(:new, :get_feed).and_return checklist_response_duplicate_ugrd
          CampusSolutions::Sir::SirConfig.stub_chain(:new, :get).and_return sir_config_response_ugrd
          allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return new_admit_attributes_freshman_pathway_sid
        end
        subject { (proxy.new(uid).get_feed[:sirStatuses]) }
        it 'does not remove any duplicate items' do
          expect(subject).to have(2).items
        end
      end
    end

  end
end
