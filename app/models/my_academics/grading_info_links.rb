module MyAcademics
  class GradingInfoLinks
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
      faculty_cat = Links::LinkCategory.where(root_level: false, name: 'Faculty').first
      grading_cat = Links::LinkCategory.where(root_level: false, name: 'Grading').first
      if !(faculty_cat && grading_cat)
        Rails.logger.warn "'Faculty' or 'Grading' link categories are not present. Refresh links by requesting /api/my/campuslinks/refresh"
      else
        link_section = Links::LinkSection.where(link_top_cat_id: faculty_cat.id, link_sub_cat_id: grading_cat.id).first
        if (link_section_links = link_section.links.to_a)
          links[:general] = link_section_links.find {|link| link.name == 'Assistance with Grading: General'}
          links[:midterm] = link_section_links.find {|link| link.name == 'Assistance with Midpoint Grading: General'}
          links[:law] = link_section_links.find {|link| link.name == 'Assistance with Grading: Law'}
        end
      end
      links
    end
  end
end
