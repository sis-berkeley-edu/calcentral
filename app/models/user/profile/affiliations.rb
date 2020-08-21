module User
  module Profile
    # Affiliations Interface for Campus Solutions and LDAP Affiliation
    class Affiliations
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def uid
        user.uid
      end

      def matriculated_but_excluded?
        ihub_affiliations.matriculated_but_excluded?
      end

      def not_registered?
        ldap_person.affiliations.include? 'STUDENT-TYPE-NOT REGISTERED'
      end

      def is_student?
        ihub_affiliations.student_affiliation_present?
      end

      def ihub_affiliations
        ihub_person.affiliations
      end

      private

      def ihub_person
        @ihub_person ||= HubEdos::PersonApi::V1::Person.get(user)
      end

      def ldap_person
        @ldap_person ||= CalnetLdap::Person.get(user)
      end
    end
  end
end
