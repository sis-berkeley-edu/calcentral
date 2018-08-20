describe FinancialAid::MyFinancialAidSummary do
  before do
    allow_any_instance_of(CampusSolutions::MyAidYears).to receive(:get_feed).and_return aid_years
    allow_any_instance_of(CampusSolutions::Sir::SirStatuses).to receive(:get_feed).and_return(new_admit_status)
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_SHOPPING_SHEET', {AID_YEAR: '2017', ACAD_CAREER: 'UGRD', INSTITUTION: 'UCB01', SFA_SS_GROUP: 'CCUGRD'}).and_return('2017 shopping sheet link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_SHOPPING_SHEET', {AID_YEAR: '2018', ACAD_CAREER: 'UGRD', INSTITUTION: 'UCB01', SFA_SS_GROUP: 'CCUGRD'}).and_return('2018 shopping sheet link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_UCB_FA_WEBSITE').and_return('finaid website link')
    allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_CAL_STUDENT_CENTRAL').and_return('cal student central link')
  end
  let(:aid_years) do
    {
      feed: {
        finaidSummary: {
          finaidYears: [
            {
              id: '2017',
              default: true
            },
            {
              id: '2018'
            },
          ]
        }
      }
    }
  end
  let(:new_admit_status) { nil }

  describe '#get_feed' do
    subject { described_class.new(uid).get_feed }
    let(:uid) { 61889 }

    it_behaves_like 'a proxy that properly observes the finaid feature flag'

    it 'returns the summary for each aid year' do
      expect(subject).to be
      expect(subject[:financialAidSummary]).to be
      expect(subject[:financialAidSummary][:aidYears]).to be
      expect(subject[:financialAidSummary][:aidYears].count).to eq 2
      expect(subject[:financialAidSummary][:aid]).to be

      expect(subject[:financialAidSummary][:aid]['2017']).to be
      expect(subject[:financialAidSummary][:aid]['2017'][:totalCostOfAttendance]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalGiftAidAndWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalNetCost]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:totalFundingOffered]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:giftAidAndOutsideResources]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:grantsAndScholarships]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:waiversAndOtherFunding]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:feeWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:loansAndWorkStudy]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:loans]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2017'][:workStudy]).to be_a Float

      expect(subject[:financialAidSummary][:aid]['2018']).to be
      expect(subject[:financialAidSummary][:aid]['2018'][:totalCostOfAttendance]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalGiftAidAndWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalNetCost]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:totalFundingOffered]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:giftAidAndOutsideResources]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:grantsAndScholarships]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:waiversAndOtherFunding]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:feeWaivers]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:loansAndWorkStudy]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:loans]).to be_a Float
      expect(subject[:financialAidSummary][:aid]['2018'][:workStudy]).to be_a Float
    end
    it 'provides the expected links' do
      expect(subject[:financialAidSummary][:links]).to be
      expect(subject[:financialAidSummary][:links].count).to eq 2
      expect(subject[:financialAidSummary][:links][:financialAidWebsite]).to eq 'finaid website link'
      expect(subject[:financialAidSummary][:links][:calStudentCentral]).to eq 'cal student central link'
    end
    it 'does not provide a link to the Shopping Sheet' do
      expect(subject[:financialAidSummary][:aid]['2017'][:shoppingSheetLink]).not_to be
      expect(subject[:financialAidSummary][:aid]['2018'][:shoppingSheetLink]).not_to be
    end

    context 'when user is an Undergrad new admit' do
      let(:new_admit_status) do
        {
          sirStatuses: [
            {
              isUndergraduate: true,
              newAdmitAttributes: new_admit_attributes
            }
          ]
        }
      end
      context 'and has no financial aid for their admit year' do
        let(:new_admit_attributes) do
          {
            term: { term: '2168' }
          }
        end
        it 'does not provide a link to the Shopping Sheet' do
          expect(subject[:financialAidSummary][:aid]['2017'][:shoppingSheetLink]).not_to be
          expect(subject[:financialAidSummary][:aid]['2018'][:shoppingSheetLink]).not_to be
        end
        context 'and has financial aid for their admit year' do
          let(:new_admit_attributes) do
            {
              term: { term: '2188' }
            }
          end
          it 'provides a link to the Shopping Sheet for the admit year only' do
            expect(subject[:financialAidSummary][:aid]['2017'][:shoppingSheetLink]).not_to be
            expect(subject[:financialAidSummary][:aid]['2018'][:shoppingSheetLink]).to eq '2018 shopping sheet link'
          end
        end
      end
    end
  end
end
