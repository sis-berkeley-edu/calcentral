# RailsAdmin config file.
# See github.com/sferik/rails_admin for more information.

# simple adapter class from our AuthenticationStatePolicy (which is pundit-based) to CanCan, which is greatly preferred by rails_admin.
class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :access, :all
      can :dashboard, :all
      if user.policy.can_administrate?
        can :manage, [
          ServiceAlerts::Alert,
          User::Auth
        ]
      end
      if user.policy.can_author?
        can :manage, [Links::Link, Links::LinkCategory, Links::LinkSection, Links::UserRole]
      end
    end
  end
end

RailsAdmin.config do |config|

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['CalCentral', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # We're not using Devise or Warden for RailsAdmin authentication; check for superuser in authorize_with instead.
  config.authenticate_with {
    if cookies[:reauthenticated] || !!Settings.features.reauthentication == false
      policy = AuthenticationState.new(session).policy
      redirect_to main_app.root_path unless policy.can_author?
    else
      redirect_to main_app.reauth_admin_path
    end
  }

  # Because CanCan is not inheriting current_user from ApplicationController, we redefine it.
  config.current_user_method {
    AuthenticationState.new(session)
  }

  config.authorize_with :cancan

  # If you want to track changes on your models:
  # config.audit_with :history, 'Adminuser'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  config.default_items_per_page = 50

  # Exclude specific models (keep the others):
  # config.excluded_models = ['OracleDatabase']

  # Include specific models (exclude the others):
  config.included_models = %w(
    ServiceAlerts::Alert
    User::Auth
  )

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]

  # config.model Links::Link do
  # end

  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.
  #

  config.model 'User::Auth' do
    label 'User Authorizations'
    list do
      field :uc_clc_id do
        column_width 25
        label 'id'
      end
      field :uid do
        column_width 60
        label 'uid'
      end
      field :uc_clc_is_su do
        column_width 20
        label 'superuser?'
      end
      field :uc_clc_is_au do
        column_width 20
        label 'author'
      end
      field :uc_clc_is_vw do
        column_width 20
        label 'viewer'
      end
      field :uc_clc_active do
        column_width 20
        label 'active'
      end
      field :created_at do
        column_width 130
      end
      field :updated_at do
        column_width 130
      end
    end
    create do
      field :uid do
        label 'uid'
        required true
      end
      field :uc_clc_is_su do
        label 'superuser?'
      end
      field :uc_clc_is_au do
        label 'author?'
      end
      field :uc_clc_is_vw do
        label 'viewer?'
      end
      field :uc_clc_active do
        label 'active?'
      end
    end
    edit do
      field :uid do
        label 'uid'
        required true
      end
      field :uc_clc_is_su do
        label 'superuser?'
      end
      field :uc_clc_is_au do
        label 'author?'
      end
      field :uc_clc_is_vw do
        label 'viewer?'
      end
      field :uc_clc_active do
        label 'active?'
      end
    end
  end

  config.model 'ServiceAlerts::Alert' do
    label 'Service Alert'

    list do
      field :uc_clc_id do
        label 'ID'
        column_width 10
      end
      field :uc_alrt_title do
        label 'Title'
        column_width 40
      end
      field :uc_alrt_snippt do
        label 'Snippet'
        column_width 40
      end
      field :uc_alrt_body do
        label 'Body'
        column_width 60
      end
      field :uc_alrt_pubdt do
        label 'Pub Date'
        column_width 60
      end
      field :uc_alrt_display do
        label 'Display'
        column_width 1
      end
      field :uc_alrt_splash do
        label 'Splash Only'
        column_width 1
      end
      field :created_at do
        label 'Created'
        column_width 10
      end
      field :updated_at do
        label 'Updated'
        column_width 10
      end
    end
    create do
      field :uc_alrt_title do
        label 'Title'
        required true
      end
      field :uc_alrt_snippt do
        label 'Snippet'
      end
      field :uc_alrt_body do
        label 'Body'
        required true
      end
      field :uc_alrt_pubdt do
        label 'Pub Date'
        required true
      end
      field :uc_alrt_display do
        label 'Display'
      end
      field :uc_alrt_splash do
        label 'Splash Only'
      end
    end
    edit do
        field :uc_alrt_title do
          label 'Title'
          required true
        end
        field :uc_alrt_snippt do
          label 'Snippet'
        end
        field :uc_alrt_body do
          label 'Body'
          required true
        end
        field :uc_alrt_pubdt do
          label 'Pub Date'
          required true
        end
        field :uc_alrt_display do
          label 'Display'
        end
        field :uc_alrt_splash do
          label 'Splash Only'
        end
    end
    show do
      field :uc_alrt_title do
        label 'Title'
        required true
      end
      field :uc_alrt_snippt do
        label 'Snippet'
      end
      field :uc_alrt_body do
        label 'Body'
        required true
      end
      field :uc_alrt_pubdt do
        label 'Pub Date'
        required true
      end
      field :uc_alrt_display do
        label 'Display'
      end
      field :uc_alrt_splash do
        label 'Splash Only'
      end
    end
  end

  config.navigation_static_label = 'Tools'

  config.navigation_static_links = {
    'Expire Campus Links Cache' => '/api/my/campuslinks/expire',
    'Reload YAML Settings' => '/api/reload_yaml_settings'
  }

end
