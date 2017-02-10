module MyCommittees
  class StudentCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      #TODO: un-comment the 'request change' link (see SISRP-30410)
      result = {
        studentCommittees: [],
        #committeeRequestChangeLink: fetch_link('UC_CX_GT_AAQEAPPLIC_ADD')
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
        committees_result << parse_cs_committee(cs_committee)
      end
      committees_result.compact
    end

  end
end
