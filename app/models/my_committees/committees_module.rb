module MyCommittees::CommitteesModule
  extend self

  include LinkFetcher

  COMMITTEE_TYPES = {
    QE: {
      code: 'QE',
      label: 'Qualifying Exam Committee'
    },
    PLN1MASTER: {
      code: 'PLN1MASTER',
      label: 'Master\'s Thesis Committee'
    },
    DOCTORAL: {
      code: 'DOCTORAL',
      label: 'Dissertation Committee'
    }
  }
  DATE_FORMAT = '%b %d, %Y'
  STATUS_ICON_SUCCESS = 'check'
  STATUS_ICON_WARN = 'exclamation-triangle'
  STATUS_ICON_FAIL = 'exclamation-circle'

  def initialize(uid)
    @uid = uid
  end

  def get_empty_committee_members
    {
      chair: [],
      coChair: [],
      insideMembers: [],
      outsideMembers: [],
      additionalReps: [],
      academicSenate: []
    }
  end

  def parse_cs_committee (cs_committee)
    return nil unless cs_committee.present?
    committee = {
      committeeType:  translate_committee_type(cs_committee),
      program:        cs_committee[:studentAcadPlan],
      milestoneAttempts: parse_cs_qualifying_exam_attempts(cs_committee),
      committeeMembers: parse_cs_committee_members(cs_committee)
    }
    set_committee_status(cs_committee, committee)
    committee
  end

  def translate_committee_type(cs_committee)
    committee_type_code = cs_committee[:committeeType].try(:intern)
    COMMITTEE_TYPES[committee_type_code].try(:[], :label)
  end

  def qualifying_exam?(cs_committee)
    cs_committee[:committeeType].to_s.strip.upcase === COMMITTEE_TYPES[:QE][:code]
  end

  def parse_cs_qualifying_exam_attempts(cs_committee)
    qualifying_exam_attempts = []
    if qualifying_exam?(cs_committee)
      qualifying_exam_attempts = parse_cs_milestone_attempts(cs_committee)
    end
    qualifying_exam_attempts
  end

  def parse_cs_milestone_attempt(cs_milestone_attempt)
    milestone_attempt = {
      sequenceNumber: cs_milestone_attempt[:attemptNbr].to_i,
      date: format_date(cs_milestone_attempt[:attemptDate]),
      result: Berkeley::GraduateMilestones.get_status(cs_milestone_attempt[:attemptStatus], Berkeley::GraduateMilestones::QE_RESULTS_MILESTONE)
    }
    milestone_attempt[:display] = format_milestone_attempt(milestone_attempt)
    milestone_attempt
  end

  def parse_cs_committee_member (cs_committee_member)
    {
      name: "#{cs_committee_member[:memberNameFirst]} #{cs_committee_member[:memberNameLast]}",
      email: cs_committee_member[:memberEmail],
      photo: committee_member_photo_url(cs_committee_member),
      primaryDepartment:  cs_committee_member[:memberDeptDescr]
    }
  end

  def parse_cs_committee_student (cs_committee)
    {
      name: "#{cs_committee[:studentNameFirst]} #{cs_committee[:studentNameLast]}",
      email: cs_committee[:studentEmail],
      photo: committee_student_photo_url(cs_committee)
    }
  end

  def committee_member_photo_url (cs_committee_member)
    empl_id = cs_committee_member[:memberEmplid]
    user_id = CalnetCrosswalk::ByCsId.new(user_id: empl_id).lookup_ldap_uid
    "/api/my/committees/photo/member/#{user_id}"
  end

  def committee_student_photo_url (cs_committee)
    empl_id = cs_committee[:studentEmplid]
    user_id = CalnetCrosswalk::ByCsId.new(user_id: empl_id).lookup_ldap_uid
    "/api/my/committees/photo/student/#{user_id}"
  end

  def set_committee_status(cs_committee, committee)
    if qualifying_exam?(cs_committee)
      committee[:statusIcon] = determine_qualifying_exam_status_icon(committee)
      committee[:statusMessage] = determine_qualifying_exam_status_message(cs_committee)
    elsif !is_active?(cs_committee) && cs_committee[:studentFilingDate]
      committee[:statusIcon] = STATUS_ICON_SUCCESS
      committee[:statusMessage] = "Filing Date: #{format_date(cs_committee[:studentFilingDate])}"
    elsif (advanced_date = determine_advanced_date(cs_committee))
      committee[:statusMessage] = "Advanced: #{format_date(advanced_date)}"
    end
  end

  def determine_qualifying_exam_status_icon(committee)
    latest_attempt = committee.try(:[], :milestoneAttempts).try(:first)
    return '' unless latest_attempt
    if latest_attempt.try(:[], :result) == Berkeley::GraduateMilestones::QE_RESULTS_STATUS_PASSED
      STATUS_ICON_SUCCESS
    elsif latest_attempt.try(:[], :sequenceNumber) === 1
      STATUS_ICON_WARN
    else
      STATUS_ICON_FAIL
    end
  end

  def determine_qualifying_exam_status_message(cs_committee)
    if cs_committee[:studentApprovalMilestoneAttempts].blank?
      proposed_exam_date = cs_committee.try(:[], :studentQeExamProposedDate)
      "Proposed Exam Date: #{format_date(proposed_exam_date)}" unless proposed_exam_date.blank?
    end
  end

  def determine_advanced_date(cs_committee)
    if (advanced_date = cs_committee[:studentAdvancedDate]).blank?
      advanced_date = latest_milestone_attempt(cs_committee).try(:[], :attemptDate)
    end
    advanced_date
  end

  def latest_milestone_attempt(cs_committee)
    cs_committee.try(:[], :studentApprovalMilestoneAttempts).try(:sort_by!) do |attempt|
      attempt.try(:[], :attemptNbr)
    end.try(:last)
  end

  def parse_cs_committee_members (cs_committee)
    committee_members_result = get_empty_committee_members
    cs_committee_members = cs_committee.try(:[], :committeeMembers)
    cs_sorted_members = cs_committee_members.try(:sort_by) { |member| [ member[:memberNameLast] || '', member[:memberNameFirst] || ''] }
    cs_sorted_members.try(:each) do |cs_committee_member|
      assign_member_role(committee_members_result, cs_committee_member)
    end
    committee_members_result
  end

  def assign_member_role(committee_members, committee_member)
    if committee_member && committee_member[:memberRole]
      role_key = get_cs_committee_role_key(committee_member[:memberRole])
      committee_members[role_key] << parse_cs_committee_member(committee_member)
    end
  end

  def get_cs_committee_role_key (role_name)
    case role_name
      when 'CHAI'
        :chair
      when 'COCH'
        :coChair
      when 'INSD'
        :insideMembers
      when 'OUTS'
        :outsideMembers
      when 'ACSN', 'ACAD'
        :academicSenate
      when 'ADDL'
        :additionalReps
      else
        :additionalReps
    end
  end

  def is_active?(cs_committee)
    cs_committee.try(:[], :committeeFinishingMilestoneComplete) != 'Y'
  end

  def format_date(unformatted_date)
    formatted_date = ''
    begin
      formatted_date = DateTime.parse(unformatted_date.to_s).strftime(DATE_FORMAT)
    rescue
      logger.error "Bad Format For Committees Date for Class #{self.class.name} feed, uid = #{@uid}"
    end
    formatted_date
  end

end
