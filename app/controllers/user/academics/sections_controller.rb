module User
  module Academics
    class SectionsController < ApplicationController
      def index
        if params[:ids]
          ids = params[:ids].split(',')
          sections = ::HubEdos::ClassesApi::V1::Sections.new(params[:term_id], params[:course_id]).matching_section_ids(ids)
          render :json => sections
        else
          sections = ::HubEdos::ClassesApi::V1::Sections.new(params[:term_id], params[:course_id])
          render :json => sections
        end
      end
    end
  end
end
