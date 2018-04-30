describe MyAcademics::FilteredForDelegate do

  shared_context 'with stubbed model providers' do
    before do
      MyAcademics::Merged.providers.each do |provider_class|
        provider = double
        allow(provider).to receive(:merge) do |feed|
          feed[provider_class.to_s] = true
        end
        allow(provider_class).to receive(:new).and_return provider
      end
    end
    let!(:unfiltered_provider_classes) { MyAcademics::Merged.providers }
    let!(:filtered_provider_classes) { described_class.providers }
    let!(:verboten_provider_classes) { unfiltered_provider_classes - filtered_provider_classes }
    let(:uid) { random_id }
  end

  shared_context 'with model providers returning fake data' do
    before do
      allow_any_instance_of(AuthenticationState).to receive(:delegated_privileges).and_return(
        {
          financial: false,
          viewEnrollments: view_enrollments,
          viewGrades: view_grades,
          phone: false
        }
      )
    end
    let(:uid) { '61889' }
  end

  describe '#get_feed_as_json' do

    let(:feed) { JSON.parse described_class.new(uid).get_feed_as_json }

    context 'whilst testing provider filtering' do
      include_context 'with stubbed model providers'

      it 'only includes a subset of providers' do
        expect(filtered_provider_classes.length).to be < unfiltered_provider_classes.length
        filtered_provider_classes.map do |provider_class|
          expect(feed[provider_class.to_s]).to eq true
        end
        verboten_provider_classes.map do |provider_class|
          expect(feed[provider_class.to_s]).to be_nil
        end
      end
    end

    context 'when delegate has full permissions', if: CampusOracle::Connection.test_data? do
      include_context 'with model providers returning fake data'
      let(:view_enrollments) { true }
      let(:view_grades) { true }

      it 'should return grades' do
        expect(feed['gpaUnits']['gpa'][0]).to include 'cumulativeGpa'
        expect(feed['gpaUnits']['gpa'][1]).to include 'cumulativeGpa'
        feed['semesters'].each do |semester|
          semester['classes'].each do |course|
            expect(course['transcript'].first).to include 'grade'
          end
        end
      end
    end

    context 'when delegate permissions do not include viewing grades', if: CampusOracle::Connection.test_data? do
      include_context 'with model providers returning fake data'
      let(:view_enrollments) { true }
      let(:view_grades) { false }

      it 'should not return grades' do
        expect(feed['gpaUnits']).not_to include 'cumulativeGpa'
        feed['semesters'].each do |semester|
          semester['classes'].each do |course|
            expect(course['transcript'].first).not_to include 'grade'
          end
        end
      end
    end
  end

  describe '#get_feed_internal' do
    include_context 'with stubbed model providers'

    subject { described_class.new(uid) }

    context 'when feature is not enabled' do
      before do
        allow(subject).to receive(:is_feature_enabled).and_return(false)
      end

      it 'returns an empty feed' do
        expect(subject.get_feed_internal).to eq({})
      end
    end

    context 'when feature is enabled' do
      before do
        allow(subject).to receive(:is_feature_enabled).and_return(true)
      end

      it 'returns a populated feed' do
        json = subject.get_feed_internal
        filtered_provider_classes.map do |provider_class|
          expect(json[provider_class.to_s]).to eq true
        end
        verboten_provider_classes.map do |provider_class|
          expect(json[provider_class.to_s]).to be_nil
        end
      end
    end
  end
end
