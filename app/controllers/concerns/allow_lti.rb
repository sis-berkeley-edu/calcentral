module AllowLti
  # Indicates that controller endpoints are either publicly available or accessible by LTI sessions.
  def allow_if_canvas_lti?
    true
  end
end
