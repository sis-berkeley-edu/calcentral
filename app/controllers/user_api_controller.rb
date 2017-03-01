class UserApiController < ApplicationController
  extend Cache::Cacheable
  include AllowDelegateViewAs
  include AllowLti

  def self.expire(id = nil)
    # no-op; this class uses the cache only to reduce the number of writes to User::Visit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def am_i_logged_in
    response.headers['Cache-Control'] = 'no-cache, no-store, private, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
    render :json => {
      :amILoggedIn => !!session['user_id']
    }.to_json
  end

  def mystatus
    ActiveRecordHelper.clear_stale_connections
    status = {}
    features = HashConverter.camelize Settings.features.marshal_dump

    if (user_id = session['user_id'])
      # wrap User::Visit.record_session inside a cache lookup so that we have to write User::Visit records less often.
      self.class.fetch_from_cache(Cache::KeyGenerator.per_view_as_type user_id, session) do
        User::Visit.record user_id if current_user.directly_authenticated?
        true
      end
      status.merge!({
        :isBasicAuthEnabled => Settings.developer_auth.enabled,
        :isLoggedIn => true,
        :features => features,
        :youtubeSplashId => Settings.youtube_splash_id
      })
      # Unlike some other feeds which are filtered for View-As above the caching layer,
      # User::Api specifies separate cache keys for every view-as user. As a result,
      # customization can be handled within the model itself.
      status.merge! User::Api.from_session(session).get_feed
    else
      status.merge!({
        :isBasicAuthEnabled => Settings.developer_auth.enabled,
        :isLoggedIn => false,
        :features => features,
        :youtubeSplashId => Settings.youtube_splash_id
      })
    end
    render :json => status.to_json
  end

  def record_first_login
    User::Api.from_session(session).record_first_login if current_user.directly_authenticated?
    render :nothing => true, :status => 204
  end

end
