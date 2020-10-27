class Api::UserAuthsController < Api::BaseController
  before_action :require_admin
  skip_before_action :require_admin, only: [:show]
  before_action :user_auth, except: [:index, :create]

  def index
    scope = UserAuth
    scope = scope.where(uid: params[:uid]) if params[:uid]
    scope = scope.page(params[:page])

    render json: {
      current_page: scope.current_page,
      total_pages: scope.total_pages,
      user_auths: scope
    }
  end

  def show
    render json: user_auth
  end

  def create
    @user_auth = UserAuth.new user_auth_params

    if @user_auth.save
      render json: @user_auth, status: :created
    else
      render json: @user_auth.errors, status: :unprocessable_entity
    end
  end

  def update
    if user_auth.update_attributes user_auth_params
      render json: @user_auth, status: :ok
    else
      render json: @user_auth.errors, status: :unprocessable_entity
    end
  end

  def destroy
    user_auth.destroy
  end

  private

  def user_auth
    @user_auth ||= if params[:id]
      UserAuth.find params[:id]
    elsif params[:uid] && session['user_id'] == params[:uid]
      UserAuth.where(uid: params[:uid]).first
    end
  end

  def user_auth_params
    params.require(:user_auth).permit(
      :id,
      :uid,
      :is_active,
      :is_author,
      :is_viewer,
      :is_superuser
    )
  end
end
