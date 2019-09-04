describe FinancialAid::MyFinaidProfile do
  let(:uid) { 61889 }
  let(:aid_year) { 2018 }

  before do
    allow_any_instance_of(FinancialAid::MyAidYears).to receive(:default_aid_year).and_return '2019'
  end

  describe '#get_feed' do
    subject { described_class.new(uid, {aid_year: aid_year}).get_feed }

    it_behaves_like 'a proxy that properly observes the financial_aid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:finaidProfile]).to be
      expect(subject[:finaidProfile].count).to eq 3
      expect(subject[:finaidProfile][:aidYear]). to eq '2018'
      expect(subject[:finaidProfile][:message]).to eq 'We take many factors into consideration when determining your funding package. Updates made elsewhere to your personal information may affect the amount of aid provided to you.'
      expect(subject[:finaidProfile][:itemGroups][0][0][:title]).to eq 'Academic Career'
      expect(subject[:finaidProfile][:itemGroups][0][0][:values][0][:subvalue][0]).to eq 'Fall 2017'
      expect(subject[:finaidProfile][:itemGroups][0][0][:values][0][:subvalue][1]).to eq 'Undergraduate'
      expect(subject[:finaidProfile][:itemGroups][0][0][:values][1][:subvalue][0]).to eq 'Spring 2018'
      expect(subject[:finaidProfile][:itemGroups][0][0][:values][1][:subvalue][1]).to eq 'Graduate'
      expect(subject[:finaidProfile][:itemGroups][1][0][:title]).to eq 'Level'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][0][:subvalue][0]).to eq 'Fall 2017'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][0][:subvalue][1]).to eq '3rd Year'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][1][:subvalue][0]).to eq 'Spring 2018'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][1][:subvalue][1]).to eq '3rd Year'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][2][:subvalue][0]).to eq 'Summer 2018'
      expect(subject[:finaidProfile][:itemGroups][1][0][:values][2][:subvalue][1]).to eq '4th Year'
      expect(subject[:finaidProfile][:itemGroups][1][1][:title]).to eq 'Expected Graduation'
      expect(subject[:finaidProfile][:itemGroups][1][1][:value]).to eq 'Spring 2019'
      expect(subject[:finaidProfile][:itemGroups][2][0][:title]).to eq 'Candidacy'
      expect(subject[:finaidProfile][:itemGroups][2][0][:value]).to eq nil
      expect(subject[:finaidProfile][:itemGroups][2][1][:title]).to eq 'Filing Fee Status'
      expect(subject[:finaidProfile][:itemGroups][2][1][:value]).to eq nil
      expect(subject[:finaidProfile][:itemGroups][3][0][:title]).to eq 'SAP Status'
      expect(subject[:finaidProfile][:itemGroups][3][0][:value]).to eq 'Meeting Satis Acad Progress'
      expect(subject[:finaidProfile][:itemGroups][3][1][:title]).to eq 'Award Status'
      expect(subject[:finaidProfile][:itemGroups][3][1][:value]).to eq 'Packaged'
      expect(subject[:finaidProfile][:itemGroups][3][2][:title]).to eq 'Verification Status'
      expect(subject[:finaidProfile][:itemGroups][3][2][:value]).to eq 'Verified'
      expect(subject[:finaidProfile][:itemGroups][4][0][:title]).to eq 'Dependency Status'
      expect(subject[:finaidProfile][:itemGroups][4][0][:value]).to eq 'Independent'
      expect(subject[:finaidProfile][:itemGroups][4][1][:title]).to eq 'Expected Family Contribution (EFC)'
      expect(subject[:finaidProfile][:itemGroups][4][1][:value]).to eq '$425'
      expect(subject[:finaidProfile][:itemGroups][4][2][:title]).to eq 'Berkeley Parent Contribution'
      expect(subject[:finaidProfile][:itemGroups][4][2][:value]).to eq '$0'
      expect(subject[:finaidProfile][:itemGroups][4][3][:title]).to eq 'Summer EFC'
      expect(subject[:finaidProfile][:itemGroups][4][3][:value]).to eq '$0'
      expect(subject[:finaidProfile][:itemGroups][4][4][:title]).to eq 'Family Members in College'
      expect(subject[:finaidProfile][:itemGroups][4][4][:value]).to eq '1'
      expect(subject[:finaidProfile][:itemGroups][5][0][:title]).to eq 'Residency'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][0][:subvalue][0]).to eq 'Fall 2017'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][0][:subvalue][1]).to eq 'Resident'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][1][:subvalue][0]).to eq 'Spring 2018'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][1][:subvalue][1]).to eq 'Resident'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][2][:subvalue][0]).to eq 'Summer 2018'
      expect(subject[:finaidProfile][:itemGroups][5][0][:values][2][:subvalue][1]).to eq 'Resident'
      expect(subject[:finaidProfile][:itemGroups][6][0][:title]).to eq 'Enrollment'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][0][:subvalue][0]).to eq 'Fall 2017'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][0][:subvalue][1]).to eq '12 Units'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][1][:subvalue][0]).to eq 'Spring 2018'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][1][:subvalue][1]).to eq '12 Units'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][2][:subvalue][0]).to eq 'Summer 2018'
      expect(subject[:finaidProfile][:itemGroups][6][0][:values][2][:subvalue][1]).to eq '7 Units'
      expect(subject[:finaidProfile][:itemGroups][7][0][:title]).to eq 'SHIP (Student Health Insurance Program)'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][0][:subvalue][0]).to eq 'Fall 2017'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][0][:subvalue][1]).to eq 'Enrolled'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][1][:subvalue][0]).to eq 'Spring 2018'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][1][:subvalue][1]).to eq 'Enrolled'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][2][:subvalue][0]).to eq 'Summer 2018'
      expect(subject[:finaidProfile][:itemGroups][7][0][:values][2][:subvalue][1]).to eq 'Enrolled'
    end

    context 'when no finaid profile data exists for aid year' do
      let(:aid_year) { '1999' }
      it 'returns an empty feed' do
        expect(subject).not_to be
      end
    end

    context 'when no aid year is provided' do
      let(:aid_year) { nil }
      it 'assumes the default aid year' do
        expect(subject).to be
        expect(subject[:finaidProfile]).to be
        expect(subject[:finaidProfile].count).to eq 3
        expect(subject[:finaidProfile][:aidYear]). to eq '2019'
        expect(subject[:finaidProfile][:message]).to eq 'We take many factors into consideration when determining your funding package. Updates made elsewhere to your personal information may affect the amount of aid provided to you.'
        expect(subject[:finaidProfile][:itemGroups][0][0][:title]).to eq 'Academic Career'
        expect(subject[:finaidProfile][:itemGroups][0][0][:value]).to eq 'Undergraduate'
        expect(subject[:finaidProfile][:itemGroups][1][0][:title]).to eq 'Level'
        expect(subject[:finaidProfile][:itemGroups][1][0][:values][0][:subvalue][0]).to eq 'Fall 2018'
        expect(subject[:finaidProfile][:itemGroups][1][0][:values][0][:subvalue][1]).to eq '4th Year'
        expect(subject[:finaidProfile][:itemGroups][1][0][:values][1][:subvalue][0]).to eq 'Spring 2019'
        expect(subject[:finaidProfile][:itemGroups][1][0][:values][1][:subvalue][1]).to eq '4th Year'
        expect(subject[:finaidProfile][:itemGroups][1][1][:title]).to eq 'Expected Graduation'
        expect(subject[:finaidProfile][:itemGroups][1][1][:value]).to eq 'Spring 2019'
        expect(subject[:finaidProfile][:itemGroups][2][0][:title]).to eq 'Candidacy'
        expect(subject[:finaidProfile][:itemGroups][2][0][:value]).to eq nil
        expect(subject[:finaidProfile][:itemGroups][2][1][:title]).to eq 'Filing Fee Status'
        expect(subject[:finaidProfile][:itemGroups][2][1][:value]).to eq nil
        expect(subject[:finaidProfile][:itemGroups][3][0][:title]).to eq 'SAP Status'
        expect(subject[:finaidProfile][:itemGroups][3][0][:value]).to eq 'Meeting Satis Acad Progress'
        expect(subject[:finaidProfile][:itemGroups][3][1][:title]).to eq 'Award Status'
        expect(subject[:finaidProfile][:itemGroups][3][1][:value]).to eq 'Packaged'
        expect(subject[:finaidProfile][:itemGroups][3][2][:title]).to eq 'Verification Status'
        expect(subject[:finaidProfile][:itemGroups][3][2][:value]).to eq 'Verified'
        expect(subject[:finaidProfile][:itemGroups][4][0][:title]).to eq 'Dependency Status'
        expect(subject[:finaidProfile][:itemGroups][4][0][:value]).to eq 'Independent'
        expect(subject[:finaidProfile][:itemGroups][4][1][:title]).to eq 'Expected Family Contribution (EFC)'
        expect(subject[:finaidProfile][:itemGroups][4][1][:value]).to eq '$0'
        expect(subject[:finaidProfile][:itemGroups][4][2][:title]).to eq 'Berkeley Parent Contribution'
        expect(subject[:finaidProfile][:itemGroups][4][2][:value]).to eq '$0'
        expect(subject[:finaidProfile][:itemGroups][4][3][:title]).to eq 'Summer EFC'
        expect(subject[:finaidProfile][:itemGroups][4][3][:value]).to eq nil
        expect(subject[:finaidProfile][:itemGroups][4][4][:title]).to eq 'Family Members in College'
        expect(subject[:finaidProfile][:itemGroups][4][4][:value]).to eq '2'
        expect(subject[:finaidProfile][:itemGroups][5][0][:title]).to eq 'Residency'
        expect(subject[:finaidProfile][:itemGroups][5][0][:values][0][:subvalue][0]).to eq 'Fall 2018'
        expect(subject[:finaidProfile][:itemGroups][5][0][:values][0][:subvalue][1]).to eq 'Resident'
        expect(subject[:finaidProfile][:itemGroups][5][0][:values][1][:subvalue][0]).to eq 'Spring 2019'
        expect(subject[:finaidProfile][:itemGroups][5][0][:values][1][:subvalue][1]).to eq 'Resident'
        expect(subject[:finaidProfile][:itemGroups][6][0][:title]).to eq 'Enrollment'
        expect(subject[:finaidProfile][:itemGroups][6][0][:values][0][:subvalue][0]).to eq 'Fall 2018'
        expect(subject[:finaidProfile][:itemGroups][6][0][:values][0][:subvalue][1]).to eq '12 Units'
        expect(subject[:finaidProfile][:itemGroups][6][0][:values][1][:subvalue][0]).to eq 'Spring 2019'
        expect(subject[:finaidProfile][:itemGroups][6][0][:values][1][:subvalue][1]).to eq '16 Units'
        expect(subject[:finaidProfile][:itemGroups][7][0][:title]).to eq 'SHIP (Student Health Insurance Program)'
        expect(subject[:finaidProfile][:itemGroups][7][0][:values][0][:subvalue][0]).to eq 'Fall 2018'
        expect(subject[:finaidProfile][:itemGroups][7][0][:values][0][:subvalue][1]).to eq 'Enrolled'
        expect(subject[:finaidProfile][:itemGroups][7][0][:values][1][:subvalue][0]).to eq 'Spring 2019'
        expect(subject[:finaidProfile][:itemGroups][7][0][:values][1][:subvalue][1]).to eq 'Enrolled'
      end
    end
  end
end
