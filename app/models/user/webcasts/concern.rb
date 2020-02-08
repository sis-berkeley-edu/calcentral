require 'active_support/concern'

module User
  module Webcasts
    module Concern
      extend ActiveSupport::Concern

      included do
        def webcasts
          @webcasts ||= ::User::Webcasts::Webcasts.new(self)
        end
      end
    end
  end
end
