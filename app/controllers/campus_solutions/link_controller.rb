module CampusSolutions
  class LinkController < CampusSolutionsController
    include LinkFetcher

    def get
      render json: link_feed(params['urlId'], params['placeholders'])
    end

  end
end
