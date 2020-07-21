module User
  module Academics
    # Provides diploma single-sign-on link for students
    class DiplomaSso
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def sso_url
        data[:ucSrCediplomaUrl]
      end

      def as_json(options = {})
        {
          sso_url: sso_url
        }
      end

      private

      def data
        @enrollments_data = CampusSolutions::CeDiplomaSso.new({
          user_id: user.uid
        }).get[:feed][:root][:ucSrCediploma]
      rescue NoMethodError
        {}
      end

    end
  end
end
