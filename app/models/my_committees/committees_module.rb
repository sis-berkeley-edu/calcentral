module MyCommittees::CommitteesModule
  extend self

  COMMITTEE_TYPE_EXAM = 'QECOMM'
  DATE_FORMAT = '%b %d, %Y'

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

  def parse_cs_committee (cs_committee, include_inactive)
    return nil unless cs_committee.present?
    {
      committeeType:  cs_committee[:committeeDescrlong],
      program:        cs_committee[:studentAcadPlan],
      statusIcon: committee_status_icon(cs_committee),
      statusTitle: committee_status_title(cs_committee),
      statusMessage: committee_status_message(cs_committee),
      committeeMembers: parse_cs_committee_members(cs_committee, include_inactive)
    }
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

  def committee_status_title (cs_committee)
    if cs_committee[:committeeType].to_s == COMMITTEE_TYPE_EXAM
      'Exam Date:'
    else
      'Advancement To Candidacy:'
    end
  end

  def committee_status_message (cs_committee)
    if cs_committee[:committeeType].to_s == COMMITTEE_TYPE_EXAM
      return cs_committee[:studentQeExamDate].present? ? format_date(cs_committee[:studentQeExamDate]) : 'Pending'
    end
    'Approved'
  end

  def committee_status_icon (cs_committee)
    if cs_committee[:committeeType].to_s == COMMITTEE_TYPE_EXAM &&
      cs_committee[:studentQeExamDate].blank?
      'exclamation-triangle'
    else
      'check'
    end
  end

  def parse_cs_committee_members (cs_committee, include_inactive)
    committee_members_result = get_empty_committee_members
    cs_committee_members = filter_members(cs_committee[:committeeMembers], include_inactive)
    cs_sorted_members = cs_committee_members.try(:sort_by) { |member| [ member[:memberNameLast] || '', member[:memberNameFirst] || ''] }
    cs_sorted_members.try(:each) do |cs_committee_member|
      if cs_committee_member && cs_committee_member[:memberRole]
        # Assign the key of committee member based on role code in cs data
        role_key = get_cs_committee_role_key(cs_committee_member[:memberRole])
        committee_members_result[role_key] << parse_cs_committee_member(cs_committee_member)
      end
    end
    committee_members_result
  end

  def filter_members(cs_committee_members, include_inactive)
    return cs_committee_members if include_inactive
      cs_committee_members.try(:select) do |member|
        is_member_active?(member[:memberEndDate])
    end
  end

  def is_member_active?(member_end_date)
    begin
      return DateTime.parse(member_end_date) >= DateTime.now
    rescue
      return true
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

  def format_date(unformatted_date)
    formatted_date = ''
    begin
      formatted_date = DateTime.parse(unformatted_date.to_s).strftime(DATE_FORMAT)
    rescue
      logger.error "Bad Format For Committees Date for Class #{self.class.name} feed, uid = #{@uid}"
    end
    formatted_date
  end

  def fetch_link(link_key, placeholders = {})
    link = CampusSolutions::Link.new.get_url(link_key, placeholders).try(:[], :link)
    logger.debug "Could not retrieve CS link #{link_key} for Class #{self.class.name} feed, uid = #{@uid}" unless link
    link
  end

end
