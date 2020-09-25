describe HubEdos::ClassesApi::V1::Section do
  let(:attributes_hash) do
    {
      'id' => 15476,
      'number' => '001',
      'component' => {
        'code' => 'IND',
        'description' => 'Independent Study'
      },
      'displayName' => '2021 Spring ECON H195B 001 IND 001',
      'instructionMode' => {
        'code' => 'P',
        'description' => 'In-Person Instruction'
      },
      'type' => {
        'code' => 'E',
        'description' => 'Enrollment',
        'formalDescription' => 'Enrollment Section'
      },
      'academicOrganization' => {
        'code' => 'ECON',
        'description' => 'Economics',
        'formalDescription' => 'Economics'
      },
      'academicGroup' => {
        'code' => 'CLS',
        'description' => 'L&S',
        'formalDescription' => 'College of Letters and Science'
      },
      'startDate' => '2021-01-19',
      'endDate' => '2021-05-07',
      'status' => {
        'code' => 'A',
        'description' => 'Active'
      },
      'association' => {
        'primary' => true,
        'primaryAssociatedComponent' => {
          'code' => 'IND',
          'description' => 'Independent Study'
        },
        'primaryAssociatedSectionId' => 15476,
        'primaryAssociatedSectionIds' => [15476],
        'associatedClass' => 1
      },
      'enrollmentStatus' => {
        'status' => {
          'code' => 'O',
          'description' => 'Open'
        },
        'enrolledCount' => 0,
        'reservedCount' => 0,
        'waitlistedCount' => 0,
        'minEnroll' => 0,
        'maxEnroll' => 16,
        'maxWaitlist' => 0,
        'openReserved' => 0
      },
      'printInScheduleOfClasses' => true,
      'addConsentRequired' => {
        'code' => 'D',
        'description' => 'Department Consent Required'
      },
      'dropConsentRequired' => {
        'code' => 'N',
        'description' => 'No Special Consent Required'
      },
      'graded' => true,
      'feesExist' => false,
      'roomShare' => false,
      'sectionAttributes' => [
        {
          'attribute' => {
            'code' => 'CCLV',
            'description' => 'CRSE LEVEL',
            'formalDescription' => 'Academic Course Level'
          },
          'value' => {
            'code' => 'UGUD',
            'description' => 'UG Upper Division',
            'formalDescription' => 'Undergraduate Upper Division Course'
          }
        },
        {
          'attribute' => {
            'code' => 'TIE',
            'description' => 'Instr Type',
            'formalDescription' => 'Instructional Activity Types'
          },
          'value' => {
            'code' => 'INDV',
            'description' => 'Individualized Instruction',
            'formalDescription' => 'Emphasizing Independent Inquiry'
          }
        },
        {
          'attribute' => {
            'code' => 'VUOC',
            'description' => 'VCREDIT',
            'formalDescription' => 'Variable Units of Credit'
          },
          'value' => {
            'code' => 'R',
            'description' => 'Inclusive',
            'formalDescription' => 'Inclusive range from Unit 1 or Unit 2'
          }
        }
      ],
      'meetings' => [
        {
          'number' => 1,
          'meetsMonday' => false,
          'meetsTuesday' => false,
          'meetsWednesday' => false,
          'meetsThursday' => false,
          'meetsFriday' => false,
          'meetsSaturday' => false,
          'meetsSunday' => false,
          'startTime' => '00:00:00',
          'endTime' => '00:00:00',
          'location' => {},
          'building' => {},
          'assignedInstructors' => [
            {
              'assignmentNumber' => 1,
              'instructor' => {
                'identifiers' => [
                  {
                    'type' => 'student-id',
                    'id' => '11667051',
                    'disclose' => false
                  },
                  {
                    'type' => 'campus-uid',
                    'id' => '61889',
                    'disclose' => true
                  },
                  {
                    'type' => 'Social Security Number',
                    'id' => '000-00-0000',
                    'disclose' => false
                  },
                  {
                    'type' => 'DB2',
                    'id' => '11667051',
                    'disclose' => false
                  },
                  {
                    'type' => 'HCM Legacy',
                    'id' => '011223344',
                    'disclose' => false
                  },
                  {
                    'type' => 'HCM System',
                    'id' => '10144556',
                    'disclose' => false
                  }
                ],
                'names' => [
                  {
                    'type' => {
                      'code' => 'PRF',
                      'description' => 'Preferred'
                    },
                    'familyName' => 'Bear',
                    'givenName' => 'Oski',
                    'formattedName' => 'Oski Bear',
                    'disclose' => false,
                    'uiControl' => {
                      'code' => 'U',
                      'description' => 'Edit - No Delete'
                    },
                    'fromDate' => '1982-01-26'
                  },
                  {
                    'type' => {
                      'code' => 'PRI',
                      'description' => 'Primary'
                    },
                    'familyName' => 'Bear',
                    'givenName' => 'Wuotan',
                    'formattedName' => 'Wuotan Bear',
                    'disclose' => false,
                    'uiControl' => {
                      'code' => 'D',
                      'description' => 'Display Only'
                    },
                    'fromDate' => '1982-01-26'
                  }
                ],
                'emails' => [
                  {
                    'type' => {
                      'code' => 'CAMP',
                      'description' => 'Campus'
                    },
                    'emailAddress' => 'oskibear@berkeley.edu',
                    'primary' => true,
                    'disclose' => false,
                    'uiControl' => {
                      'code' => 'D',
                      'description' => 'Display Only'
                    }
                  }
                ]
              },
              'role' => {
                'code' => 'PI',
                'description' => '1-TIC',
                'formalDescription' => 'Teaching and In Charge'
              },
              'printInScheduleOfClasses' => true,
              'gradeRosterAccess' => {
                'code' => 'A',
                'description' => 'Approve',
                'formalDescription' => 'Approve'
              }
            }
          ],
          'startDate' => '2021-01-19',
          'endDate' => '2021-05-07',
          'meetingTopic' => {}
        }
      ],
      'class' => {
        'course' => {
          'identifiers' => [
            {
              'type' => 'cs-course-id',
              'id' => '105330'
            }
          ],
          'subjectArea' => {
            'code' => 'ECON',
            'description' => 'Economics'
          },
          'catalogNumber' => {
            'prefix' => 'H',
            'number' => '195',
            'suffix' => 'B',
            'formatted' => 'H195B'
          },
          'displayName' => 'ECON H195B',
          'title' => 'Senior Honors Thesis',
          'transcriptTitle' => 'SR HONORS THESIS'
        },
        'offeringNumber' => 1,
        'session' => {
          'term' => {
            'id' => '2212',
            'name' => '2021 Spring'
          },
          'id' => '1',
          'name' => 'Regular Academic Session'
        },
        'number' => '001',
        'displayName' => '2021 Spring ECON H195B 001',
        'allowedUnits' => {
          'minimum' => 1,
          'maximum' => 3,
          'forAcademicProgress' => 1,
          'forFinancialAid' => 1
        },
        'gradingBasis' => {
          'code' => 'OPT',
          'description' => 'Student Option'
        }
      }
    }
  end
  subject { described_class.new(attributes_hash) }

  describe '#as_json' do
    it 'returns hash representation of section' do
      section_hash = subject.as_json
      expect(section_hash[:ccn]).to eq '15476'
      expect(section_hash[:async]).to eq nil
      expect(section_hash[:cloud]).to eq nil
      expect(section_hash[:timeConflictOverride]).to eq nil
      expect(section_hash[:instructionMode]).to eq 'In-Person Instruction'
      expect(section_hash[:instructionModeCode]).to eq 'P'
    end
  end
end
