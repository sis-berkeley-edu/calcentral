describe Berkeley::UserRoles do

  shared_examples_for 'a parser for roles' do |expected_roles|
    it 'only sets expected roles' do
      set_roles = subject.select {|key, val| val}.keys.sort
      expect(set_roles).to eq expected_roles.sort
    end
  end

  describe '#roles_from_cs_affiliations' do
    subject { Berkeley::UserRoles.roles_from_cs_affiliations(affiliations) }

    context 'concurrent enrollment student' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2017-01-21'
          },
          {
            :type => {
              :code => 'EXTENSION',
              :description => 'UCB Extension Student'
            },
            :status => {
              :code => 'ACT',
              :description => 'Active'
            },
            :fromDate => '2017-01-21'
          },
          {
            :type => {
              :code => 'UNDERGRAD',
              :description => 'Undergraduate Student'
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2017-02-10'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :undergrad, :concurrentEnrollmentStudent]
    end

    context 'undergraduate student' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'UNDERGRAD',
              :description => 'Undergraduate Student'
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :undergrad]
    end

    context 'graduate student' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'GRADUATE',
              :description => 'Graduate Student'
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :graduate]
    end

    context 'inactive student' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'INA',
              :description => 'Inactive'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'GRADUATE',
              :description => 'Graduate Student'
            },
            :status => {
              :code =>'INA',
              :description => 'Inactive'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:exStudent]
    end

    context 'former undergrad, current grad' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'GRADUATE',
              :description => 'Graduate Student'
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'UNDERGRAD',
              :description => 'Undergraduate Student'
            },
            :status => {
              :code =>'INA',
              :description => 'Inactive'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :graduate]
    end

    context 'Law student' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'LAW',
              :description => 'Law School Student'
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :law]
    end

    context 'new and released admit' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'ADMT_UX',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:applicant]
    end

    context 'unreleased admit or not-yet-accepted applicant' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'APPLICANT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', []
    end

    context 'ex-student and unaccepted applicant' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'STUDENT',
              :description => ''
            },
            :status => {
              :code =>'INA',
              :description => 'Inactive'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'APPLICANT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', [:exStudent]
    end

    context 'retracted admit' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'APPLICANT',
              :description => ''
            },
            :status => {
              :code =>'ACT',
              :description => 'Active'
            },
            :fromDate => '2014-05-15'
          },
          {
            :type => {
              :code => 'ADMT_UX',
              :description => ''
            },
            :status => {
              :code =>'INA',
              :description => 'Inactive'
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      it_behaves_like 'a parser for roles', []
    end

    context 'advisor affiliation' do
      let(:affiliations) do
        [
          {
            :type => {
              :code => 'ADVISOR',
              :description => 'Advisor'
            },
            :status => {
              :code => status_code,
              :description => status_description
            },
            :fromDate => '2014-05-15'
          }
        ]
      end
      context 'active status in date range' do
        let(:status_code) { 'ACT' }
        let(:status_description) { 'Active' }
        it_behaves_like 'a parser for roles', [:advisor]
      end
      context 'inactive' do
        let(:status_code) { 'INA' }
        let(:status_description) { 'Inactive' }
        it_behaves_like 'a parser for roles', []
      end
    end

    context 'no affiliations' do
      let(:affiliations) { [] }
      it_behaves_like 'a parser for roles', []
    end
  end

  describe '#roles_from_ldap_affiliations' do
    let(:ldap_record) do
      {
        berkeleyeduaffiliations: affiliations
      }
    end
    subject { Berkeley::UserRoles.roles_from_ldap_affiliations(ldap_record) }
    context 'current student' do
      let(:affiliations) { ['STUDENT-TYPE-REGISTERED'] }
      it_behaves_like 'a parser for roles', [:student, :registered]
    end
    context 'current but not-fully-registered student' do
      let(:affiliations) { ['STUDENT-TYPE-NOT REGISTERED'] }
      it_behaves_like 'a parser for roles', [:student]
    end
    context 'confusingly registered student' do
      let(:affiliations) { ['STUDENT-TYPE-NOT REGISTERED', 'STUDENT-TYPE-REGISTERED'] }
      it_behaves_like 'a parser for roles', [:student, :registered]
    end
    context 'guest account' do
      let(:affiliations) { ['GUEST-TYPE-COLLABORATOR'] }
      it_behaves_like 'a parser for roles', [:guest]
    end
    context 'student employee' do
      let(:affiliations) { ['EMPLOYEE-TYPE-STAFF', 'STUDENT-TYPE-REGISTERED'] }
      it_behaves_like 'a parser for roles', [:staff, :student, :registered]
    end
    context 'academic employee and ex-student' do
      let(:affiliations) { ['EMPLOYEE-TYPE-ACADEMIC', 'FORMER-STUDENT'] }
      it_behaves_like 'a parser for roles', [:exStudent, :faculty]
    end
    context 'ex-employee' do
      let(:affiliations) { ['FORMER-EMPLOYEE'] }
      it_behaves_like 'a parser for roles', []
    end
    # TODO Remove this after the new CalNet scheme lands in production.
    context 'legacy historical affiliations' do
      context 'academic employee and ex-student' do
        let(:affiliations) { ['EMPLOYEE-TYPE-ACADEMIC', 'STUDENT-STATUS-EXPIRED'] }
        it_behaves_like 'a parser for roles', [:exStudent, :faculty]
      end
    end
  end

  describe '#roles_from_ldap_groups' do
    subject { Berkeley::UserRoles.roles_from_ldap_groups(groups) }
    context 'current undergrad' do
      let(:groups) do
        [
          'cn=edu:berkeley:official:students:all,ou=campus groups,dc=berkeley,dc=edu',
          'cn=edu:berkeley:official:students:undergrad,ou=campus groups,dc=berkeley,dc=edu'
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :undergrad]
    end
    context 'current graduate student' do
      let(:groups) do
        [
          'cn=edu:berkeley:official:students:all,ou=campus groups,dc=berkeley,dc=edu',
          'cn=edu:berkeley:official:students:graduate,ou=campus groups,dc=berkeley,dc=edu'
        ]
      end
      it_behaves_like 'a parser for roles', [:student, :graduate]
    end
  end

end
