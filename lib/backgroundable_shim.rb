module BackgroundableShim

  def self.included(base)
    if Settings.background_torquebox
      base.send :include, TorqueBox::Messaging::Backgroundable
    else
      base.send :include, BackgroundThread
    end
  end

end
