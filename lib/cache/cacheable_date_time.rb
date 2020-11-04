module Cache
  # This wrapper class for DateTime works around a marshal/unmarshal issue in JRuby 9.2
  # (https://github.com/jruby/jruby/issues/6385) so that we can store datetime objects in
  # the Rails cache.
  #
  # TODO: Remove this after fixed in jRuby v9.2.14. See SISRP-54265
  class CacheableDateTime < SimpleDelegator
    def marshal_dump
      iso8601(9)
    end

    def marshal_load(serialized)
      __setobj__(DateTime.iso8601(serialized))
    end

    def advance(opts)
      self.class.new(__getobj__.advance(opts))
    end

    def end_of_day
      self.class.new(__getobj__.end_of_day)
    end
  end

end
