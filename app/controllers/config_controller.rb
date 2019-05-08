class ConfigController < ApplicationController
  include AllowDelegateViewAs
  include AllowLti
  before_filter :get_settings, :initialize_calcentral_config

  def get
    configs = @calcentral_config.merge(
      {
        # See http://git.io/rgw3Pg
        csrfParam: request_forgery_protection_token,
        csrfToken: form_authenticity_token
      }).merge proxies
    render json: configs.to_json.html_safe
  end

  def proxies
    return {} unless current_user.policy.can_administrate?
    {
      proxies:
      {
        campusSolutions: Settings.campus_solutions_proxy.base_url,
        hubEdos: Settings.hub_edos_proxy.base_url,
        calnetCrosswalk: Settings.calnet_crosswalk_proxy.base_url,
        casServer: Settings.cas_server,
        ldapHost: Settings.ldap.host
      }
    }
  end
end
