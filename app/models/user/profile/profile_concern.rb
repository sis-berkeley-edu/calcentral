module User
  module Profile
    module ProfileConcern
      extend ActiveSupport::Concern

      included do
        def is_student?
          affiliations.is_student?
        end

        def matriculated?
          !affiliations.matriculated_but_excluded? && affiliations.not_registered?
        end

        private

        def affiliations
          @affiliations ||= ::User::Profile::Affiliations.new(self)
        end
      end

    end
  end
end
