module MyAcademics
  class FacultyDelegate < UserSpecificModel

    def merge(data)
      semesters = is_user_student? ? data[:semesters] : data[:teachingSemesters]
      if semesters
        add_grd_access_to_semesters(semesters)
      end
    end


    def is_user_student?
      User::SearchUsersByUid.new(id: @uid, roles: [:student]).search_users_by_uid.present?
    end

    def add_grd_access_to_semesters(teaching_semesters)
      teaching_semesters.try(:each) do |semester|
        term_code = Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
        add_grd_access_to_classes(semester[:classes], term_code)
      end
    end

    def add_grd_access_to_classes(semester_classes, term_code)
      semester_classes.try(:each) do |semester_class|
        add_grd_access_to_class(semester_class, term_code)
      end
    end

    def add_grd_access_to_class(semester_class, term_code)
      semester_class.try(:[],:sections).try(:each) do |section|
        ccn = section[:ccn]
        cs_delegate_data = CampusSolutions::FacultyDelegate.new(term_id: term_code, course_id: ccn).get
        add_grd_access_to_section(section, cs_delegate_data)
      end
    end

    def add_grd_access_to_section(section, cs_delegate_data)
      section_key = section[:is_primary_section] ? :primarySection : :notPrimarySection
      section.try(:[],:instructors).try(:each) do |instructor|
        add_grd_access_to_instructor(instructor, cs_delegate_data, section_key)
      end
    end

    def add_grd_access_to_instructor(instructor, cs_delegate_data, section_key)
      instructor_delegate_data = parse_cs_delegate_data(cs_delegate_data, instructor[:uid])
      cs_grading_role =  parse_cs_grading_role(instructor_delegate_data.try(:[],:instrRoleCode))
      cs_grading_access =  instructor_delegate_data.try(:[],:gradeRstrAccess)
      instructor.merge!(
        {
          csGradeAccessCode: cs_grading_access,
          csDelegatRole: cs_grading_role,
          ccGradingAccees: parse_cc_grading_access(cs_grading_access),
          ccDelegateRole: grading_access_role_mapping[section_key][cs_grading_role][:ccDelegateRole],
          ccDelegateRoleOrder: grading_access_role_mapping[section_key][cs_grading_role][:ccDelegateRoleOrder]
        })
    end

    def parse_cc_grading_access(cs_grading_access)
      case cs_grading_access
        when 'A'
          :approveGrades
        when 'G', 'P'
          :enterGrades
        else
          :noGradeAccess
      end
    end

    def parse_cs_grading_role(cs_grading_role)
      case cs_grading_role
        when 'PI'
          :PI
        when 'ICNT'
          :ICNT
        when 'TNIC'
          :TNIC
        when 'APRX'
          :APRX
        else
          :noCsData
      end
    end

    def grading_access_role_mapping
      {
        primarySection: {
          PI: {
            ccDelegateRole: 'Instr. of Record',
            ccDelegateRoleOrder: 1
          },
          ICNT: {
            ccDelegateRole: 'Instr. of Record',
            ccDelegateRoleOrder: 1
          },
          TNIC: {
            ccDelegateRole: 'Teaching',
            ccDelegateRoleOrder: 2
          },
          APRX: {
            ccDelegateRole: 'Proxy',
            ccDelegateRoleOrder: 3
          },
          noCsData: {
            ccDelegateRole: '',
            ccDelegateRoleOrder: 5
          }
        },
        notPrimarySection: {
          PI: {
            ccDelegateRole: 'Instr. of Record',
            ccDelegateRoleOrder: 1
          },
          ICNT: {
            ccDelegateRole: 'Instr. of Record',
            ccDelegateRoleOrder: 1
          },
          TNIC: {
            ccDelegateRole: 'GSI',
            ccDelegateRoleOrder: 4
          },
          APRX: {
            ccDelegateRole: 'Proxy',
            ccDelegateRoleOrder: 3
          },
          noCsData: {
            ccDelegateRole: '',
            ccDelegateRoleOrder: 5
          }
        }
      }
    end

    def parse_cs_delegate_data(cs_delegate_date, instructor_uid)
      instructor_emplid = CalnetCrosswalk::ByUid.new(user_id: instructor_uid ).lookup_campus_solutions_id
      delegate_array = cs_delegate_date.try(:[],:feed).try(:[],:ucSrFacultyDelegates).try(:[],:ucSrFacultyDelegate)
      delegate_array =  delegate_array.blank? || delegate_array.kind_of?(Array) ? delegate_array : [] << delegate_array
      delegate_array.try(:find) do |delegate|
        delegate[:emplid].present? && delegate[:emplid] == instructor_emplid
      end
    end
  end
end
