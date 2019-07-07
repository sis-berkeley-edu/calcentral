module CampusSolutions
  class LinkController < CampusSolutionsController
    include LinkFetcher
    include AllowDelegateViewAs

    def get
      render json: link_feed(params['urlId'], params['placeholders'])
    end

  end
end
