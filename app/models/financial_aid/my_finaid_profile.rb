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
          categories: categories
        }
      }
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || FinancialAid::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end

    def status
      @status ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_status(@uid, my_aid_year)
    end

    def level
      @level ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_acad_level(@uid, my_aid_year)
    end

    def enrollment
      @enrollment ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_enrollment(@uid, my_aid_year)
    end

    def residency
      @residency ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_residency(@uid, my_aid_year)
    end

    def isir
      @isir ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_isir(@uid, my_aid_year)
    end

    def title4
      @title4 ||= EdoOracle::FinancialAid::Queries.get_title4(@uid)
    end

    def terms_and_conditions
      @terms_and_conditions ||= EdoOracle::FinancialAid::Queries.get_terms_and_conditions(@uid, my_aid_year)
    end

    def success?
      (status || level || enrollment || residency || isir) && (title4 && terms_and_conditions)
    end

    def subvaluesLevel
      @subvaluesLevel ||= level.map do |item|
         {
          subvalue: [
            item['term_descr'],
            item['acad_level']
          ]
        }
      end
    end

    def subvaluesResidency
      @subvaluesResidency ||= residency.map do |item|
         {
          subvalue: [
            item['term_descr'],
            item['residency']
          ]
        }
      end
    end

    def subvaluesEnrollment
      @subvaluesEnrollment ||= enrollment.map do |item|
         {
          subvalue: [
            item['term_descr'],
            item['term_units']
          ]
        }
      end
    end

    def subvaluesSHIP
      @subvaluesSHIP ||= enrollment.map do |item|
         {
          subvalue: [
            item['term_descr'],
            item['ship_status']
          ]
        }
      end
    end

    def itemGroupsProfile
      @itemGroupsProfile ||= [
        [
          {
            title: 'Academic Career',
            value: status['acad_career_descr']
          },{
            title: 'Level',
            values: subvaluesLevel
          },{
            title: 'Expected Graduation',
            value: status['exp_grad_term']
          }
        ],
        [
          {
            title: 'Candidacy',
            value: status['candidacy']
          },{
            title: 'Filing Fee Status',
            value: status['filing_fee']
          }
        ],
        [
          {
            title: 'Academic Holds',
            value: status['acad_holds']
          }
        ],
        [
          {
            title: 'SAP Status',
            value: status['sap_status']
          },
          {
            title: 'Award Status',
            value: status['award_status']
          },
          {
            title: 'Verification Status',
            value: status['verification_status']
          }
        ],
        [
          {
            title: 'Dependency Status',
            value: isir['dependency_status']
          },
          {
            title: 'Expected Family Contribution (EFC)',
            value: isir['primary_efc']
          },
          {
            title: 'Summer EFC',
            value: isir['summer_efc']
          },
          {
            title: 'Berkeley Parent Contribution',
            value: status['berkeley_pc']
          },
          {
            title: 'Family Members in College',
            value: isir['family_in_college']
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

    def itemGroupsAgreements
      @itemGroupsAgreements ||= [
        [
          {
            title: 'Title IV',
            value: title4['response_descr']
          },{
            title: 'Terms & Conditions',
            value: terms_and_conditions['response_descr']
          }
        ]
      ]
    end

    def categories
      @categories ||= [
        {
          title: status['title'],
          itemGroups: itemGroupsProfile
        },{
          title: 'Agreements',
          itemGroups: itemGroupsAgreements
        }
      ]
    end
  end
end
