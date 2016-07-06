module Proxies
  module AuthenticatedApi
    def request_options(opts = {})
      opts = super(opts)
      if @settings.app_id.present? && @settings.app_key.present?
        opts = {headers: {
          'app_id' => @settings.app_id,
          'app_key' => @settings.app_key
        }}.deep_merge opts
      elsif @settings.username.present? && @settings.password.present?
        opts[:basic_auth] = {
          username: @settings.username,
          password: @settings.password
        }
      end
      opts
    end
  end
end
