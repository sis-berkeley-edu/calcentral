module User
  module Academics
    class Roles
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def current_user_roles
        collect_roles(user_roles_hash[:current])
      end

      def historic_user_roles
        collect_roles(user_roles_hash[:historical])
      end

      def collect_roles(roles_hash)
        roles_hash.inject([]) {|map, role| map << role[0].to_sym if role[1]; map }
      end

      def user_roles_hash
        @user_roles_hash ||= MyAcademics::MyAcademicRoles.new(user.uid).get_feed
      end
    end
  end
end
