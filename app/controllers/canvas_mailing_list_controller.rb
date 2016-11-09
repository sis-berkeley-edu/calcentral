# This mailing list controller (singular) allows instructors and admins to manage a single mailing list for a single
# course site, as distinct from CanvasMailingListsController (plural), which allows admins to administer mailing lists
# across a Canvas instance.

class CanvasMailingListController < ApplicationController
  include AllowLti
  include DisallowAdvisorViewAs
  include ClassLogger
  include SpecificToCourseSite

  before_action :api_authenticate
  before_action :authorize_mailing_list_management
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_mailing_list_management
    course_id = canvas_course_id
    raise Pundit::NotAuthorizedError, 'Canvas Course ID not present' if course_id.blank?
    canvas_course = Canvas::Course.new(user_id: session['user_id'], canvas_course_id: course_id)
    authorize canvas_course, :can_manage_mailing_list?
  end

  # GET /api/academics/canvas/mailing_list

  def show
    list = MailingLists::SiteMailingList.find_or_initialize_by canvas_site_id: canvas_course_id.to_s
    render json: list.to_json
  end

  # POST /api/academics/canvas/mailing_list/create

  def create
    list = MailingLists::MailgunList.create! canvas_site_id: canvas_course_id.to_s
    list.populate
    render json: list.to_json
  end
end
