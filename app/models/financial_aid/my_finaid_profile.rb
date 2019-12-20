module FinancialAid
  class MyFinaidProfile < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinaidFeatureFlagged

    attr_accessor :aid_year

    def get_feed_internal
      is_feature_enabled ? finaid_profile : {}
    end

    def instance_key
      "#{@uid}-#{my_aid_year}"
    end

    private

    def finaid_profile
      return nil unless success?

      {
        finaidProfile: {
          aidYear: my_aid_year,
          message: status['message'],
          itemGroups: itemGroupsProfile
        }
      }
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || FinancialAid::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end

    def status
      @status ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_status(@uid, my_aid_year, effective_date: today)
    end

    def careers
      @careers ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_acad_careers(@uid, my_aid_year, effective_date: today)
    end

    def level
      @level ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_acad_level(@uid, my_aid_year, effective_date: today)
    end

    def enrollment
      @enrollment ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_enrollment(@uid, my_aid_year, effective_date: today)
    end

    def ship_status
      @ship_status ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_SHIP(@uid, my_aid_year, effective_date: today)
    end

    def residency
      @residency ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_residency(@uid, my_aid_year, effective_date: today)
    end

    def isir
      @isir ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_isir(@uid, my_aid_year, effective_date: today)
    end

    def title4
      @title4 ||= EdoOracle::FinancialAid::Queries.get_title4(@uid)
    end

    def terms_and_conditions
      @terms_and_conditions ||= EdoOracle::FinancialAid::Queries.get_terms_and_conditions(@uid, my_aid_year)
    end

    def success?
      my_aid_year.present? && status.present? ? true : false
    end

    def subvaluesCareer
      @subvaluesCareer ||= careers.map.try(:each) do |item|
        {
          subvalue: [
            item.try(:[], 'term_descr'),
            item.try(:[], 'acad_career')
          ]
        }
      end
    end

    def subvaluesLevel
      @subvaluesLevel ||= level.map.try(:each) do |item|
        {
          subvalue: [
            item.try(:[], 'term_descr'),
            item.try(:[], 'acad_level')
          ]
        }
      end
    end

    def subvaluesResidency
      @subvaluesResidency ||= residency.map.try(:each) do |item|
        {
          subvalue: [
            item.try(:[], 'term_descr'),
            item.try(:[], 'residency')
          ]
        }
      end
    end

    def subvaluesEnrollment
      @subvaluesEnrollment ||= enrollment.map.try(:each) do |item|
        {
          subvalue: [
            item.try(:[], 'term_descr'),
            item.try(:[], 'term_units')
          ]
        }
      end
    end

    def subvaluesSHIP
      @subvaluesSHIP ||= ship_status.map.try(:each) do |item|
        {
          subvalue: [
            item.try(:[], 'term_descr'),
            item.try(:[], 'ship_status')
          ]
        }
      end
    end

    def itemGroupsProfile
      @itemGroupsProfile ||= [
        [
          subvaluesCareer.present? ?
          ({
            title: 'Academic Career',
            values:subvaluesCareer
          })
          :
          ({
            title: 'Academic Career',
            value: status.try(:[], 'acad_career_descr')
          })
        ],
        [
          {
            title: 'Level',
            values: subvaluesLevel
          },
          {
            title: 'Expected Graduation',
            value: status.try(:[], 'exp_grad_term')
          }
        ],
        [
          {
            title: 'Candidacy',
            value: status.try(:[], 'candidacy')
          },
          {
            title: 'Filing Fee Status',
            value: status.try(:[], 'filing_fee')
          }
        ],
        [
          {
            title: 'SAP Status',
            value: status.try(:[], 'sap_status')
          },
          {
            title: 'Award Status',
            value: status.try(:[], 'award_status')
          },
          {
            title: 'Verification Status',
            value: status.try(:[], 'verification_status')
          }
        ],
        [
          {
            title: 'Dependency Status',
            value: isir.try(:[], 'dependency_status')
          },
          {
            title: 'Expected Family Contribution (EFC)',
            value: isir.try(:[], 'primary_efc')
          },
          {
            title: 'Berkeley Parent Contribution',
            value: status.try(:[], 'berkeley_pc')
          },
          {
            title: 'Summer EFC',
            value: isir.try(:[], 'summer_efc')
          },
          {
            title: 'Family Members in College',
            value: isir.try(:[], 'family_in_college')
          }
        ],
        [
          {
            title: 'Residency',
            values: subvaluesResidency
          }
        ],
        [
          {
            title: 'Enrollment',
            values: subvaluesEnrollment
          }
        ],
        [
          {
            title: 'SHIP (Student Health Insurance Program)',
            values: subvaluesSHIP
          }
        ]
      ]
    end

    def today
      @today ||= Time.zone.today.in_time_zone.to_date
    end
  end
end
