module MyCommittees
  class Merged < UserSpecificModel

    include Cache::CachedFeed
    include MergedModel

    def self.providers
      [
        MyCommittees::StudentCommittees,
        MyCommittees::FacultyCommittees
      ]
    end

    def get_feed_internal
      feed = {}
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge feed
      end
      feed
    end

    def photo_data_or_file(person_id)
      photo_feed = Cal1card::Photo.new(person_id).get_feed
      if photo_feed[:photo]
        {
          size: photo_feed[:length],
          data: photo_feed[:photo]
        }
      end
    end


    def can_user_see_student_photo?(student_id)
      committees = get_feed_internal
      if committees[:facultyCommittees]
        # Only show pictures for active committees
        is_id_in_student_photo_urls?(student_id,committees[:facultyCommittees][:active])
      else
        false
      end
    end

    def can_user_see_member_photo?(member_id)
      committees = get_feed_internal
      if committees[:studentCommittees].present? &&
        committees[:facultyCommittees].present?
        is_id_in_member_photo_urls?(member_id,committees)
      else
        false
      end
    end

    def is_id_in_student_photo_urls?(student_id, faculty_committees)
      faculty_committees.find { |afc| afc[:student][:photo].to_s == "/api/my/committees/photo/student/#{ student_id }" }
    end

    def is_id_in_member_photo_urls?(member_id, committees)
      is_id_in_committees_photo_url?(member_id, committees[:studentCommittees]) ||
        is_id_in_committees_photo_url?(member_id, committees[:facultyCommittees][:active])
    end

    def is_id_in_committees_photo_url?(member_id, committees)
      committees.find do |com|
        members = com[:committeeMembers]
        photo_url = "/api/my/committees/photo/member/#{ member_id }"
        [:chair, :academicSenate, :coChair, :additionalReps].find do |chairType|
          members[chairType].find {|mem| mem[:photo].to_s == photo_url }
        end
      end
    end

  end
end
