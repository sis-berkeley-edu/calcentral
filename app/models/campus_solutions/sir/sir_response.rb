module CampusSolutions
  module Sir
    class SirResponse < PostingProxy

      include CampusSolutions::CampusSolutionsIdRequired

      def initialize(options = {})
        super(Settings.campus_solutions_proxy, options)
      end

      def self.field_mappings
        @field_mappings ||= FieldMapping.to_hash(
          [
            FieldMapping.required(:acadCareer, :ACAD_CAREER),
            FieldMapping.required(:studentCarNbr, :STDNT_CAR_NBR),
            FieldMapping.required(:admApplNbr, :ADM_APPL_NBR),
            FieldMapping.required(:applProgNbr, :APPL_PROG_NBR),
            FieldMapping.required(:chklstItemCd, :CHKLST_ITEM_CD),
            FieldMapping.required(:actionReason, :ACTION_REASON),
            FieldMapping.required(:progAction, :PROG_ACTION),
            FieldMapping.required(:responseReason, :RESPONSE_REASON),
            FieldMapping.required(:responseDescription, :RESPONSE_DESCR)
          ]
        )
      end

      def valid?(params)
        valid_statuses = []
        sir_statuses_feed = CampusSolutions::Sir::SirStatuses.new(@uid).get_feed
        sir_statuses_feed.try(:[], :sirStatuses).try(:each) do |status|
          if status.try(:[], :itemStatusCode) != 'C'
            valid_status = {
              chklstItemCd: status.try(:[], :chklstItemCd),
              admApplNbr: status.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr)
            }
            valid_statuses.push(valid_status)
          end
        end
        posting_status = {
          chklstItemCd: params.try(:[], 'chklstItemCd'),
          admApplNbr: params.try(:[], 'admApplNbr')
        }
        valid_statuses.include?(posting_status)
      end

      def request_root_xml_node
        'UC_AD_SIR'
      end

      def xml_filename
        'sir_response.xml'
      end

      def url
        "#{@settings.base_url}/UC_AD_SIR.v1/sir/post/"
      end

    end
  end
end
