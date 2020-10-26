Calcentral::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => 'bootstrap#index'

  # User management/status endpoints, currently used by all services.
  get '/api/my/am_i_logged_in' => 'user#am_i_logged_in', :as => :am_i_logged_in, :defaults => { :format => 'json' }
  get '/api/my/status' => 'user#my_status', :defaults => { :format => 'json' }
  post '/api/my/record_first_login' => 'user#record_first_login', :as => :record_first_login, :defaults => { :format => 'json' }

  # System utility endpoints
  get '/api/cache/clear' => 'cache#clear', :defaults => { :format => 'json' }
  get '/api/cache/delete' => 'cache#delete', :defaults => { :format => 'json' }
  get '/api/cache/delete/*key' => 'cache#delete', :defaults => { :format => 'json' }
  get '/api/config' => 'config#get', :defaults => { :format => 'json' }
  get '/api/ping' => 'ping#do', :defaults => {:format => 'json'}
  get '/api/server_info' => 'server_runtime#get_info'
  get '/api/smoke_test_routes' => 'routes_list#smoke_test_routes', :as => :all_routes, :defaults => { :format => 'json' }

  # Oauth endpoints: Google
  get '/api/google/request_authorization'=> 'google_auth#request_authorization'
  get '/api/google/handle_callback' => 'google_auth#handle_callback'
  post '/api/google/remove_authorization' => 'google_auth#remove_authorization'
  post '/api/google/dismiss_reminder' => 'google_auth#dismiss_reminder', :defaults => { :format => 'json'}

  # Authentication endpoints
  get '/auth/cas/callback' => 'sessions#lookup'
  get '/auth/failure' => 'sessions#failure'
  if Settings.developer_auth.enabled
    # the backdoor for http basic auth (bypasses CAS) only on development environments.
    get '/basic_auth_login' => 'sessions#basic_lookup'
    get '/logout' => 'sessions#destroy', :as => :logout
    post '/logout' => 'sessions#destroy', :as => :logout_post
  else
    post '/logout' => 'sessions#destroy', :as => :logout
  end

  # Search for users
  get '/api/search_users/:id' => 'search_users#by_id', :defaults => { :format => 'json' }

  # View-as endpoints
  get '/api/view_as/my_stored_users' => 'stored_users#get', :defaults => { :format => 'json' }
  post '/api/view_as/store_user_as_saved' => 'stored_users#store_saved_uid', defaults: { format: 'json' }
  post '/api/view_as/store_user_as_recent' => 'stored_users#store_recent_uid', defaults: { format: 'json' }
  post '/act_as' => 'act_as#start'
  post '/stop_act_as' => 'act_as#stop'
  post '/delete_user/saved' => 'stored_users#delete_saved_uid', defaults: { format: 'json' }
  post '/delete_users/recent' => 'stored_users#delete_all_recent', defaults: { format: 'json' }
  post '/delete_users/saved' => 'stored_users#delete_all_saved', defaults: { format: 'json' }

  get '/api/stats' => 'stats#get_stats', :defaults => { :format => 'json' }

  # Feeds of read-only content
  get '/api/academics/degree_progress/grad' => 'my_degree_progress#get_graduate_milestones', :defaults => { :format => 'json' }
  get '/api/academics/degree_progress/ugrd' => 'my_degree_progress#get_undergraduate_requirements', :defaults => { :format => 'json' }
  get '/api/academics/enrollment_verification' => 'enrollment_verification#get_feed', :defaults => { :format => 'json' }
  get '/api/academics/exam_results' => 'exam_results#get_exam_results', :defaults => { :format => 'json' }
  get '/api/academics/has_exam_results' => 'exam_results#has_exam_results', :defaults => { :format => 'json' }
  get '/api/academics/pnp_calculator/calculator_values' => 'campus_solutions/pnp_calculator#get_calculator_values', :defaults => { :format => 'json' }
  get '/api/academics/pnp_calculator/ratio_message' => 'campus_solutions/pnp_calculator#get_ratio_message', :defaults => { :format => 'json' }
  get '/api/academics/rosters/campus/:campus_course_id' => 'campus_rosters#get_feed', :as => :campus_roster, :defaults => { :format => 'json' }
  get '/api/academics/rosters/campus/csv/:campus_course_id' => 'campus_rosters#get_csv', :as => :campus_roster_csv, :defaults => { :format => 'csv' }
  get '/api/academics/transfer_credits' =>'transfer_credit#get_feed', :defaults => { :format => 'json' }
  get '/api/advising/my_advising' => 'my_advising#get_feed', :as => :advising, :defaults => {:format => 'json'}
  get '/api/media/:term_yr/:term_cd/:dept_name/:catalog_id' => 'mediacasts#get_media', :defaults => { :format => 'json' }
  get '/api/my/academics' => 'my_academics#get_feed', :as => :my_academics, :defaults => { :format => 'json' }
  get '/api/my/academic_records' => 'my_academic_records#get_feed', :defaults => { :format => 'json' }
  get '/api/my/activities' => 'my_activities#get_feed', :as => :my_activities, :defaults => { :format => 'json' }
  get '/api/my/aid_years' => 'my_aid_years#get_feed', :defaults => { :format => 'json' }
  get '/api/my/awards/:aid_year' => 'my_awards#get_feed', :defaults => { :format => 'json' }
  get '/api/my/awards_by_term/:aid_year' => 'my_awards_by_term#get_feed', :defaults => { :format => 'json' }
  get '/api/my/badges' => 'my_badges#get_feed', :as => :my_badges, :defaults => { :format => 'json' }
  get '/api/my/campuslinks' => 'my_campus_links#get_feed', :as => :my_campus_links, :defaults => { :format => 'json' }
  get '/api/my/campuslinks/expire' => 'my_campus_links#expire'
  get '/api/my/campuslinks/refresh' => 'my_campus_links#refresh', :defaults => { :format => 'json' }
  get '/api/my/financial_aid_summary' => 'my_financial_aid_summary#get_feed', :defaults => { :format => 'json' }
  get '/api/my/finaid_profile/:aid_year' => 'my_finaid_profile#get_feed', :defaults => { :format => 'json' }
  get '/api/my/class_enrollments' => 'my_class_enrollments#get_feed', :defaults => { :format => 'json' }
  get '/api/my/classes' => 'my_classes#get_feed', :as => :my_classes, :defaults => { :format => 'json' }

  get '/api/my/committees' => 'my_committees#get_feed', :defaults => { :format => 'json' }
  get '/api/my/committees/photo/member/:member_id' => 'my_committees#member_photo', :defaults => { :format => 'jpeg' }
  get '/api/my/committees/photo/student/:student_id' => 'my_committees#student_photo', :defaults => { :format => 'jpeg' }

  get '/api/my/eft_enrollment' => 'my_eft_enrollment#get_feed', :as => :my_eft_enrollment, :defaults => { :format => 'json' }
  get '/api/my/financials' => 'my_financials#get_feed', :as => :my_financials, :defaults => {:format => 'json'}
  get '/api/my/groups' => 'my_groups#get_feed', :as => :my_groups, :defaults => { :format => 'json' }
  get '/api/my/holds' => 'my_holds#get_feed', :as => :my_holds, :defaults => { :format => 'json' }
  get '/api/my/housing/:aid_year' => 'my_housing#get_feed', :defaults => { :format => 'json' }

  with_options defaults: { format: :json } do
    scope '/api' do
      resources :covid_response, only: :index
    end

    get '/api/my/law_awards' => 'my_law_awards#get_feed'

    scope '/api/my', module: 'user' do
      scope '/tasks', module: 'tasks' do
        resources :agreements, only: [:index]
        resources :checklist_items, only: [:index]
        resources :web_messages, only: [:index]
        resources :b_courses_todos, only: [:index]
        resources :b_courses_messages, only: [:index]
      end

      scope '/academics', module: 'academics' do
        resources :status_and_holds, only: [:index]
        resources :terms, only: [] do
          resources :courses, only: [] do
            resources :sections
          end
        end
        resources :diploma, only: [:index]
      end

      scope '/financial_aid', module: 'financial_aid' do
        resources :award_comparison, only: [:index]
        get 'award_comparison/:aid_year/:effective_date' => 'award_comparison#show'
      end

      scope '/finances', module: 'finances' do
        resources :billing_items, only: [:index, :show]
      end
    end
  end

  get '/api/my/loan_history_aid_years' => 'loan_history#get_aid_years_feed', :defaults => { :format => 'json' }
  get '/api/my/loan_history_cumulative' => 'loan_history#get_cumulative_feed', :defaults => { :format => 'json' }
  get '/api/my/loan_history_inactive' => 'loan_history#get_inactive_feed', :defaults => { :format => 'json' }
  get '/api/my/loan_history_summary' => 'loan_history#get_summary_feed', :defaults => { :format => 'json' }
  get '/api/my/new_admit_resources' =>'new_admit_resources#get_feed', :defaults => { :format => 'json' }
  get '/api/my/photo' => 'photo#my_photo', :as => :my_photo, :defaults => { :format => 'jpeg' }
  get '/api/my/profile' => 'my_profile#get_feed', :defaults => { :format => 'json' }
  get '/api/my/profile/link' => 'my_profile#get_edit_link', :defaults => { :format => 'json' }
  get '/api/my/registrations' => 'my_registrations#get_feed', :defaults => { :format => 'json' }
  get '/api/my/residency' => 'my_academics#residency', :defaults => { :format => 'json' }
  get '/api/my/sir_statuses' => 'sir_statuses#get_feed', :defaults => { :format => 'json' }
  get '/api/my/standings' => 'my_standings#get_feed', :as => :my_standings, :defaults => { :format => 'json' }
  get '/api/my/tasks' => 'my_tasks#get_feed', :as => :my_tasks, :defaults => { :format => 'json' }
  get '/api/my/textbooks_details' => 'my_textbooks#get_feed', :as => :my_textbooks, :defaults => { :format => 'json' }
  get '/api/my/up_next' => 'my_up_next#get_feed', :as => :my_up_next, :defaults => { :format => 'json' }
  get '/api/photo/:uid' => 'photo#photo', :as => :photo, :defaults => {:format => 'jpeg' }
  get '/api/service_alerts' => 'service_alerts#get_feed', :as => :service_alerts, :defaults => { :format => 'json' }
  get '/campus/:campus_course_id/photo/:person_id' => 'campus_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'

  # Google API writing endpoints
  post '/api/my/tasks' => 'my_tasks#update_task', :as => :update_task, :defaults => { :format => 'json' }
  post '/api/my/tasks/create' => 'my_tasks#insert_task', :as => :insert_task, :defaults => { :format => 'json' }
  post '/api/my/tasks/clear_completed' => 'my_tasks#clear_completed_tasks', :as => :clear_completed_tasks, :defaults => { :format => 'json' }
  post '/api/my/tasks/delete/:task_id' => 'my_tasks#delete_task', :as => :delete_task, :defaults => { :format => 'json' }

  # Advisor endpoints
  get '/api/advising/academics/:student_uid' => 'advising_student#academics', :defaults => { :format => 'json' }

  with_options defaults: { format: :json } do
    scope '/api/advising', module: 'advising' do
      scope '/academics', module: 'academics' do
        resources :status_and_holds, only: [:show]
      end
    end
  end

  get '/api/advising/advising/:student_uid' => 'advising_student#advising', :defaults => { :format => 'json' }
  get '/api/advising/cache_expiry/academics/:student_uid' => 'advising_student#academics_cache_expiry', :defaults => { :format => 'json' }
  get '/api/advising/class_enrollments/:student_uid' => 'advising_student#enrollment_instructions', :defaults => { :format => 'json'}
  get '/api/advising/student_committees/:student_uid' => 'advising_student#student_committees', :defaults => { :format => 'json' }
  get '/api/advising/degree_progress/grad/:student_uid' => 'advising_student#degree_progress_graduate', :defaults => { :format => 'json' }
  get '/api/advising/degree_progress/ugrd/:student_uid' => 'advising_student#degree_progress_undergrad', :defaults => { :format => 'json' }
  get '/api/advising/holds/:student_uid' => 'advising_student#holds', :defaults => { :format => 'json' }
  get '/api/advising/standings/:student_uid' => 'advising_student#standings', :defaults => { :format => 'json' }
  get '/api/advising/registrations/:student_uid' => 'advising_student#registrations', :defaults => { :format => 'json' }
  get '/api/advising/resources/:student_uid' => 'advising_student#resources', :defaults => { :format => 'json' }
  get '/api/advising/student/:student_uid' => 'advising_student#profile', :defaults => { :format => 'json' }
  get '/api/advising/student_success/:student_uid' => 'advising_student#student_success', :defaults => { :format => 'json' }
  get '/api/advising/transfer_credit/:student_uid' => 'advising_student#transfer_credit', :defaults => { :format => 'json' }
  get '/api/advising/employment_appointments/:student_uid' =>  'advising_student#employment_appointments', :defaults => { :format => 'json' }
  get '/api/search_users/id_or_name/:input/' => 'search_users#by_id_or_name', :defaults => { :format => 'json' }
  post '/advisor_act_as' => 'advisor_act_as#start'
  post '/stop_advisor_act_as' => 'advisor_act_as#stop'

  # Delegated Access endpoints
  get '/api/campus_solutions/delegate_terms_and_conditions' => 'campus_solutions/delegate_access#get_terms_and_conditions', :defaults => { :format => 'json' }
  get '/api/campus_solutions/delegate_management_url' => 'campus_solutions/delegate_access#get_delegate_management_url', :defaults => { :format => 'json' }
  get '/api/campus_solutions/delegate_access/students' => 'campus_solutions/delegate_access#get_students', :defaults => { :format => 'json' }
  post '/delegate_act_as' => 'delegate_act_as#start'
  post '/stop_delegate_act_as' => 'delegate_act_as#stop'
  post '/api/campus_solutions/delegate_access' => 'campus_solutions/delegate_access#post', :defaults => { :format => 'json' }

  # Campus Solutions general purpose endpoints
  get '/api/campus_solutions/address_label' => 'campus_solutions/address_label#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/advising_resources' => 'campus_solutions/advising_resources#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/billing_activity' => 'campus_solutions/billing#get_activity', :defaults => { :format => 'json' }
  get '/api/campus_solutions/billing_links' => 'campus_solutions/billing#get_links', :defaults => { :format => 'json' }
  get '/api/campus_solutions/confidential_student_message' => 'campus_solutions/confidential_student#get_message', :defaults => { :format => 'json' }
  get '/api/campus_solutions/country' => 'campus_solutions/country#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/currency_code' => 'campus_solutions/currency_code#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/emergency_contacts' => 'campus_solutions/emergency_contacts#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/ethnicity_setup' => 'campus_solutions/ethnicity_setup#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/faculty_resources' => 'campus_solutions/faculty_resources#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_aid_compare_awards_current' => 'campus_solutions/financial_aid_compare_awards_current#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_aid_compare_awards_list' => 'campus_solutions/financial_aid_compare_awards_list#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_aid_compare_awards_prior' => 'campus_solutions/financial_aid_compare_awards_prior#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_aid_data' => 'campus_solutions/financial_aid_data#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_resources/emergency_loan' => 'campus_solutions/financial_resources#get_emergency_loan', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_resources/financial_aid_summary' => 'campus_solutions/financial_resources#get_financial_aid_summary', :defaults => { :format => 'json' }
  get '/api/campus_solutions/financial_resources/summer_estimator' => 'campus_solutions/financial_resources#get_summer_estimator', :defaults => { :format => 'json' }
  get '/api/campus_solutions/fpp_enrollment' => 'campus_solutions/fpp_enrollment#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/higher_one_url' => 'campus_solutions/higher_one_url#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/holds' => 'campus_solutions/holds#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/language_code' => 'campus_solutions/language_code#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/link' => 'campus_solutions/link#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/slr_deeplink' => 'campus_solutions/slr_deeplink#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/state' => 'campus_solutions/state#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/student_resources' => 'campus_solutions/student_resources#get', :defaults => { :format => 'json' }
  get '/api/campus_solutions/translate' => 'campus_solutions/translate#get', :defaults => { :format => 'json' }
  post '/api/campus_solutions/ethnicity' => 'campus_solutions/ethnicity#post', :defaults => { :format => 'json' }
  post '/api/campus_solutions/language' => 'campus_solutions/language#post', :defaults => { :format => 'json' }
  post '/api/campus_solutions/sir_response' => 'campus_solutions/sir_response#post', :defaults => { :format => 'json' }
  post '/api/campus_solutions/work_experience' => 'campus_solutions/work_experience#post', :defaults => { :format => 'json' }
  delete '/api/campus_solutions/ethnicity/:ethnicGroupCode/:regRegion' => 'campus_solutions/ethnicity#delete', :defaults => { :format => 'json' }
  delete '/api/campus_solutions/language/:languageCode' => 'campus_solutions/language#delete', :defaults => { :format => 'json' }
  delete '/api/campus_solutions/work_experience/:sequenceNbr' => 'campus_solutions/work_experience#delete', :defaults => { :format => 'json' }

  # Financial Aid endpoints
  get '/api/financial_aid/financial_resources' => 'financial_resources#get_feed', :defaults => { :format => 'json' }

  # Alumni Profile endpoints 
  get '/api/alumni/alumni_profiles' => 'alumni_profiles#get_feed', :defaults => { :format => 'json' }
  get '/api/alumni/set_skip_landing_page' => 'alumni_profiles#set_skip_landing_page', :defaults => { :format => 'json' }


  # Redirect to College Scheduler
  get '/college_scheduler/student/:acad_career/:term_id' => 'campus_solutions/college_scheduler#get'
  get '/college_scheduler/advisor/:acad_career/:term_id/:student_user_id' => 'campus_solutions/college_scheduler#get_advisor'

  # Redirect to HigherOne
  get '/higher_one/higher_one_url' => 'campus_solutions/higher_one_url#redirect'

  # Redirect to National Student ClearingHouse
  get '/clearing_house/clearing_house_url' => 'my_clearing_house_url#redirect'

  # EDOs from integration hub
  get '/api/edos/work_experience' => 'hub_edo#work_experience', :defaults => { :format => 'json' }

  # All the other paths should use the bootstrap page
  # We need this because we use html5mode=true
  #
  # This should ALWAYS be the last rule on the routes list!
  get '/*url' => 'bootstrap#index', :defaults => { :format => 'html' }
end
