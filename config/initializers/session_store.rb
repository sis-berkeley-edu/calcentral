# Be sure to restart your server when you modify this file.

Calcentral::Application.config.session_store :cookie_store,
  :key => '_calcentral_session',
  :expire_after => Settings.application.session_expiration
