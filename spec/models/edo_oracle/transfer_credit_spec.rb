describe EdoOracle::TransferCredit do

  def create_row_detailed(career, school_descr, transfer_units, law_transfer_units, requirement_designation, grade_points)
    {
      'career' => career,
      'school_descr' => school_descr,
      'transfer_units' => BigDecimal.new(transfer_units.to_s),
      'law_transfer_units' => BigDecimal.new(law_transfer_units.to_s),
      'requirement_designation' => requirement_designation,
      'grade_points' => BigDecimal.new(grade_points.to_s)
    }
  end
  def create_row_summary(career, total_cumulative_units, total_transfer_units, transfer_units_adjusted, ap_test_units, ib_test_units, alevel_test_units)
    {
      'career' => career,
      'total_cumulative_units' => BigDecimal.new(total_cumulative_units.to_s),
      'total_transfer_units' => BigDecimal.new(total_transfer_units.to_s),
      'transfer_units_adjusted' => BigDecimal.new(transfer_units_adjusted.to_s),
      'ap_test_units' => BigDecimal.new(ap_test_units.to_s),
      'ib_test_units' => BigDecimal.new(ib_test_units.to_s),
      'alevel_test_units' => BigDecimal.new(alevel_test_units.to_s)
    }
  end

  let(:uid) { random_id }
  let(:cs_id) { random_cs_id }
  let(:proxy) { described_class.new(user_id: uid) }
  let(:ugrd_rows_detailed) {
    [
      create_row_detailed('UGRD', 'Berkeley City College', 27.0, 0.0, nil, 0.0),
      create_row_detailed('UGRD', 'College Of Alameda', 0.5, 0.0, nil, 0.0)
    ]
  }
  let(:grad_rows_detailed) { [create_row_detailed('GRAD', 'UC Berkeley Extension', 3.0, 0.0, nil, 0.0)] }
  let(:law_rows_detailed) {
    [
      create_row_detailed('LAW', 'Georgetown Univ Law Center', 10.0, 0.0, nil, 0.0),
      create_row_detailed('LAW', 'Georgetown Univ Law Center', 2.0, 2.0, 'Fulfills Constitutional Law Requirement', 0.0)
    ]
  }
  let(:ugrd_rows_summary) { [create_row_summary('UGRD', 169.5, 52.5, 0.0, 0.0, 0.0, 0.0)] }
  let(:grad_rows_summary) { [create_row_summary('GRAD', 25.0, 3.0, 0.0, 0.0, 0.0, 0.0)] }
  let(:law_rows_summary) { [create_row_summary('LAW', 69.0, 10.0, 0.0, 0.0, 0.0, 0.0)] }
  let(:ucbx_rows_summary) { [create_row_summary('UCBX', 12.0, 0.0, 0.0, 0.0, 0.0, 0.0)] }
  let(:edo_law_units) { { 'total_transfer_units_law' => 10 } }

  describe 'pulling in transfer credit' do
    before do
      User::Identifiers.stub(:lookup_campus_solutions_id) { random_cs_id }
      EdoOracle::Queries.stub(:get_transfer_credit_detailed) { edo_resp_detailed }
      EdoOracle::Queries.stub(:get_transfer_credit_summary) { edo_resp_summary }
      EdoOracle::Queries.stub(:get_total_transfer_units_law) { edo_law_units }
    end

    context 'as an undergraduate, with some credits coming from UCBX' do
      let(:edo_resp_detailed) { ugrd_rows_detailed }
      let(:edo_resp_summary) { ugrd_rows_summary.concat(ucbx_rows_summary) }
      subject { proxy.get_feed }
      context 'parsing detailed data' do
        it 'pulls in all detailed data, restructures it, and casts Numeric values to Floats' do
          expect(subject[:undergraduate][:detailed]).to be_an_instance_of(Array)
          expect(subject[:undergraduate][:detailed]).to have(2).items
          expect(subject[:undergraduate][:detailed][0][:school]).to eql('Berkeley City College')
          expect(subject[:undergraduate][:detailed][0][:units]).to be_an_instance_of(Float)
          expect(subject[:undergraduate][:detailed][0][:units]).to eql(27.0)
        end
      end
      context 'parsing summary data' do
        it 'pulls in all summary data, restructures it, and casts Numeric values to Floats' do
          expect(subject[:undergraduate][:summary]).to include(:career => 'UGRD', :totalCumulativeUnits => 169.5, :apTestUnits => 0.0)
          expect(subject[:undergraduate][:summary][:totalCumulativeUnits]).to be_an_instance_of(Float)
        end
        it 'preserves data structure for non-relevant careers' do
          expect(subject).to include(:graduate, :law)
        end
        it 'ignores non-relevant careers like UCBX' do
          expect(subject).to_not include(:ucbx)
        end
        it 'does not query edo_oracle for law transfer units' do
          expect(EdoOracle::Queries).not_to receive(:get_total_transfer_units_law)
        end
      end
    end

    context 'as a law student with graduate and law career credits' do
      let(:edo_resp_detailed) { grad_rows_detailed.concat(law_rows_detailed) }
      let(:edo_resp_summary) { grad_rows_summary.concat(law_rows_summary) }
      subject { proxy.get_feed }
      context 'parsing detailed data' do
        it 'correctly separates grad and law credits' do
          expect(subject[:graduate][:detailed]).to have(1).items
          expect(subject[:law][:detailed]).to have(2).items
        end
        it 'correctly parses law career credits, providing additional data if provided' do
          expect(subject[:law][:detailed][0]).to include(:lawUnits => 0.0, :requirementDesignation => nil)
          expect(subject[:law][:detailed][1]).to include(:lawUnits => 2.0, :requirementDesignation => 'Fulfills Constitutional Law Requirement')
        end
      end
      context 'parsing summary data' do
        it 'correctly separates grad and law credits' do
          expect(subject[:graduate][:summary][:totalTransferUnits]).to eql(3.0)
          expect(subject[:law][:summary][:totalTransferUnits]).to eql(10.0)
        end
        it 'does not create test-credit properties for grad/law summaries' do
          expect(subject[:graduate][:summary]).to_not include(:apTestUnits, :ibTestUnits, :alevelTestUnits)
          expect(subject[:law][:summary]).to_not include(:apTestUnits, :ibTestUnits, :alevelTestUnits)
        end
        it 'queries edo_oracle for total transfer law units' do
          expect(EdoOracle::Queries).to receive(:get_total_transfer_units_law)
          expect(subject[:law][:summary]).to include(:totalTransferUnitsLaw => 10)
        end
      end
    end

  end
end
