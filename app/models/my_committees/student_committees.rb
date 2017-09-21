module MyCommittees
  class StudentCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      result = {
        studentCommittees: []
      }
      feed = CampusSolutions::StudentCommittees.new(user_id: @uid).get[:feed]

      if feed && (cs_committees = feed[:ucSrStudentCommittee][:studentCommittees])
        result[:studentCommittees] = parse_cs_student_committees cs_committees
      end
      result
    end

    def parse_cs_student_committees (cs_committees)
      cs_committees.compact!
      committees_result = []
      cs_committees.try(:each) do |cs_committee|
        committees_result << parse_student_cs_committee(cs_committee)
      end
      committees_result.compact
    end

    def parse_student_cs_committee(cs_committee)
      committee = parse_cs_committee(cs_committee)
      committee[:isActive] = is_active? cs_committee
      committee
    end

    def set_committee_status(cs_committee, committee)
      if qualifying_exam?(cs_committee)
        committee[:statusMessage] = determine_qualifying_exam_status_message(cs_committee)
      end
    end

    def parse_cs_committee_member (cs_committee_member)
      {
        name: "#{cs_committee_member[:memberNameFirst]} #{cs_committee_member[:memberNameLast]}",
        email: cs_committee_member[:memberEmail],
        photo: committee_member_photo_url(cs_committee_member),
        primaryDepartment:  cs_committee_member[:memberDeptDescr],
        serviceRange: format_member_service_dates(cs_committee_member)
      }
    end
  end
end
