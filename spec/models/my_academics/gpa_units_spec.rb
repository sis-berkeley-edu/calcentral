describe 'MyAcademics::GpaUnits' do

  let(:uid) { '61889' }
  let(:eight_digit_cs_id) { '87654321' }
  let(:ten_digit_cs_id) { '1234567890' }
  let(:edo_response) do
    {
      'pnp_taken' => 3,
      'pnp_passed' => 5
    }
  end
  let(:academic_roles) do
    {
      'law' => has_law_role
    }
  end
  let(:has_law_role) { false }

  let(:feed) do
    {}.tap { |feed| MyAcademics::GpaUnits.new(uid).merge feed }
  end

  context 'when legacy user but non-legacy term' do
    let(:status_proxy) { HubEdos::AcademicStatus.new(user_id: uid, fake: true) }
    before do
      allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return eight_digit_cs_id
      allow(Settings.terms).to receive(:legacy_cutoff).and_return('spring-2010')
    end
    context 'CS data is ready to go' do
      it 'sources from Hub' do
        expect(CampusOracle::Queries).to receive(:get_student_info).never
        expect(HubEdos::AcademicStatus).to receive(:new).and_return status_proxy
        expect(feed[:gpaUnits][:cumulativeGpa]).to eq '3.8'
      end
    end
  end

  context 'when sourced from Hub academic status' do
    let(:status_proxy) { HubEdos::AcademicStatus.new(user_id: uid, fake: true) }
    before do
      allow(HubEdos::AcademicStatus).to receive(:new).and_return status_proxy
      allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return academic_roles
    end

    context 'when CalNet and EDO DB are responsive' do
      before do
        allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return ten_digit_cs_id
        allow(EdoOracle::Queries).to receive(:get_pnp_unit_count).and_return edo_response
      end

      it 'translates GPA' do
        expect(feed[:gpaUnits][:cumulativeGpa]).to eq '3.8'
      end
      it 'translates total units' do
        expect(feed[:gpaUnits][:totalUnits]).to eq 73
      end
      it 'translates total units attempted' do
        expect(feed[:gpaUnits][:totalUnitsAttempted]).to eq 8
      end
      it 'provides the pass/no pass unit totals' do
        expect(feed[:gpaUnits][:totalUnitsTakenNotForGpa]).to eq 3
        expect(feed[:gpaUnits][:totalUnitsPassedNotForGpa]).to eq 5
      end

      context 'when student is active in a LAW career' do
        let(:has_law_role) { true }
        it 'suppresses the pass/no pass unit totals' do
          expect(feed[:gpaUnits][:totalUnitsTakenNotForGpa]).not_to be
          expect(feed[:gpaUnits][:totalUnitsPassedNotForGpa]).not_to be
        end
      end

      context 'when academic status feed is empty' do
        before { status_proxy.set_response(status: 200, body: '{}') }
        it 'reports empty' do
          expect(feed[:gpaUnits][:hub_empty]).to eq true
        end
      end

      context 'when academic status feed errors' do
        before { status_proxy.set_response(status: 502, body: '') }
        it 'reports error' do
          expect(feed[:gpaUnits][:errored]).to eq true
        end
      end

      context 'when academic status feed lacking some data' do
        before do
          status_proxy.override_json do |json|
            json['apiResponse']['response']['any']['students'][0]['academicStatuses'][0].delete 'cumulativeUnits'
          end
        end
        it 'returns what data it can' do
          expect(feed[:gpaUnits][:cumulativeGpa]).to be_present
          expect(feed[:gpaUnits][:totalUnits]).to be nil
        end
      end
    end

    context 'when CalNet campus solutions id lookup fails' do
      before do
        allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return nil
      end
      it 'cannot call the EDO query' do
        expect(feed[:gpaUnits][:totalUnitsTakenNotForGpa]).not_to be
        expect(feed[:gpaUnits][:totalUnitsPassedNotForGpa]).not_to be
      end
    end

    context 'when EDO DB provides no data' do
      before do
        allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return ten_digit_cs_id
        allow(EdoOracle::Queries).to receive(:get_pnp_unit_count).and_return nil
      end
      it 'cannot call the EDO query' do
        expect(feed[:gpaUnits][:totalUnitsTakenNotForGpa]).not_to be
        expect(feed[:gpaUnits][:totalUnitsPassedNotForGpa]).not_to be
      end
    end
  end

end
