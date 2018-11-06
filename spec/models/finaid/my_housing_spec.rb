describe FinancialAid::MyHousing do

  before do
    allow(Settings.terms).to receive(:fake_now).and_return after_spring_housing_period
    allow_any_instance_of(CampusSolutions::MyAidYears).to receive(:default_aid_year).and_return '2019'
    allow_any_instance_of(CampusSolutions::Sir::SirStatuses).to receive(:get_feed).and_return(new_admit_status)
    allow(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_STDNT_HOUSING_TYPE', {:AID_YEAR=>aid_year, :INSTITUTION=> 'UCB01'}).and_return('update housing link')
    allow(LinkFetcher).to receive(:fetch_link).with('UC_CX_FA_STDNT_HOUSING_TYPE_PW', {:AID_YEAR=>aid_year, :INSTITUTION=> 'UCB01'}).and_return('update housing/pathway link')
    allow(LinkFetcher).to receive(:fetch_link).with('UC_ADMT_FYPATH_FA_SPG').and_return('first-year pathway financial aid link')
    allow(CampusSolutions::MessageCatalog).to receive(:get_message_catalog_definition) do |msg_set_nbr, msg_nbr|
      case msg_nbr
        when '117'
          {descrlong: 'generic message'}
        when '116'
          {descrlong: 'fall pathway message'}
        when '118'
          {descrlong: 'spring pathway message'}
      end
    end
  end
  let(:during_spring_housing_period) { Concerns::DatesAndTimes.cast_utc_to_pacific(DateTime.parse('2019-04-30')) }
  let(:after_spring_housing_period) { Concerns::DatesAndTimes.cast_utc_to_pacific(DateTime.parse('2019-05-01')) }
  let(:new_admit_status) { nil }

  describe '#get_feed' do
    subject { described_class.new(uid, {aid_year: aid_year}).get_feed }
    let(:uid) { 61889 }
    let(:aid_year) { '2019' }

    it_behaves_like 'a proxy that properly observes the finaid feature flag'

    it 'returns the expected result' do
      expect(subject).to be
      expect(subject[:housing]).to be
      expect(subject[:housing].count).to eq 5
      expect(subject[:housing][:terms].count).to eq 2
      expect(subject[:housing][:instruction]).to be nil
      expect(subject[:housing][:pathwayMessage]).to be nil
      expect(subject[:housing][:links]).to be
      expect(subject[:housing][:isFallPathway]).to be_falsey

      expect(subject[:housing][:terms][0].count).to eq 6
      expect(subject[:housing][:terms][0][:termId]).to eq '2188'
      expect(subject[:housing][:terms][0][:termDescr]).to eq 'Fall 2018'
      expect(subject[:housing][:terms][0][:housingOption]).to eq 'Living Off Campus'
      expect(subject[:housing][:terms][0][:housingStatus]).to eq 'N'
      expect(subject[:housing][:terms][0][:housingEndDate]).to eq DateTime.parse('2018-10-01')
      expect(subject[:housing][:terms][0][:acadCareer]).to eq 'UGRD'

      expect(subject[:housing][:terms][1].count).to eq 6
      expect(subject[:housing][:terms][1][:termId]).to eq '2192'
      expect(subject[:housing][:terms][1][:termDescr]).to eq 'Spring 2019'
      expect(subject[:housing][:terms][1][:housingOption]).to eq 'Residence Hall'
      expect(subject[:housing][:terms][1][:housingStatus]).to eq 'N'
      expect(subject[:housing][:terms][1][:housingEndDate]).to eq DateTime.parse('2019-05-01')
      expect(subject[:housing][:terms][1][:acadCareer]).to eq 'UGRD'

      expect(subject[:housing][:links][:updateHousing]).to be nil
      expect(subject[:housing][:links][:pathwayFinaid]).to be nil
    end

    context 'when no housing data exists for aid year' do
      let(:uid) { 61889 }
      let(:aid_year) { '2016' }
      it 'returns an empty terms list' do
        expect(subject).to be
        expect(subject[:housing][:terms]).to eq []
      end
    end

    context 'when no aid year is provided' do
      let(:uid) { 61889 }
      let(:aid_year) { nil }
      it 'assumes the default aid year' do
        expect(subject).to be
        expect(subject[:housing]).to be
        expect(subject[:housing].count).to eq 5
        expect(subject[:housing][:terms].count).to eq 2
        expect(subject[:housing][:instruction]).to be nil
        expect(subject[:housing][:pathwayMessage]).to be nil
        expect(subject[:housing][:links]).to be
        expect(subject[:housing][:isFallPathway]).to be_falsey

        expect(subject[:housing][:terms][0].count).to eq 6
        expect(subject[:housing][:terms][0][:termId]).to eq '2188'
        expect(subject[:housing][:terms][0][:termDescr]).to eq 'Fall 2018'
        expect(subject[:housing][:terms][0][:housingOption]).to eq 'Living Off Campus'
        expect(subject[:housing][:terms][0][:housingStatus]).to eq 'N'
        expect(subject[:housing][:terms][0][:housingEndDate]).to eq DateTime.parse('2018-10-01')
        expect(subject[:housing][:terms][0][:acadCareer]).to eq 'UGRD'

        expect(subject[:housing][:terms][1].count).to eq 6
        expect(subject[:housing][:terms][1][:termId]).to eq '2192'
        expect(subject[:housing][:terms][1][:termDescr]).to eq 'Spring 2019'
        expect(subject[:housing][:terms][1][:housingOption]).to eq 'Residence Hall'
        expect(subject[:housing][:terms][1][:housingStatus]).to eq 'N'
        expect(subject[:housing][:terms][1][:housingEndDate]).to eq DateTime.parse('2019-05-01')
        expect(subject[:housing][:terms][1][:acadCareer]).to eq 'UGRD'

        expect(subject[:housing][:links][:updateHousing]).to be nil
        expect(subject[:housing][:links][:pathwayFinaid]).to be nil
      end
    end

    context 'when student is not an undergrad' do
      let(:uid) { 746457 }
      let(:new_admit_status) { nil }
      it 'does not provide an instruction' do
        expect(subject[:housing][:instruction]).to be nil
      end
      it 'does not provide a first year pathway suggestion message' do
        expect(subject[:housing][:pathwayMessage]).to be nil
      end
      it 'does not provide a first-year pathway financial aid link' do
        expect(subject[:housing][:links][:pathwayFinaid]).to be nil
      end
      it 'sets the fall pathway flag to false' do
        expect(subject[:housing][:isFallPathway]).to be_falsey
      end
      it 'does not provide a housing update link' do
        expect(subject[:housing][:links]).to be
        expect(subject[:housing][:links][:updateHousing]).to be nil
      end
    end

    context 'when student is an undergrad' do
      let(:uid) { 61889 }
      let(:new_admit_status) { nil }
      it 'does not provide an instruction' do
        expect(subject[:housing][:instruction]).to be nil
      end
      it 'does not provide a first year pathway suggestion message' do
        expect(subject[:housing][:pathwayMessage]).to be nil
      end
      it 'does not provide a first-year pathway financial aid link' do
        expect(subject[:housing][:links][:pathwayFinaid]).to be nil
      end
      it 'sets the fall pathway flag to false' do
        expect(subject[:housing][:isFallPathway]).to be_falsey
      end
      context 'after the latest term\'s window for changing housing has closed' do
        it 'does not provide a housing update link' do
          expect(subject[:housing][:links][:updateHousing]).to be nil
        end
      end
      context 'while the window for changing housing is still open' do
        before { allow(Settings.terms).to receive(:fake_now).and_return during_spring_housing_period }
        it 'provides a housing update link' do
          expect(subject[:housing][:links][:updateHousing]).to eq 'update housing link'
        end
      end
    end

    context 'when student is an undergrad who has already selected their housing options' do
      let(:uid) { 799934 }
      let(:new_admit_status) { nil }
      context 'while the window for changing housing is still open' do
        before { allow(Settings.terms).to receive(:fake_now).and_return during_spring_housing_period }
        it 'does not provide a housing update link' do
          expect(subject[:housing][:links][:updateHousing]).to be nil
        end
      end
    end

    context 'when student is a new admit' do
      let(:new_admit_status) do
        {
          sirStatuses: [
            {
              isUndergraduate: is_undergrad_new_admit,
              newAdmitAttributes: new_admit_attributes
            }
          ]
        }
      end
      context 'and is not an undergrad' do
        let(:uid) { 746457 }
        let(:is_undergrad_new_admit) { false }
        let(:new_admit_attributes) { nil }
        it 'does not provide an instruction' do
          expect(subject[:housing][:instruction]).to be nil
        end
        it 'does not provide links' do
          expect(subject[:housing][:links]).to be
          expect(subject[:housing][:links][:updateHousing]).to be nil
          expect(subject[:housing][:links][:pathwayFinaid]).to be nil
        end
        it 'sets the fall pathway flag to false' do
          expect(subject[:housing][:isFallPathway]).to be_falsey
        end
      end
      context 'and is an undergrad' do
        let(:uid) { 61889 }
        let(:is_undergrad_new_admit) { true }
        let(:new_admit_attributes) { nil }
        it 'provides a generic instruction' do
          expect(subject[:housing][:instruction]).to eq 'generic message'
        end
        it 'does not provide a first-year pathway financial aid link' do
          expect(subject[:housing][:links][:pathwayFinaid]).to be nil
        end
        it 'sets the fall pathway flag to false' do
          expect(subject[:housing][:isFallPathway]).to be_falsey
        end
        context 'after the latest term\'s window for changing housing has closed' do
          it 'does not provide a housing update link' do
            expect(subject[:housing][:links][:updateHousing]).to be nil
          end
        end
        context 'while the window for changing housing is still open' do
          before { allow(Settings.terms).to receive(:fake_now).and_return during_spring_housing_period }
          it 'provides a housing update link' do
            expect(subject[:housing][:links][:updateHousing]).to eq 'update housing link'
          end
        end
      end
      context 'and is a first-year pathway fall admit' do
        let(:uid) { 61889 }
        let(:is_undergrad_new_admit) { true }
        let(:new_admit_attributes) do
          {
            roles: { firstYearPathway: true },
            admitTerm: { type: 'Fall' }
          }
        end
        it 'provides a first-year pathway instruction' do
          expect(subject[:housing][:instruction]).to eq 'fall pathway message'
        end
        it 'provides a pathway-specific housing update link' do
          expect(subject[:housing][:links][:updateHousing]).to eq 'update housing/pathway link'
        end
        it 'does not provide a first-year pathway financial aid link' do
          expect(subject[:housing][:links][:pathwayFinaid]).to be nil
        end
        it 'sets the fall pathway flag to true' do
          expect(subject[:housing][:isFallPathway]).to be true
        end
      end
      context 'and is a first-year pathway spring admit' do
        let(:uid) { 61889 }
        let(:is_undergrad_new_admit) { true }
        let(:new_admit_attributes) do
          {
            roles: { firstYearPathway: true },
            admitTerm: { type: 'Spring' }
          }
        end
        it 'provides a generic instruction' do
          expect(subject[:housing][:instruction]).to eq 'generic message'
        end
        it 'provides a first year pathway suggestion message' do
          expect(subject[:housing][:pathwayMessage]).to eq 'spring pathway message'
        end
        it 'provides a first-year pathway financial aid link' do
          expect(subject[:housing][:links][:pathwayFinaid]).to eq 'first-year pathway financial aid link'
        end
        it 'sets the fall pathway flag to false' do
          expect(subject[:housing][:isFallPathway]).to be_falsey
        end
        it 'provides a pathway-specific housing update link' do
          expect(subject[:housing][:links][:updateHousing]).to eq 'update housing/pathway link'
        end
      end
    end
  end

  describe '#instance_key' do
    subject { described_class.new(uid, {aid_year: aid_year}).instance_key }
    let(:uid) { 61889 }
    let(:aid_year) { '2018' }
    it 'generates a key based on UID and aid year' do
      expect(subject).to eq '61889-2018'
    end
    context 'when no aid year provided' do
      let(:aid_year) { nil }
      it 'assumes the default aid year' do
        expect(subject).to eq '61889-2019'
      end
    end
  end
end
