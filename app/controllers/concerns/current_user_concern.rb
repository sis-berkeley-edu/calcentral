module CurrentUserConcern
  extend ActiveSupport::Concern

  included do
    private

    def user
      @user ||= User::Current.new(session['user_id'])
    end
  end
end
