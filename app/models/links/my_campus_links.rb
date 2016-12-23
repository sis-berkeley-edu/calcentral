module Links
  class MyCampusLinks

=begin
  NOTES:

  - Navigation consists of Main Categories, Subcategories, and On-page categories
  - A Section is defined as a unique aggregate of MainCat/SubCat/PageCat
  - A single Categories table serves all three purposes by being referred to thrice in the Sections model
  - A Link can belong to multiple Sections; a Section consists of multiple links
  - Links (or their URLs) are guaranteed unique
  - RailsAdmin is whitelisting only the Models we want to display (in rails_admin.rb)
  - RailsAdmin comes with an optional History feature to track who changed what, but it's disabled here.

=end

    def get_feed
      # Feed consists of two primary sections: Navigation and Links
      navigation = []
      Links::LinkCategory.where('root_level = ?', true).order('LOWER(name)').each do |category|
        navigation.push({
          'label' => category.name,
          'categories' => get_subsections_for_nav(category)
        })
      end
      links = []
      Links::Link.where('published = ?', true).order('LOWER(name)').each do |link|
        links.push({
           'name' => link.name,
           'description' => link.description,
           'url' => link.url,
           'roles' => get_roles_for_link(link),
           'categories' => get_cats_for_link(link)
         })
      end
      {
        'links' => links,
        'navigation' => navigation
      }
    end

    def get_subsections_for_nav(cat)
      # Given a top-level category, get names and slugs of sub-categories for navigation. Find the unique subsections.
      categories = []
      Links::LinkSection.where('link_root_cat_id = ?', cat.id).select(:link_top_cat_id).uniq.each do |subsection|
        categories.push({
          'id' => subsection.link_top_cat.slug,
          'name' => subsection.link_top_cat.name
        })
      end
      categories.sort_by { |category| category['name'] }
    end
    # Given a link, return an array of the categories it lives in by examining its host sections
    def get_cats_for_link(link)
      categories = []
      link.link_sections.each do |section|
        if section.link_top_cat.present? && section.link_sub_cat.present?
          categories.push({
            'topcategory' => section.link_top_cat.name,
            'subcategory' => section.link_sub_cat.name
          })
        end
      end
      categories.sort_by { |category| [category['topcategory'], category['subcategory']] }
    end

    # Given a link, provide the client side with a list of the user roles who would be interested in it.
    def get_roles_for_link(link)
      roles = {
        'student' => false,
        'applicant' => false,
        'staff' => false,
        'faculty' => false,
        'exStudent' => false,
        'summerVisitor' => false
      }
      link.user_roles.each { |link_role| roles[link_role.slug] = true }
      roles
    end

  end
end
