module MyCommittees
  class FacultyCommittees

    include CommitteesModule
    include ClassLogger

    def merge(feed)
      feed.merge! get_feed
    end

    def get_feed
      result = {}
      feed = CampusSolutions::FacultyCommittees.new(user_id: @uid).get[:feed]
      if feed && (cs_committees = feed[:ucSrFacultyCommittee].try(:[], :facultyCommittees))
        # Service range will be parsed from nested member data with match on emplid
        @emplid = feed[:ucSrFacultyCommittee].try(:[], :emplid)
        result[:facultyCommittees] = parse_cs_faculty_committees cs_committees
      end
      result
    end

    def parse_cs_faculty_committees (cs_committees)
      committees_result = {
        active: [],
        completed: []
      }
      cs_committees.try(:each) do |cs_committee|
        faculty_committee = parse_cs_committee(cs_committee)
        # Add additional pieces of data needed faculty committees
        faculty_committee.merge!(
          student: parse_cs_committee_student(cs_committee),
          serviceRange: parse_cs_faculty_committee_svc(cs_committee)
        )
        # Add the committee to the corresponding array based on completed flag
        if cs_committee[:studentMilestoneComplete] && cs_committee[:studentMilestoneComplete] != 'N'
          committees_result[:active] << faculty_committee
        else
          committees_result[:completed] << faculty_committee
        end
      end
      committees_result
    end

    def parse_cs_faculty_committee_svc (cs_committee)
      committee_service_range_result = ''
      user_committee = cs_committee[:committeeMembers].try(:select) do |mem|
        mem[:memberEmplid].present? &&  mem[:memberEmplid] == @emplid
      end.first
      start_date = user_committee.try(:[], :memberStartDate)
      end_date = user_committee.try(:[], :memberEndDate)
      committee_service_range_result = "#{ format_date(start_date) } - #{ format_date(end_date) }" if user_committee
      committee_service_range_result
    end

  end
end
