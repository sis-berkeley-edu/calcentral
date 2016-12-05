module MyAcademics
  class FacultyDelegate < UserSpecificModel

    def merge(data)
      teaching_semesters = data[:teachingSemesters]
      if teaching_semesters
        add_grd_access_to_semesters(teaching_semesters)
      end
      semesters = data[:semesters]
      if semesters
        add_grd_access_to_semesters(semesters)
      end
    end

    def add_grd_access_to_semesters(teaching_semesters)
      teaching_semesters.try(:each) do |semester|
        add_grd_access_to_classes(semester[:classes])
      end
    end

    def add_grd_access_to_classes(semester_classes)
      semester_classes.try(:each) do |semester_class|
        add_grd_access_to_class(semester_class)
      end
    end

    def add_grd_access_to_class(semester_class)
      semester_class.try(:[],:sections).try(:each) do |section|
        ccn = section[:ccn]
        add_grd_access_to_section(section)
      end
    end

    def add_grd_access_to_section(section)
      section_key = section[:is_primary_section] ? :primarySection : :notPrimarySection
      section.try(:[],:instructors).try(:each) do |instructor|
        add_grd_access_to_instructor(instructor, section_key)
      end
    end

    def add_grd_access_to_instructor(instructor, section_key)
      cs_grading_role = parse_cs_grading_role(instructor.try(:[], :role))
      cs_grading_access = instructor.try(:[], :gradeRosterAccess)
      instructor.merge!(
        {
          csGradeAccessCode: cs_grading_access,
          csDelegateRole: cs_grading_role,
          ccGradingAccess: parse_cc_grading_access(cs_grading_access),
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

  end
end
