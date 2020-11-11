# Configuration for the secure_headers gem, which sets X-Frame and CSP headers.
# Docs at https://github.com/github/secure_headers/blob/v6.3.1/README.md
module Calcentral
  class Application < Rails::Application
    config.before_initialize do
      ::SecureHeaders::Configuration.default do |config|
        config.x_frame_options = "DENY"
        config.x_xss_protection = "1; mode=block"
      end

      SecureHeaders::Configuration.override(:enable_unsafe_inline_scripting_nsc) do |config|
        config.csp = {
          default_src: %w('self'),
          script_src: %w('unsafe-inline')
        }
      end
    end
  end
end
