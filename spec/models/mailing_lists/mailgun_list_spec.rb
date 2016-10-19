describe MailingLists::MailgunList do
  let(:canvas_site_id) { '1121' }
  let(:fake_course_data) { Canvas::Course.new(canvas_course_id: canvas_site_id, fake: true).course[:body] }
  before { allow_any_instance_of(Canvas::Course).to receive(:course).and_return(statusCode: 200, body: fake_course_data) }

  let(:response) { JSON.parse list.to_json}
  let(:list_domain) { Settings.mailgun_proxy.domain }

  include_examples 'a newly initialized mailing list'

  context 'creating a list' do
    let(:create_list) { described_class.create(canvas_site_id: canvas_site_id) }
    let(:list) { create_list }

    it 'reports list created' do
      count = described_class.count
      create_list
      expect(described_class.count).to eq count+1
      expect(response['mailingList']['state']).to eq 'created'
    end

    include_examples 'mailing list creation errors'
  end

  context 'an existing list record' do
    before { described_class.create(canvas_site_id: canvas_site_id)  }
    let(:list) { described_class.find_by(canvas_site_id: canvas_site_id) }

    it 'reports state as created' do
      expect(response['mailingList']['state']).to eq 'created'
      expect(response['mailingList']['creationUrl']).not_to be_present
      expect(response['mailingList']).not_to include('timeLastPopulated')
    end

    context 'populating list' do
      let(:course_users) { Canvas::CourseUsers.new(canvas_course_id: canvas_site_id, fake: true) }

      let(:oliver) do {
        'login_id' => '12345',
        'first_name' => 'Oliver',
        'last_name' => 'Heyer',
        'email_address' => 'oheyer@berkeley.edu',
        'enrollments' => [{'role' => 'TeacherEnrollment'}]
      } end
      let(:ray) do {
        'login_id' => '67890',
        'first_name' => 'Ray',
        'last_name' => 'Davis',
        'email_address' => 'raydavis@berkeley.edu',
        'enrollments' => [{'role' => 'StudentEnrollment'}]
      } end
      let(:paul) do {
        'login_id' => '65536',
        'first_name' => 'Paul',
        'last_name' => 'Kerschen',
        'email_address' => 'kerschen@berkeley.edu',
        'enrollments' => [{'role' => 'StudentEnrollment'}]
      } end

      def basic_attributes(user)
        {
          ldap_uid: user['login_id'],
          first_name: user['first_name'],
          last_name: user['last_name'],
          email_address: user['email_address']
        }
      end

      def create_mailing_list_members(*users)
        users.each do |user|
          MailingLists::Member.create!(
            mailing_list_id: list.id,
            first_name: user['first_name'],
            last_name: user['last_name'],
            email_address: user['email_address'],
            can_send: (user['enrollments'][0]['role'] == 'TeacherEnrollment')
          )
        end
      end

      before do
        allow(Canvas::CourseUsers).to receive(:new).and_return course_users
        expect(course_users).to receive(:course_users).exactly(1).times.and_return(statusCode: 200, body: canvas_site_members)
        expect(User::BasicAttributes).to receive(:attributes_for_uids).exactly(1).times.and_return(canvas_site_members.map { |user| basic_attributes user })
      end

      def expect_empty_population_results(list, action)
        expect(list.population_results[action][:total]).to eq 0
        expect(list.population_results[action][:success]).to eq 0
        expect(list.population_results[action][:failure]).to eq []
      end

      context 'populating an empty list' do
        let(:canvas_site_members) { [oliver, ray, paul] }

        it 'requests addition and reports success' do
          expect(list.members.count).to eq 0

          expect(MailingLists::Member).to receive(:create!).exactly(3).times.and_call_original
          expect_any_instance_of(MailingLists::Member).not_to receive(:destroy)
          expect_any_instance_of(MailingLists::Member).not_to receive(:update_attributes)
          list.populate

          expect(list.population_results[:add][:success]).to eq 3
          expect_empty_population_results(list, :remove)
          expect_empty_population_results(list, :update)

          expect(response['populationResults']['success']).to eq true
          expect(response['populationResults']['messages']).to eq ['3 new members were added.']
          expect(list.members.count).to eq 3
        end

        it 'enables sending permission for teacher role only' do
          list.populate

          expect(list.members.find_by(email_address: 'oheyer@berkeley.edu').can_send).to eq true
          expect(list.members.find_by(email_address: 'raydavis@berkeley.edu').can_send).to eq false
          expect(list.members.find_by(email_address: 'kerschen@berkeley.edu').can_send).to eq false
        end
      end

      context 'no change in list membership' do
        let(:canvas_site_members) { [oliver, ray, paul] }
        before { create_mailing_list_members(oliver, ray, paul) }

        it 'makes no changes' do
          expect(list.members.count).to eq 3
          expect(MailingLists::Member).not_to receive(:create!)
          expect_any_instance_of(MailingLists::Member).not_to receive(:destroy)
          expect_any_instance_of(MailingLists::Member).not_to receive(:update_attributes)
          list.populate
          expect(list.members.count).to eq 3
        end

        it 'returns time, no errors and empty results' do
          list.populate
          expect(response['mailingList']['timeLastPopulated']).to be_present
          expect(response).not_to include 'errorMessages'
          expect_empty_population_results(list, :add)
          expect_empty_population_results(list, :remove)
          expect_empty_population_results(list, :update)
          expect(response['populationResults']['success']).to eq true
          expect(response['populationResults']['messages']).to eq []
        end
      end

      context 'new users in course site' do
        let(:canvas_site_members) { [oliver, ray, paul] }
        before { create_mailing_list_members(oliver) }

        it 'requests addition of new users only' do
          expect(list.members.count).to eq 1

          expect(MailingLists::Member).to receive(:create!).exactly(1).times.with(
            email_address: 'raydavis@berkeley.edu',
            first_name: 'Ray',
            last_name: 'Davis',
            can_send: false,
            mailing_list_id: list.id
          ).and_call_original
          expect(MailingLists::Member).to receive(:create!).exactly(1).times.with(
            email_address: 'kerschen@berkeley.edu',
            first_name: 'Paul',
            last_name: 'Kerschen',
            can_send: false,
            mailing_list_id: list.id
          ).and_call_original
          expect_any_instance_of(MailingLists::Member).not_to receive(:destroy)
          expect_any_instance_of(MailingLists::Member).not_to receive(:update_attributes)

          list.populate

          expect(list.population_results[:add][:total]).to eq 2
          expect(list.population_results[:add][:success]).to eq 2
          expect(list.population_results[:add][:failure]).to eq []
          expect_empty_population_results(list, :remove)
          expect_empty_population_results(list, :update)

          expect(response['populationResults']['success']).to eq true
          expect(response['populationResults']['messages']).to eq ['2 new members were added.']

          expect(list.members.count).to eq 3
        end
      end

      context 'users no longer in course site' do
        let(:canvas_site_members) { [oliver, ray] }
        before { create_mailing_list_members(oliver, ray, paul) }

        it 'requests removal of departed users only' do
          expect(list.members.count).to eq 3

          expect(MailingLists::Member).not_to receive(:create!)
          expect_any_instance_of(MailingLists::Member).not_to receive(:update_attributes)
          expect_any_instance_of(MailingLists::Member).to receive(:destroy).exactly(1).times.and_call_original

          list.populate

          expect_empty_population_results(list, :add)
          expect(list.population_results[:remove][:total]).to eq 1
          expect(list.population_results[:remove][:success]).to eq 1
          expect(list.population_results[:remove][:failure]).to eq []
          expect(response['populationResults']['success']).to eq true
          expect(response['populationResults']['messages']).to eq ['1 former member was removed.']

          expect(list.members.count).to eq 2
          expect(list.members.reload.map { |member| member.email_address}).not_to include 'kerschen@berkeley.edu'
        end
      end

      context 'user with changed permissions' do
        let(:canvas_site_members) { [oliver, ray, paul] }
        before do
          student_oliver = oliver.merge({'enrollments' => [{'role' => 'StudentEnrollment'}]})
          create_mailing_list_members(student_oliver, ray, paul)
        end

        it 'updates user\'s sending permission' do
          expect(list.members.count).to eq 3
          expect(list.members.find_by(email_address: 'oheyer@berkeley.edu').can_send).to eq false

          expect(MailingLists::Member).not_to receive(:create!)
          expect_any_instance_of(MailingLists::Member).not_to receive(:destroy)
          expect_any_instance_of(MailingLists::Member).to receive(:update_attributes).exactly(1).times.and_call_original

          list.populate

          expect(list.members.count).to eq 3
          expect(list.members.find_by(email_address: 'oheyer@berkeley.edu').can_send).to eq true

          expect_empty_population_results(list, :add)
          expect_empty_population_results(list, :remove)
          expect(list.population_results[:update][:total]).to eq 1
          expect(list.population_results[:update][:success]).to eq 1
          expect(list.population_results[:update][:failure]).to eq []
          expect(response['populationResults']['success']).to eq true
          expect(response['populationResults']['messages']).to eq ['1 member was updated.']
        end
      end
    end
  end

end
