class AdvisingStudentController < ApplicationController
  include CampusSolutions::StudentLookupFeatureFlagged
  include AdvisorAuthorization

  before_action :api_authenticate
  before_action :authorize_for_student

  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def profile
    student_uid = student_uid_param
    render json: {
      # TODO Fetch from cached endpoints.
      attributes: User::AggregatedAttributes.new(student_uid).get_feed,
      contacts: HubEdos::Contacts.new(user_id: student_uid, include_fields: %w(names addresses phones emails)).get,
      residency: MyAcademics::Residency.new(student_uid).get_feed
    }
  end

  def academics
    render json: MyAcademics::FilteredForAdvisor.from_session('user_id' => student_uid_param).get_feed_as_json
  end

  def academic_status
    render json: HubEdos::AcademicStatus.new(user_id: student_uid_param).get
  end

  def enrollment_instructions
    render json: MyAcademics::ClassEnrollments.new(student_uid_param).get_feed_as_json
  end

  def registrations
    render json: MyAcademics::Registrations.new(student_uid_param).get_feed_as_json
  end

  def advising
    render json: Advising::MyAdvising.new(student_uid_param).get_feed_as_json
  end

  def student_success
    render json: StudentSuccess::Merged.new(user_id: student_uid_param).get_feed
  end

  def resources
    json = CampusSolutions::AdvisingResources.new(user_id: session['user_id'], student_uid: student_uid_param).get
    links = json[:feed] && json[:feed][:ucAdvisingResources] && json[:feed][:ucAdvisingResources][:ucAdvisingLinks]
    if links
      # Advisors get only a subset of links
      keys = [:ucServiceIndicator, :ucStudentAdvisor, :multiYearAcademicPlannerStudentSpecific, :schedulePlannerStudentSpecific,
              :studentAppointments, :studentAdvisorNotes, :studentWebnowDocuments]
      advising_links = links.select { |key| keys.include? key }
      json[:feed][:ucAdvisingResources][:ucAdvisingLinks] = advising_links
    end
    render json: json
  end

  def student_attributes
    render json: HubEdos::StudentAttributes.new(user_id: student_uid_param).get
  end

  def degree_progress_graduate
    render json: DegreeProgress::GraduateMilestones.new(student_uid_param).get_feed_as_json
  end

  private

  def authorize_for_student
    raise NotAuthorizedError.new('The student lookup feature is disabled') unless is_feature_enabled
    authorize_advisor_student_overview current_user.user_id, student_uid_param
  end

  def student_uid_param
    params.require 'student_uid'
  end

end
