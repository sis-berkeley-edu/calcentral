module User
  class Owned
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def uid
      user.uid
    end
  end
end
