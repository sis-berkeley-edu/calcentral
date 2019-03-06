module Cache
  module UserCacheExpiry

    def self.notify(uid)
      (Cache::UserCacheExpiry.classes).each do |klass|
        klass.expire uid
      end
    end

    def self.included(klass)
      unless klass.respond_to?(:expire)
        raise ArgumentError.new "Class #{klass.name} must implement expire to be expirable"
      end
      @classes ||= []
      @classes << klass
    end

    def self.classes
      @classes
    end

  end
end
