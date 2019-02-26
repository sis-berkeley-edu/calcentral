class AdvisingStudentController < ApplicationController
  include CampusSolutions::StudentLookupFeatureFlagged
  include AdvisorAuthorization

  before_action :api_authenticate
  before_action :authorize_for_student

  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def academics
    render json: MyAcademics::FilteredForAdvisor.from_session('user_id' => student_uid_param).get_feed_as_json
  end

  def academics_cache_expiry
    MyAcademics::FilteredForAdvisor.expire student_uid_param
    render :nothing => true
  end

  def advising
    render json: Advising::MyAdvising.new(student_uid_param).get_feed_as_json
  end

  def student_committees
    committees = MyCommittees::Merged.new(student_uid_param).get_feed
    render json: {
      studentCommittees: committees.try(:[], :studentCommittees)
    }
  end

  def degree_progress_graduate
    render json: DegreeProgress::GraduateMilestones.new(student_uid_param).get_feed_as_json
  end

  def degree_progress_undergrad
    render json: DegreeProgress::UndergradRequirements.new(student_uid_param).get_feed_as_json
  end

  def enrollment_instructions
    render json: MyAcademics::ClassEnrollments.new(student_uid_param).get_feed_as_json
  end

  def holds
    render json: MyAcademics::MyHolds.new(student_uid_param).get_feed_as_json
  end

  def standings
    render json: MyAcademics::MyStandings.new(student_uid_param).get_feed_as_json
  end

  def profile
    student_uid = student_uid_param
    render json: {
      academicRoles: MyAcademics::MyAcademicRoles.new(student_uid).get_feed,
      attributes: User::AggregatedAttributes.new(student_uid).get_feed,
      contacts: HubEdos::Contacts.new(user_id: student_uid, include_fields: %w(names addresses phones emails)).get,
      residency: MyAcademics::Residency.new(student_uid).get_feed
    }
  end

  def registrations
    render json: MyRegistrations::Statuses.new(student_uid_param).get_feed_as_json
  end

  def resources
    render json: AdvisingResources.student_specific_links(student_uid_param)
  end

  def student_success
    render json: StudentSuccess::Merged.new(user_id: student_uid_param).get_feed
  end

  def transfer_credit
    render json: MyAcademics::MyTransferCredit.new(student_uid_param).get_feed_as_json
  end

  private

  def authorize_for_student
    raise NotAuthorizedError.new('The student lookup feature is disabled') unless is_feature_enabled
    authorize_advisor_access_to_student current_user.user_id, student_uid_param
  end

  def student_uid_param
    params.require 'student_uid'
  end

end
