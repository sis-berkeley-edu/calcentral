module User
  class SearchUsers
    extend Cache::Cacheable
    include User::Parser

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
      results = Set.new
      [CalnetCrosswalk::ByUid, CalnetCrosswalk::ByCsId].each do |proxy_class|
        proxy = proxy_class.new(user_id: id)
        if (uid = proxy.lookup_ldap_uid)
          results << uid
        end
      end
      results
    end

  end
end
