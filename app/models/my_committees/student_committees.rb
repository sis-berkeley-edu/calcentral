module MyCommittees
  class StudentCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      result = {
        studentCommittees: [],
        committeeRequestChangeLink: fetch_link('UC_CX_GT_AAQEAPPLIC_ADD')
      }
      feed = CampusSolutions::StudentCommittees.new(user_id: @uid).get[:feed]

      if feed && (cs_committees = feed[:ucSrStudentCommittee][:studentCommittees])
        # Only process and return active committees
        active_committees = cs_committees.select{|c| c.present? && c[:studentMilestoneCompleteDate].blank?}
        result[:studentCommittees] = parse_cs_student_committees active_committees
      end
      result
    end

    def parse_cs_student_committees (cs_committees)
      committees_result = []
      cs_committees.try(:each) do |cs_committee|
        committees_result << parse_cs_committee(cs_committee)
      end
      committees_result.compact
    end

  end
end
