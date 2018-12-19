module MyAcademics
  module Grading
    class InfoLinks
      extend Cache::Cacheable

      def self.fetch(options = {})
        smart_fetch_from_cache(force_write: options[:force]) do
          grading_links
        end
      end

      def self.grading_links
        links = {
          general: nil,
          midterm: nil,
          law: nil
        }
        campus_links = Links::MyCampusLinks.new.get_feed
        grading_info_links = campus_links['links'].select do |link|
          link['categories'].index({"topcategory"=>"Faculty", "subcategory"=>"Grading"}).present?
        end
        links[:general] = grading_info_links.find {|link| link.try(:[], 'name') == 'Assistance with Grading: General'}
        links[:midterm] = grading_info_links.find {|link| link.try(:[], 'name') == 'Assistance with Midpoint Grading: General'}
        links[:law] = grading_info_links.find {|link| link.try(:[], 'name') == 'Assistance with Grading: Law'}
        links
      end
    end
  end
end
