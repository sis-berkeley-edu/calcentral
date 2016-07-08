module Proxies
  module Tls12
    def request_options(opts = {})
      {
        ssl_version: 'TLSv1_2'
      }.deep_merge super(opts)
    end
  end
end
