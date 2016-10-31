module MyCommittees::CommitteesModule
  extend self

  def initialize(uid)
    @uid = uid
  end

  def get_empty_committee_members
    {
      chair: [],
      coChair: [],
      additionalReps: [],
      academicSenate: []
    }
  end

  def parse_cs_committee (cs_committee)
    return nil unless cs_committee.present?
    {
      committeeType:  cs_committee[:studentMilestoneDescr],
      program:        cs_committee[:studentAcadPlan],
      statusIcon: committee_status_icon(cs_committee),
      statusTitle: committee_status_title(cs_committee),
      statusMessage: committee_status_message(cs_committee),
      committeeMembers: parse_cs_committee_members(cs_committee)
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
    if cs_committee[:committeeType].to_s == 'OUA_FNLZN'
      'Exam Date:'
    else
      'Advancement To Candidacy:'
    end
  end

  def committee_status_message (cs_committee)
    if cs_committee[:committeeType].to_s == 'OUA_FNLZN'
      return cs_committee[:studentQeExamDate].present? ? format_date(cs_committee[:studentQeExamDate]) : 'Pending'
    end
    'Approved'
  end

  def committee_status_icon (cs_committee)
    if cs_committee[:committeeType].to_s == 'OUA_FNLZN' &&
      cs_committee[:studentQeExamDate].blank?
      'exclamation-triangle'
    else
      'check'
    end
  end

  def parse_cs_committee_members (cs_committee)
    committee_members_result = get_empty_committee_members
    cs_committee[:committeeMembers].try(:each) do |cs_committee_member|
      if cs_committee_member && cs_committee_member[:memberRole]
        # Assign the key of committee member based on role code in cs data
        role_key = get_cs_committee_role_key(cs_committee_member[:memberRole])
        committee_members_result[role_key] << parse_cs_committee_member(cs_committee_member)
      end
    end
    committee_members_result
  end

  def get_cs_committee_role_key (role_name)
    case role_name
      when 'CHAI'
        :chair
      when 'COCH', 'INSD'
        :coChair
      when 'ACSN', 'OUTS', 'ACAD'
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
      formatted_date = DateTime.parse(unformatted_date.to_s).strftime("%b %d, %Y")
    rescue
      logger.error "Bad Format For Committees Date for Class #{self.class.name} feed, uid = #{@uid}"
    end
    formatted_date
  end

end
