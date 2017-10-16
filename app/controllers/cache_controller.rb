class CacheController < ApplicationController
  include ClassLogger

  before_filter :check_permission
  rescue_from Errors::ClientError, with: :handle_client_error

  def clear
    logger.warn "Clearing all cache entries at request of #{current_user.real_user_id}"
    Rails.cache.clear
    render :json => {cache_cleared: true}
  end

  def delete
    key = params['key']
    deleted = Rails.cache.delete(key)
    logger.warn "Deleted cache_key #{key} at request of #{current_user.real_user_id}"
    render json: {deleted: deleted}
  end

  private

  def check_permission
    authorize(current_user, :can_clear_cache?)
  end
end
