describe CampusSolutions::FinancialAidHousing do
  subject { CampusSolutions::FinancialAidHousing.append_housing(uid, feed) }
  let(:uid) { random_id }
  let(:undergrad) { false }
  let(:non_degree_undergrad) { false }
  let(:raw_feed) { {:feed => {}} }
  let(:feed_with_housing) do
    {
      :feed => {
        :housing => {
          title: 'Housing',
          values: housing_values,
          link: {
            url: 'https://bcs.example.com/housing_update/',
            title: 'Update',
            isCsLink: true
          }
        }
      }
    }
  end
  let(:housing_values) do
    [
      {"subvalue"=>["Fall", "Housing - Living Off Campus"]},
      {"subvalue"=>["Spring", "Housing - Living Off Campus"]}
    ]
  end
  let(:message_catalog_definition) { {descrlong: 'generic message'} }
  let(:spring_first_year_pathway_link) do
    {
      url: 'http://financialaid.berkeley.edu/newly-admitted-student-pathways',
      urlId: 'UC_ADMT_FYPATH_FA_SPG',
      linkDescription: 'Estimating your financial aid and scholarships based on your pathway choice.',
      linkDescriptionDisplay: true,
      showNewWindow: true,
      name: 'First-Year Pathways Financial Aid',
      title: 'First-Year Pathways Financial Aid'
    }
  end

  before do
    allow_any_instance_of(User::AggregatedAttributes).to receive(:get_feed).and_return({ :roles => { :undergrad => undergrad }})
    allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return({ 'ugrdNonDegree' => non_degree_undergrad })
    allow(LinkFetcher).to receive(:fetch_link).with('UC_ADMT_FYPATH_FA_SPG').and_return(spring_first_year_pathway_link)
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

  describe '#append_housing' do
    context 'when housing data not present within feed' do
      let(:feed) { raw_feed }
      it 'returns feed' do
        expect(subject).to have_key(:feed)
        expect(subject[:feed]).to_not have_key(:housing)
      end
    end

    context 'when housing data present within feed' do
      let(:feed) { feed_with_housing }
      context 'when sir statuses not present (non-ugrd)' do
        let(:sir_statuses) { nil }
        it 'excludes generic housing instructional message' do
          expect(subject[:feed][:housing][:instruction]).to be nil
        end
        it 'excludes housing update link' do
          expect(subject[:feed][:housing][:link]).to be nil
        end
        context 'when user is continuing undergrad' do
          let(:undergrad) { true }
          it 'includes housing update link' do
            expect(subject[:feed][:housing][:link]).to be
            expect(subject[:feed][:housing][:link][:name]).to eq 'Update Housing'
            expect(subject[:feed][:housing][:link][:title]).to eq 'Update Housing'
            expect(subject[:feed][:housing][:link][:url]).to eq 'https://bcs.example.com/housing_update/'
          end
        end
      end
      context 'when sir statuses present' do
        before { allow_any_instance_of(CampusSolutions::Sir::SirStatuses).to receive(:get_feed).and_return(sir_statuses_feed) }
        let(:admit_term) { {term: '2168', type: 'Fall'} }
        let(:sir_statuses_feed) do
          {
            sirStatuses: sir_statuses
          }
        end
        context 'when ugrd status not present' do
          let(:sir_statuses) { [{isUndergraduate: false}] }
          it 'excludes generic housing instructional message' do
            expect(subject[:feed][:housing][:instruction]).to be nil
          end
          it 'excludes housing update link' do
            expect(subject[:feed][:housing][:link]).to be nil
          end
          context 'when user is continuing undergrad' do
            let(:undergrad) { true }
            it 'includes housing update link' do
              expect(subject[:feed][:housing][:link]).to be
              expect(subject[:feed][:housing][:link][:name]).to eq 'Update Housing'
              expect(subject[:feed][:housing][:link][:title]).to eq 'Update Housing'
              expect(subject[:feed][:housing][:link][:url]).to eq 'https://bcs.example.com/housing_update/'
            end
          end
        end
        context 'when ugrd status present' do
          let(:sir_statuses) do
            [{isUndergraduate: true, newAdmitAttributes: new_admit_attributes}]
          end
          let(:is_visible) { false }
          let(:is_athlete) { false }
          let(:is_transfer) { false }
          let(:is_first_year_freshman) { true }
          let(:is_first_year_pathway) { false }
          let(:is_prematriculated) { false }
          let(:coa_freshman_link) { false }
          let(:coa_transfer_link) { false }
          let(:first_year_pathway_link) { false }
          let(:new_admit_attributes) do
            {
              roles: {
                athlete: is_athlete,
                transfer: is_transfer,
                firstYearFreshman: is_first_year_freshman,
                firstYearPathway: is_first_year_pathway,
                preMatriculated: is_prematriculated
              },
              admitTerm: admit_term,
              visible: is_visible,
              links: {
                coaFreshmanLink: coa_freshman_link,
                coaTransferLink: coa_transfer_link,
                firstYearPathwayLink: first_year_pathway_link
              }
            }
          end

          context 'when user is not pathways eligible' do
            let(:is_first_year_pathway) { false }
            it 'includes generic housing instructional message' do
              expect(subject[:feed][:housing][:instruction]).to be
              expect(subject[:feed][:housing][:instruction][:descrlong]).to eq 'generic message'
            end
            it 'includes housing update link' do
              expect(subject[:feed][:housing][:link]).to be
              expect(subject[:feed][:housing][:link][:name]).to eq 'Update Housing'
              expect(subject[:feed][:housing][:link][:title]).to eq 'Update Housing'
              expect(subject[:feed][:housing][:link][:url]).to eq 'https://bcs.example.com/housing_update/'
            end
            it 'includes default housing card title' do
              expect(subject[:feed][:housing][:title]).to eq 'Housing'
            end
          end

          context 'when user is pathways eligible new admit' do
            let(:is_first_year_pathway) { true }

            context 'when admit term is fall' do
              let(:admit_term) { {term: '2188', type: 'Fall'} }
              it 'includes pathways housing instructional message' do
                expect(subject[:feed][:housing][:instruction]).to be
                expect(subject[:feed][:housing][:instruction][:descrlong]).to eq 'fall pathway message'
              end
              it 'includes housing/pathways update link' do
                expect(subject[:feed][:housing][:link]).to be
                expect(subject[:feed][:housing][:link][:name]).to eq 'Update Housing / Pathway'
                expect(subject[:feed][:housing][:link][:title]).to eq 'Update Housing or First-Year Pathway'
                expect(subject[:feed][:housing][:link][:url]).to eq 'https://bcs.example.com/housing_update/'
              end
              it 'includes housing/pathways card title' do
                expect(subject[:feed][:housing][:title]).to eq 'Housing or Pathway'
              end
            end
            context 'when admit term is spring' do
              let(:admit_term) { {term: '2182', type: 'Spring'} }
              it 'includes spring pathways housing instructional message' do
                expect(subject[:feed][:housing][:instruction]).to be
                expect(subject[:feed][:housing][:instruction][:descrlong]).to eq 'generic message'
              end
              it 'includes housing update link' do
                expect(subject[:feed][:housing][:link]).to be
                expect(subject[:feed][:housing][:link][:name]).to eq 'Update Housing'
                expect(subject[:feed][:housing][:link][:title]).to eq 'Update Housing'
                expect(subject[:feed][:housing][:link][:url]).to eq 'https://bcs.example.com/housing_update/'
              end
              it 'includes first year pathway suggestion message' do
                expect(subject[:feed][:housing][:pathways_message][:descrlong]).to eq 'spring pathway message'
              end
              it 'includes first-year pathways financial aid link' do
                expect(subject[:feed][:housing][:pathways_link]).to be
                expect(subject[:feed][:housing][:pathways_link][:name]).to eq 'First-Year Pathways Financial Aid'
                expect(subject[:feed][:housing][:pathways_link][:title]).to eq 'First-Year Pathways Financial Aid'
                expect(subject[:feed][:housing][:pathways_link][:url]).to eq 'http://financialaid.berkeley.edu/newly-admitted-student-pathways'
              end
              it 'includes default housing card title' do
                expect(subject[:feed][:housing][:title]).to eq 'Housing'
              end
            end
          end
        end
      end
    end
  end
end
