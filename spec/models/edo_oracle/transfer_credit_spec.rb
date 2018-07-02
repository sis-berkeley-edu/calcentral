describe EdoOracle::TransferCredit do

  let(:proxy) { described_class.new(user_id: uid) }

  describe '#get_feed' do
    subject { proxy.get_feed }

    before do
      allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return({ :current => { 'law' => is_law }})
    end

    let(:is_law) { false }

    context 'as a student with Undergrad and UCBX transfer credits' do
      let(:uid) { '790833' }

      it 'parses detailed data, casting Numerical values to Floats' do
        expect(subject[:undergraduate]).to be
        expect(subject[:undergraduate][:detailed]).to be
        expect(subject[:undergraduate][:detailed]).to be_an_instance_of(Array)
        expect(subject[:undergraduate][:detailed]).to have(2).items

        expect(subject[:undergraduate][:detailed][0]).to be
        expect(subject[:undergraduate][:detailed][0].count).to eq 5
        expect(subject[:undergraduate][:detailed][0][:school]).to eql('Berkeley City College')
        expect(subject[:undergraduate][:detailed][0][:units]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:detailed][0][:units]).to eql(27.0)
        expect(subject[:undergraduate][:detailed][0][:gradePoints]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:detailed][0][:gradePoints]).to eql(0.0)
        expect(subject[:undergraduate][:detailed][0][:lawUnits]).to be nil
        expect(subject[:undergraduate][:detailed][0][:requirementDesignation]).to be nil

        expect(subject[:undergraduate][:detailed][1]).to be
        expect(subject[:undergraduate][:detailed][1].count).to eq 5
        expect(subject[:undergraduate][:detailed][1][:school]).to eql('College Of Alameda')
        expect(subject[:undergraduate][:detailed][1][:units]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:detailed][1][:units]).to eql(0.5)
        expect(subject[:undergraduate][:detailed][1][:gradePoints]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:detailed][1][:gradePoints]).to eql(0.0)
        expect(subject[:undergraduate][:detailed][1][:lawUnits]).to be nil
        expect(subject[:undergraduate][:detailed][1][:requirementDesignation]).to be nil
      end
      it 'parses summary data, casting Numerical values to Floats' do
        expect(subject[:undergraduate]).to be
        expect(subject[:undergraduate][:summary]).to be
        expect(subject[:undergraduate][:summary][:career]).to eq 'UGRD'
        expect(subject[:undergraduate][:summary][:careerDescr]).to eq :Undergraduate
        expect(subject[:undergraduate][:summary][:totalCumulativeUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:totalCumulativeUnits]).to eq 2.0
        expect(subject[:undergraduate][:summary][:totalTransferUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:totalTransferUnits]).to eq 70.0
        expect(subject[:undergraduate][:summary][:totalTransferUnitsNonAdjusted]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:totalTransferUnitsNonAdjusted]).to eq 100.0
        expect(subject[:undergraduate][:summary][:apTestUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:apTestUnits]).to eq 2.0
        expect(subject[:undergraduate][:summary][:ibTestUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:ibTestUnits]).to eq 4.0
        expect(subject[:undergraduate][:summary][:alevelTestUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:alevelTestUnits]).to eq 6.0
        expect(subject[:undergraduate][:summary][:totalTestUnits]).to be_an_instance_of(Float)
        expect(subject[:undergraduate][:summary][:totalTestUnits]).to eq 12.0
        expect(subject[:undergraduate][:summary][:totalTransferUnitsLaw]).to eq nil
      end
      it 'preserves data structure for relevant careers' do
        expect(subject).to include(:undergraduate, :graduate, :law)
      end
      it 'ignores non-relevant careers like UCBX' do
        expect(subject).to_not include(:ucbx)
      end
    end

    context 'as a student with graduate and law career credits' do
      let(:uid) { '876437' }

      context 'currently a law student' do
        let(:is_law) { true }
        it 'includes only transfer credits from the active career' do
          expect(subject[:graduate]).to be
          expect(subject[:graduate][:detailed]).to be nil
          expect(subject[:graduate][:summary]).to be nil

          expect(subject[:law]).to be
          expect(subject[:law][:detailed]).to be
          expect(subject[:law][:detailed]).to have(2).items
          expect(subject[:law][:summary]).to be
          expect(subject[:law][:summary]).to have(10).items
        end
      end
      context 'not currently a law student' do
        it 'includes transfer credits from all careers' do
          expect(subject[:graduate]).to be
          expect(subject[:graduate][:detailed]).to be
          expect(subject[:graduate][:detailed]).to have(1).items
          expect(subject[:graduate][:summary]).to be

          expect(subject[:law]).to be
          expect(subject[:law][:detailed]).to be
          expect(subject[:law][:detailed]).to have(2).items
          expect(subject[:law][:summary]).to be
        end
        it 'parses detailed data, casting Numerical values to Floats' do
          expect(subject[:graduate][:detailed][0].count).to eq 5
          expect(subject[:graduate][:detailed][0][:school]).to eql('UNIV OF TORONTO')
          expect(subject[:graduate][:detailed][0][:units]).to be_an_instance_of(Float)
          expect(subject[:graduate][:detailed][0][:units]).to eql(15.0)
          expect(subject[:graduate][:detailed][0][:gradePoints]).to be_an_instance_of(Float)
          expect(subject[:graduate][:detailed][0][:gradePoints]).to eql(0.0)
          expect(subject[:graduate][:detailed][0][:lawUnits]).to be nil
          expect(subject[:graduate][:detailed][0][:requirementDesignation]).to be nil

          expect(subject[:law][:detailed][0].count).to eq 5
          expect(subject[:law][:detailed][0][:school]).to eql('Georgetown Univ Law Center')
          expect(subject[:law][:detailed][0][:units]).to be_an_instance_of(Float)
          expect(subject[:law][:detailed][0][:units]).to eql(10.0)
          expect(subject[:law][:detailed][0][:gradePoints]).to eq nil
          expect(subject[:law][:detailed][0][:lawUnits]).to be_an_instance_of(Float)
          expect(subject[:law][:detailed][0][:lawUnits]).to eq 0.0
          expect(subject[:law][:detailed][0][:requirementDesignation]).to be nil

          expect(subject[:law][:detailed][1].count).to eq 5
          expect(subject[:law][:detailed][1][:school]).to eql('Georgetown Univ Law Center')
          expect(subject[:law][:detailed][1][:units]).to be_an_instance_of(Float)
          expect(subject[:law][:detailed][1][:units]).to eql(2.0)
          expect(subject[:law][:detailed][1][:gradePoints]).to eq nil
          expect(subject[:law][:detailed][1][:lawUnits]).to be_an_instance_of(Float)
          expect(subject[:law][:detailed][1][:lawUnits]).to eq 2.0
          expect(subject[:law][:detailed][1][:requirementDesignation]).to eq 'Fulfills Constitutional Law Requirement'
        end
        it 'parses summary data, casting Numerical values to Floats' do
          expect(subject[:graduate][:summary]).to have(10).items
          expect(subject[:graduate][:summary][:career]).to eq 'GRAD'
          expect(subject[:graduate][:summary][:careerDescr]).to eq :Graduate
          expect(subject[:graduate][:summary][:totalCumulativeUnits]).to be nil
          expect(subject[:graduate][:summary][:totalTransferUnits]).to be_an_instance_of(Float)
          expect(subject[:graduate][:summary][:totalTransferUnits]).to eq 3.0
          expect(subject[:graduate][:summary][:totalTransferUnitsNonAdjusted]).to be nil
          expect(subject[:graduate][:summary][:apTestUnits]).to be nil
          expect(subject[:graduate][:summary][:ibTestUnits]).to be nil
          expect(subject[:graduate][:summary][:alevelTestUnits]).to be nil
          expect(subject[:graduate][:summary][:totalTransferUnitsLaw]).to eq nil

          expect(subject[:law][:summary][:career]).to eq 'LAW'
          expect(subject[:law][:summary][:careerDescr]).to eq :Law
          expect(subject[:law][:summary][:totalCumulativeUnits]).to be nil
          expect(subject[:law][:summary][:totalTransferUnits]).to be_an_instance_of(Float)
          expect(subject[:law][:summary][:totalTransferUnits]).to eq 10.0
          expect(subject[:law][:summary][:totalTransferUnitsNonAdjusted]).to be nil
          expect(subject[:law][:summary][:apTestUnits]).to be nil
          expect(subject[:law][:summary][:ibTestUnits]).to be nil
          expect(subject[:law][:summary][:alevelTestUnits]).to be nil
          expect(subject[:law][:summary][:totalTestUnits]).to be nil
          expect(subject[:law][:summary][:totalTransferUnitsLaw]).to be_an_instance_of(Float)
          expect(subject[:law][:summary][:totalTransferUnitsLaw]).to eq 57.0
        end
        it 'preserves data structure for relevant careers' do
          expect(subject).to include(:undergraduate, :graduate, :law)
        end
        it 'ignores non-relevant careers like UCBX' do
          expect(subject).to_not include(:ucbx)
        end
      end
    end

    context 'as a student with credits from 3 careers' do
      let(:uid) { '300216' }

      context 'currently a law student' do
        let(:is_law) { true }
        it 'includes only transfer credits from active careers' do
          expect(subject[:undergraduate]).to be
          expect(subject[:undergraduate][:detailed]).to be nil
          expect(subject[:undergraduate][:summary]).to be nil

          expect(subject[:graduate]).to be
          expect(subject[:graduate][:detailed]).to be
          expect(subject[:graduate][:detailed]).to have(1).items
          expect(subject[:graduate][:summary]).to be
          expect(subject[:graduate][:summary]).to have(10).items

          expect(subject[:law]).to be
          expect(subject[:law][:detailed]).to be
          expect(subject[:law][:detailed]).to have(1).items
          expect(subject[:law][:summary]).to be
          expect(subject[:law][:summary]).to have(10).items
        end
      end
      context 'not currently a law student' do
        it 'includes only transfer credits from all careers' do
          expect(subject[:undergraduate]).to be
          expect(subject[:undergraduate][:detailed]).to be
          expect(subject[:undergraduate][:detailed]).to have(1).items
          expect(subject[:undergraduate][:summary]).to be
          expect(subject[:undergraduate][:summary]).to have(10).items

          expect(subject[:graduate]).to be
          expect(subject[:graduate][:detailed]).to be
          expect(subject[:graduate][:detailed]).to have(1).items
          expect(subject[:graduate][:summary]).to be
          expect(subject[:graduate][:summary]).to have(10).items

          expect(subject[:law]).to be
          expect(subject[:law][:detailed]).to be
          expect(subject[:law][:detailed]).to have(1).items
          expect(subject[:law][:summary]).to be
          expect(subject[:law][:summary]).to have(10).items
        end
      end
    end
  end
end
