class UserSpecificModel
  include ActiveAttrModel
  include ClassLogger
  attr_reader :authentication_state

  def self.from_session(session_state, options={})
    self.new session_state['user_id'], options.merge(filtered session_state)
  end

  def initialize(uid, options={})
    @uid = uid
    @options = options
    @authentication_state = AuthenticationState.new @options.merge('user_id' => @uid)
  end

  def instance_key
    @uid
  end

  def directly_authenticated?
    @authentication_state.directly_authenticated?
  end

  def self.filtered(session={})
    Hash[SessionKey::ALL_KEYS.collect { |k| [k, session[k]] }]
  end
end
