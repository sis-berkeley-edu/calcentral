# Provides diploma data related to students
class User::Academics::Diploma
  include Cache::CachedFeed
  include Cache::UserCacheExpiry

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def instance_key
    user.uid
  end

  def get_feed_internal
    as_json
  end

  def as_json(options = {})
    {
      diplomaEligible: show_diploma_eligibility?,
      diplomaReady: user_ready_for_diploma?,
      ssoUrl: sso_url,
      paperDiplomaMessage: messages.paper_diploma_message,
      electronicDiplomaNoticeMessage: messages.electronic_diploma_notice_message,
      electronicDiplomaReadyMessage: messages.electronic_diploma_ready_message,
      electronicDiplomaHelpMessage: messages.electronic_diploma_help_message,
    }
  end

  def sso_url
    ::User::Academics::DiplomaSso.new(user).sso_url
  end

  def show_diploma_eligibility?
    (has_eligible_degree_checkout_status? && user_in_degree_eligible_student_group?) || has_awarded_degree_checkout_status? || user_in_degree_awarded_student_group?
  end

  def user_ready_for_diploma?
    has_awarded_degree_checkout_status? && user_in_degree_awarded_student_group?
  end

  def user_in_degree_awarded_student_group?
    student_attributes.find_all_by_type_code('RDGA').any?
  end

  def user_in_degree_eligible_student_group?
    student_attributes.find_all_by_type_code('RDGE').any?
  end

  def has_awarded_degree_checkout_status?
    @has_awarded_degree_checkout_status ||= eligible_student_plans.detect {|plan| plan.degree_awarded? }.present?
  end

  def has_eligible_degree_checkout_status?
    @has_eligible_degree_checkout_status ||= eligible_student_plans.detect {|plan| plan.degree_eligible? }.present?
  end

  def eligible_student_plans
    @eligible_student_plans ||= active_or_completed_student_plans.select do |plan|
      supported_terms.include?(plan.expected_graduation_term_id)
    end
  end

  def student_attributes
    ::HubEdos::StudentApi::V2::Student::StudentAttributes.new(user)
  end

  def messages
    @diploma_messages ||= ::User::Academics::DiplomaMessages.new(expected_graduation_terms)
  end

  def supported_terms
    messages.supported_terms
  end

  def expected_graduation_terms
    @expected_graduation_terms ||= active_or_completed_student_plans.collect do |plan|
      plan.expected_graduation_term_id
    end
  end

  def active_or_completed_student_plans
    acad_statuses = HubEdos::StudentApi::V2::Student::AcademicStatuses.new(user)
    student_plans = acad_statuses.all.collect do |status|
      status.active_student_plans + status.completed_student_plans
    end.flatten
  end
end
