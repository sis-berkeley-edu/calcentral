module User
  class SearchUsers
    extend Cache::Cacheable

    def initialize(options={})
      @options = options
    end

    def search_users
      results = []
      uids = id_to_uids @options[:id]
      uids.each do |uid|
        if (user = User::SearchUsersByUid.new(@options.merge(id: uid)).search_users_by_uid)
          results << user
        end
      end
      results
    end

    def id_to_uids(id)
      results = Set[id]
      if (uid = User::Identifiers.lookup_ldap_uid id)
        results << uid
      end
      results
    end

  end
end
