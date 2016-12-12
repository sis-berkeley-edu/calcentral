module CampusSolutions
  class CollegeSchedulerController < CampusSolutionsController
    include AdvisorAuthorization

    before_filter :check_directly_authenticated
    before_action :authorize_advisor_access, only: [:get_advisor]

    # GET /college_scheduler/student/:acad_career/:term_id
    def get
      handle_redirect college_scheduler_proxy
    end

    # GET /college_scheduler/advisor/:acad_career/:term_id/:student_user_id
    def get_advisor
      handle_redirect college_scheduler_proxy(true)
    end

    private

    def authorize_advisor_access
      require_advisor session['user_id']
    end

    def handle_redirect(proxy)
      if (college_scheduler_url = proxy.get_college_scheduler_url)
        redirect_to college_scheduler_url
      else
        redirect_to url_for_path '/404'
      end
    end

    def college_scheduler_proxy(is_advisor = false)
      proxy_params = is_advisor ? params.permit(:term_id, :acad_career, :student_user_id) : params.permit(:term_id, :acad_career)
      proxy_arguments = {
        user_id: session['user_id'],
        term_id: proxy_params['term_id'],
        acad_career: proxy_params['acad_career'],
      }
      proxy_arguments.merge!({student_user_id: proxy_params['student_user_id']}) if is_advisor
      CampusSolutions::CollegeSchedulerUrl.new(proxy_arguments)
    end
  end
end
