describe MyAcademics::MyStandings do

  let(:standings_response) {
    [
      {
        'acad_standing_status' => 'GST',
        'acad_standing_status_descr'=>  'Good Standing',
        'acad_standing_action_descr'=> 'Probation Ended',
        'term_id' => '2148',
        'action_date'=> DateTime.parse('07-AUG-14')
      },
      {
        'acad_standing_status' => 'DIS',
        'acad_standing_status_descr'=> 'Dismissed',
        'acad_standing_action_descr'=> 'Dismissed (2.0 Rule)',
        'term_id' => '2198',
        'action_date'=> DateTime.parse('07-AUG-19')
      },
      {
        'acad_standing_status' => 'AP',
        'acad_standing_status_descr'=> 'Probation',
        'acad_standing_action_descr'=> 'Academic Probation',
        'term_id' => '2158',
        'action_date'=> DateTime.parse('07-AUG-15')
      }
    ]
  }

  describe '#get_feed_internal' do
    subject { described_class.new(random_id).get_feed_internal }

    shared_examples 'a model receiving no data' do
      it 'returns an empty response' do
        expect(subject).to be
        expect(subject[:feed]).to be
        expect(subject[:feed][:currentStandings]).to eq []
        expect(subject[:feed][:standingsHistory]).to eq []
      end
    end

    context 'when EdoOracle Academic Standings returns nil' do
      before do
        allow_any_instance_of(EdoOracle::Queries).to receive(:get_academic_standings).and_return(nil)
      end
      it_behaves_like 'a model receiving no data'
    end
    context 'when AcademicStatus response is empty' do
      before do
        allow_any_instance_of(EdoOracle::Queries).to receive(:get_academic_standings).and_return({})
      end
      it_behaves_like 'a model receiving no data'
    end
    context 'when AcademicStanding query is populated' do
      before do
        EdoOracle::Queries.stub(:get_academic_standings) { standings_response }
      end
      it 'should successfully return a response' do
        standings = subject[:feed][:standingsHistory]
        expect(standings.count).to eq 2

        expect(standings[0][:acadStandingStatus]).to eq 'AP'
        expect(standings[0][:acadStandingStatusDescr]).to eq 'Probation'
        expect(standings[0][:acadStandingActionDescr]).to eq 'Academic Probation'
        expect(standings[0][:termName]).to eq 'Fall 2015'

        expect(standings[1][:acadStandingStatus]).to eq 'GST'
        expect(standings[1][:acadStandingStatusDescr]).to eq 'Good Standing'
        expect(standings[1][:acadStandingActionDescr]).to eq 'Probation Ended'
        expect(standings[1][:termName]).to eq 'Fall 2014'
      end

      it 'should successfully set the current standing' do
        standings = subject[:feed][:currentStandings]
        expect(standings.count).to eq 1

        expect(standings[0][:acadStandingStatus]).to eq 'DIS'
        expect(standings[0][:acadStandingStatusDescr]).to eq 'Dismissed'
        expect(standings[0][:acadStandingActionDescr]).to eq 'Dismissed (2.0 Rule)'
        expect(standings[0][:termName]).to eq 'Fall 2019'
      end
    end
  end
end
