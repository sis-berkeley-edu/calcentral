module CampusSolutions
  class FacultyResources < Proxy

    include LinkFetcher

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def get
      cs_links = {}

      campus_solutions_link_settings = [
        { feed_key: :acad_accomodations_hub_faculty, cs_link_key: 'UC_CC_ACCOMM_HUB_FACULTY'},
        { feed_key: :eforms_review_center, cs_link_key: 'UC_CX_GT_ACTION_CENTER' },
        { feed_key: :work_center, cs_link_key: 'UC_CX_GT_WORK_CENTER'},
        { feed_key: :scarab_login, cs_link_key: 'UC_CX_DSP_FACULTY_LOGIN' }
      ]

      campus_solutions_link_settings.each do |setting|
        link = fetch_link(setting[:cs_link_key])
        cs_links[setting[:feed_key]] = link unless link.blank?
      end

      {
        statusCode: 200,
        feed: {
          resources: HashConverter.camelize(cs_links)
        }
      }
    end

    def xml_filename
      'file_is_not_used_in_test.xml'
    end
  end
end
