describe MyRegistrations::Statuses do
  let(:model) { MyRegistrations::Statuses.new('61889') }
  let(:hub_student_registrations) { HubEdos::Registrations.new(user_id: 61889, fake: true).get }
  let(:hub_student_attributes) { HubEdos::StudentAttributes.new(user_id: 61889, fake: true).get }
  before(:each) do
    allow(model).to receive(Settings.terms.legacy_cutoff).and_return 'summer-2016'
    allow(model).to receive(:registrations).and_return(hub_student_registrations[:feed]['registrations'])
    allow(model).to receive(:studentAttributes).and_return(hub_student_attributes[:feed]['student']['studentAttributes'])
  end

  context 'fully populated berkeley terms' do
    before do
      allow(model).to receive(:get_terms).and_return ({
        current: {id: '1932', name: 'Spring 1993', classesStart: Date.parse('1993-05-22T00:00:00.000-07:00'), end: Date.parse('1993-08-11T23:59:59.000-07:00'), endDropAdd: false},
        running: {id: '1952', name: 'Spring 1995', classesStart: Date.parse('1995-05-22T00:00:00.000-07:00'), end: Date.parse('1995-08-11T23:59:59.000-07:00'), endDropAdd: false},
        sis_current_term: {id: '2175', name: 'Summer 2017', classesStart: Date.parse('2017-05-22T00:00:00.000-07:00'), end: Date.parse('2017-08-11T23:59:59.000-07:00'), endDropAdd: false},
        next: {id: '2178', name: 'Fall 2017', classesStart: Date.parse('2017-08-23T00:00:00.000-07:00'), end: Date.parse('2017-08-11T23:59:59.000-07:00'), endDropAdd: Date.parse('2017-09-22')},
        future: {id: '2182', name: 'Spring 2018', classesStart: Date.parse('2018-01-16T00:00:00.000-08:00'), end: Date.parse('2018-05-11T23:59:59.000-07:00'), endDropAdd: nil}
      })
    end
    subject { model.get_feed_internal }

    it 'adds the appropriate term flags' do
      current = model.send(:set_term_flags, subject[:terms][:current])
      running = model.send(:set_term_flags, subject[:terms][:running])
      expect(current[:pastClassesStart]).to eq true
      expect(running[:pastEndOfInstruction]).to eq true
      expect(subject[:registrations]['2175'][:isSummer]).to eq true
      expect(subject[:registrations]['2182'][:isSummer]).to eq false
    end

    it 'adds the appropriate visibility flags' do
      expect(subject[:registrations]['2182'][:showRegStatus]).to eq true
      expect(subject[:registrations]['2182'][:showCnp]).to eq false
    end

    it 'returns all matched terms' do
      expect(subject[:registrations]['1932']['term']['id']).to eq '1932'
      expect(subject[:registrations]['1952']['term']['id']).to eq '1952'
      expect(subject[:registrations]['2182']['term']['id']).to eq '2182'
    end

    it 'matches positive indicators to the correct term' do
      expect(subject[:registrations]['2182'][:positiveIndicators][0]['type']['code']).to eq '+S09'
    end
  end

  context 'some populated berkeley terms' do
    before do
      allow(model).to receive(:get_terms).and_return ({
        current: nil,
        running: nil,
        sis_current_term: nil,
        next: {id: '2178', name: 'Fall 2017', classesStart: '2017-08-23T00:00:00.000-07:00', end: '2017-08-11T23:59:59.000-07:00', endDropAdd: '2017-09-22'},
        future: {id: '2182', name: 'Spring 2018', classesStart: '2018-01-16T00:00:00.000-08:00', end: '2018-05-11T23:59:59.000-07:00', endDropAdd: nil}
      })
    end
    subject { model.get_feed_internal }

    context 'registrations present' do
      it 'returns all matched terms' do
        expect(subject[:registrations]['2182']['term']['id']).to eq '2182'
      end
    end

    context 'registrations not present' do
      before do
        allow(model).to receive(:registrations).and_return ({})
      end

      it 'returns no matched terms' do
        expect(subject[:registrations]).to eq ({})
      end
    end
  end

  context 'no populated berkeley terms' do
    before do
      allow(model).to receive(:get_terms).and_return ({
        current: nil,
        running: nil,
        sis_current_term: nil,
        next: nil,
        future: nil
      })
    end
    subject { model.get_feed_internal }

    it 'returns no matched terms' do
      expect(subject[:registrations]).to eq ({})
    end
  end

end
