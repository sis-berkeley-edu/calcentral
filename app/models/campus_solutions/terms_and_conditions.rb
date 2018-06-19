module CampusSolutions
  class TermsAndConditions < PostingProxy

    include FinaidFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:response, :UC_RESPONSE),
          FieldMapping.required(:aidYear, :AID_YEAR)
        ]
      )
    end

    def valid?(params)
      valid_aid_years = []
      aid_years = CampusSolutions::MyAidYears.new(@uid).get_feed
      aid_years.try(:[], :feed).try(:[], :finaidSummary).try(:[], :finaidYears).try(:each) do |aid_year|
        unless prior_response_recorded? aid_year
          valid_aid_years.push(aid_year.try(:[], :id).try(:to_i))
        end
      end
      valid_aid_years.include?(params[:aidYear].try(:to_i))
    end

    def prior_response_recorded?(aid_year)
      response = aid_year.try(:[], :termsAndConditions).try(:[], :approved)
      response == true || response == false
    end

    def request_root_xml_node
      'Terms_Conditions'
    end

    def response_root_xml_node
      'UC_FA_T_C_RSP'
    end

    def xml_filename
      'terms_and_conditions.xml'
    end

    def default_post_params
      super.merge(
        {
          INSTITUTION: 'UCB01',
          LASTUPDOPRID: '1086132'
        })
    end

    def instance_key
      if @params.present? && @params[:aidYear].present?
        "#{@uid}-#{@params[:aidYear]}"
      else
        @uid
      end
    end

    def url
      "#{@settings.base_url}/UC_FA_T_C.v1/post"
    end

  end
end
