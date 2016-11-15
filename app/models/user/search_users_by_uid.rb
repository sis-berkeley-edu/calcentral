module User
  class SearchUsersByUid

    def initialize(options={})
      @options = options
    end

    def search_users_by_uid
      # TODO Try reading User::Api cache first.
      user = User::AggregatedAttributes.new(@options[:id]).get_feed
      user if !user[:unknown] &&
        (@options[:roles].blank? || @options[:roles].find { |role| user[:roles][role] }) &&
        (@options[:except].blank? || !(@options[:except].find { |role| user[:roles][role] }))
    end

  end
end
