describe CampusOracle::UserAttributes do

  context 'obtaining user attributes feed' do

    subject {CampusOracle::UserAttributes.new(user_id: uid).get_feed_internal}

    shared_examples_for 'a parser for roles' do |expected_roles|
      it 'only sets expected roles' do
        set_roles = subject[:roles].select {|key, val| val}.keys.sort
        expect(set_roles).to eq expected_roles.sort
      end
    end

    context 'working against test data', if: CampusOracle::Queries.test_data? do
      describe 'roles' do
        context 'student' do
          let(:uid) {300846}
          it_behaves_like 'a parser for roles', [:student, :registered, :undergrad]
        end
        context 'staff member and ex-student' do
          let(:uid) {238382}
          it_behaves_like 'a parser for roles', [:exStudent, :staff]
        end
        context 'user without affiliations data' do
          let(:uid) {321765}
          it_behaves_like 'a parser for roles', []
        end
        context 'guest' do
          let(:uid) {19999969}
          it_behaves_like 'a parser for roles', [:guest]
        end
        context 'user with expired CalNet account' do
          let(:uid) {6188989}
          it_behaves_like 'a parser for roles', [:student, :registered, :expiredAccount, :graduate]
        end
      end
    end

  end

end
