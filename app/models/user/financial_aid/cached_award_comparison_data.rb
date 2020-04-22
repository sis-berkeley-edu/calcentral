module User
  module FinancialAid
    class CachedAwardComparisonData < UserSpecificModel

      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker

      def initialize(uid, aid_year, effective_date)
        @uid = uid
        @aid_year = aid_year
        @effective_date = effective_date
      end

      def instance_key
        "#{@uid}-#{@aid_year}-#{@effective_date}"
      end

      def get_feed_internal
        {
          awards: awards.as_json,
          cost: {
            total: items_with_floats(all_costs).collect { |item| item['value'] }.sum.to_f,
            items: items_with_floats(all_costs)
          },
          profile: {
            items: [
              {
                description: 'Level',
                subvalues: subvaluesLevel
              },
              {
                description: 'Enrollment',
                subvalues: subvaluesEnrollment
              },
              {
                description: 'Residency',
                subvalues: subvaluesResidency
              },
              {
                description: 'Housing',
                subvalues: subvaluesHousing
              },
              {
                description: 'SHIP (Student Housing Insurance Program)',
                subvalues: subvaluesSHIP
              },
              {
                description: 'SAP Status',
                value: snapshot_data[0].try(:[], 'sap_status')
              },
              {
                description: 'Verification Status',
                value: snapshot_data[0].try(:[], 'verification_status')
              },
              {
                description: 'Family Members in College',
                value: isir.try(:[], 'family_in_college')
              },
              {
                description: 'Estimated Graduation',
                value: status.try(:[], 'exp_grad_term')
              },
              {
                description: 'Dependency Status',
                value: isir.try(:[], 'dependency_status')
              },
              {
                description: 'Expected Family Contribution (EFC)',
                value: isir.try(:[], 'primary_efc').partition('$ ')[1].to_f
              },
              {
                description: 'Berkeley Parent Contribution',
                value: snapshot_data[0].try(:[], 'berkeley_pc').to_f
              }
            ]
          }
        }
      end

      def items_with_floats(data)
        items_with_floats ||= data.collect do |item_to_float|
          item_to_float.merge({ 'value' => item_to_float['value'].to_f })
        end
      end

      def awards
        @awards ||= Awards.new({ uid: @uid, aid_year: @aid_year, effective_date: @effective_date })
      end

      # Expected Cost of Attendance
      def all_costs
        @all_costs ||= Queries.get_award_comparison_cost(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      # Profile Data
      def level
        @level ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_acad_level(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def enrollment
        @enrollment ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_enrollment(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def residency
        @residency ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_residency(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def housing
        @housing ||= EdoOracle::FinancialAid::Queries.get_housing(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def ship_status
        @ship_status ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_SHIP(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def isir
        @isir ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_isir(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def status
        @status ||= EdoOracle::FinancialAid::Queries.get_finaid_profile_status(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def snapshot_data
        @snapshot_data ||= Queries.get_award_comparison_snapshot_data(@uid, aid_year: @aid_year, effective_date: @effective_date)
      end

      def subvaluesLevel
        @subvaluesLevel ||= level.map.try(:each) do |item|
          {
            term: item.try(:[], 'term_descr').partition(' ')[0],
            value: acadLevel(item.try(:[], 'acad_level'))
          }
        end
      end

      def acadLevel(value)
        value.sub("/", " / ")
      end

      def subvaluesEnrollment
        @subvaluesEnrollment ||= enrollment.map.try(:each) do |item|
          {
            term: item.try(:[], 'term_descr').partition(' ')[0],
            value: item.try(:[], 'term_units')
          }
        end
      end

      def subvaluesResidency
        @subvaluesResidency ||= residency.map.try(:each) do |item|
          {
            term: item.try(:[], 'term_descr').partition(' ')[0],
            value: item.try(:[], 'residency')
          }
        end
      end

      def subvaluesHousing
        @subvaluesHousing ||= housing.map.try(:each) do |item|
          {
            term: item.try(:[], 'term_descr').partition(' ')[0],
            value: housingOption(item.try(:[], 'housing_option'))
          }
        end
      end

      def housingOption(value)
        value.sub("Housing - ", "").sub("And", "&")
      end


      def subvaluesSHIP
        @subvaluesSHIP ||= ship_status.map.try(:each) do |item|
          {
            term: item.try(:[], 'term_descr').partition(' ')[0],
            value: item.try(:[], 'ship_status')
          }
        end
      end
    end
  end
end
