class SearchUsersController < ApplicationController
  include ViewAsAuthorization

  before_action :api_authenticate

  rescue_from Errors::BadRequestError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  DEFAULT_LIMIT_SEARCH_RESULTS = 50

  def by_id
    opts = user_search_constraints
    id = params.require 'id'
    users = User::SearchUsers.new(opts.merge id: id).search_users
    render json: { users: prepare_to_render(users) }.to_json
  end

  def by_id_or_name
    opts = user_search_constraints
    id_or_name = params.require 'input'
    users = User::SearchUsersByName.new.search_by(id_or_name, opts)
    render json: { users: prepare_to_render(users.take(limit)) }.to_json
  end

  private

  def prepare_to_render(users)
    unless users.nil? || users.empty?
      # Give the front-end the camelCase it wants.
      users.map! { |user| HashConverter.camelize user }
      # Identify users in the result-set which were once "saved".
      if (saved_users = User::StoredUsers.get(current_user.real_user_id)[:saved])
        stored_uid_list = saved_users.map { |saved_user| saved_user['ldap_uid'] }
        users.each { |user| user[:saved] = stored_uid_list.include? user[:ldapUid] }
      end
    end
    # If users is a Set then uniqueness is enforced by default
    users.is_a?(Array) ? users.uniq { |user| user[:ldapUid] } : users
  end

  def limit
    return DEFAULT_LIMIT_SEARCH_RESULTS unless (arg = params[:limit])
    raise Errors::BadRequestError, "The 'limit' param must be a number greater than zero. Invalid: #{arg}" if (limit = arg.to_i) <= 0
    limit
  end

end
