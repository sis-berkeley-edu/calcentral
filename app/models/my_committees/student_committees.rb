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
        result[:studentCommittees] = parse_cs_student_committees cs_committees
      end
      result
    end

    def parse_cs_student_committees (cs_committees)
      cs_committees.compact!
      committees_result = []
      cs_committees.try(:each) do |cs_committee|
        remove_inactive_members(cs_committee)
        committees_result << parse_cs_committee(cs_committee)
      end
      committees_result.compact
    end

    def remove_inactive_members(cs_committee)
      cs_committee[:committeeMembers].try(:reject!) do |member|
        inactive?(member)
      end
    end

    def inactive?(committee_member)
      inactive = false;
      begin
        inactive = Time.zone.parse(committee_member[:memberEndDate].to_s).to_datetime.try(:past?)
      rescue
        logger.error "Bad Format for committee member end date; Class #{self.class.name} feed, uid = #{@uid}"
      end
      inactive
    end

  end
end
