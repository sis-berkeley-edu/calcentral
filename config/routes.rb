Calcentral::Application.routes.draw do

  mount RailsAdmin::Engine => '/ccadmin', :as => 'rails_admin'

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
  get '/api/cache/delete/:key' => 'cache#delete', :defaults => { :format => 'json' }
  get '/api/config' => 'config#get', :defaults => { :format => 'json' }
  get '/api/ping' => 'ping#do', :defaults => {:format => 'json'}
  get '/api/reload_yaml_settings' => 'yaml_settings#reload', :defaults => { :format => 'json' }
  get '/api/server_info' => 'server_runtime#get_info'
  get '/api/smoke_test_routes' => 'routes_list#smoke_test_routes', :as => :all_routes, :defaults => { :format => 'json' }

  # Torquebox utility endpoints, not usable in a vanilla Rails deployment
  if ENV['IS_TORQUEBOX'] || ENV['RAILS_ENV'] == 'test'
    get '/api/torque/stats' => 'torquebox#stats', :defaults => {:format => 'json'}
    get '/api/torque/bg' => 'torquebox#bg', :defaults => {:format => 'json'}
    get '/api/torque/bg_msgs' => 'torquebox#bg_msgs', :defaults => {:format => 'json'}
    get '/api/torque/bg_purge' => 'torquebox#bg_purge', :defaults => {:format => 'json'}
    get '/api/torque/job' => 'torquebox#job', :defaults => {:format => 'json'}
    get '/api/torque/test_no_wait' => 'torquebox#test_no_wait', :defaults => {:format => 'json'}
    get '/api/torque/test_wait' => 'torquebox#test_wait', :defaults => {:format => 'json'}
  end

  # Oauth endpoints: Google
  get '/api/google/request_authorization'=> 'google_auth#refresh_tokens'
  get '/api/google/handle_callback' => 'google_auth#handle_callback'
  get '/api/google/current_scope' => 'google_auth#current_scope'
  post '/api/google/remove_authorization' => 'google_auth#remove_authorization'
  post '/api/google/dismiss_reminder' => 'google_auth#dismiss_reminder', :defaults => { :format => 'json'}

  # Authentication endpoints
  get '/auth/cas/callback' => 'sessions#lookup'
  get '/auth/failure' => 'sessions#failure'
  get '/reauth/admin' => 'sessions#reauth_admin', :as => :reauth_admin
  delete '/logout' => 'sessions#destroy', :as => :logout_ccadmin
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

  if ProvidedServices.calcentral?
    get '/api/stats' => 'stats#get_stats', :defaults => { :format => 'json' }

    # Feeds of read-only content
    get '/api/academics/degree_progress/grad' => 'my_degree_progress#get_graduate_milestones', :defaults => { :format => 'json' }
    get '/api/academics/degree_progress/ugrd' => 'my_degree_progress#get_undergraduate_requirements', :defaults => { :format => 'json' }
    get '/api/academics/enrollment_verification' => 'enrollment_verification#get_feed', :defaults => { :format => 'json' }
    get '/api/academics/rosters/campus/:campus_course_id' => 'campus_rosters#get_feed', :as => :campus_roster, :defaults => { :format => 'json' }
    get '/api/academics/rosters/campus/csv/:campus_course_id' => 'campus_rosters#get_csv', :as => :campus_roster_csv, :defaults => { :format => 'csv' }
    get '/api/academics/transfer_credits' =>'transfer_credit#get_feed', :defaults => { :format => 'json' }
    get '/api/advising/my_advising' => 'my_advising#get_feed', :as => :advising, :defaults => {:format => 'json'}
    get '/api/media/:term_yr/:term_cd/:dept_name/:catalog_id' => 'mediacasts#get_media', :defaults => { :format => 'json' }
    get '/api/my/academics' => 'my_academics#get_feed', :as => :my_academics, :defaults => { :format => 'json' }
    get '/api/my/academic_records' => 'my_academic_records#get_feed', :defaults => { :format => 'json' }
    get '/api/my/activities' => 'my_activities#get_feed', :as => :my_activities, :defaults => { :format => 'json' }
    get '/api/my/badges' => 'my_badges#get_feed', :as => :my_badges, :defaults => { :format => 'json' }
    get '/api/my/campuslinks' => 'my_campus_links#get_feed', :as => :my_campus_links, :defaults => { :format => 'json' }
    get '/api/my/campuslinks/expire' => 'my_campus_links#expire'
    get '/api/my/campuslinks/refresh' => 'my_campus_links#refresh', :defaults => { :format => 'json' }
    get '/api/my/financial_aid_summary' => 'my_financial_aid_summary#get_feed', :defaults => { :format => 'json' }
    get '/api/my/housing/:aid_year' => 'my_housing#get_feed', :defaults => { :format => 'json' }
    get '/api/my/class_enrollments' => 'my_class_enrollments#get_feed', :defaults => { :format => 'json' }
    get '/api/my/classes' => 'my_classes#get_feed', :as => :my_classes, :defaults => { :format => 'json' }
    get '/api/my/committees' => 'my_committees#get_feed', :defaults => { :format => 'json' }
    get '/api/my/committees/photo/member/:member_id' => 'my_committees#member_photo', :defaults => { :format => 'jpeg' }
    get '/api/my/committees/photo/student/:student_id' => 'my_committees#student_photo', :defaults => { :format => 'jpeg' }
    get '/api/my/eft_enrollment' => 'my_eft_enrollment#get_feed', :as => :my_eft_enrollment, :defaults => { :format => 'json' }
    get '/api/my/financials' => 'my_financials#get_feed', :as => :my_financials, :defaults => {:format => 'json'}
    get '/api/my/groups' => 'my_groups#get_feed', :as => :my_groups, :defaults => { :format => 'json' }
    get '/api/my/holds' => 'my_holds#get_feed', :as => :my_holds, :defaults => { :format => 'json' }
    get '/api/my/loan_history_aid_years' => 'loan_history#get_aid_years_feed', :defaults => { :format => 'json' }
    get '/api/my/loan_history_cumulative' => 'loan_history#get_cumulative_feed', :defaults => { :format => 'json' }
    get '/api/my/loan_history_inactive' => 'loan_history#get_inactive_feed', :defaults => { :format => 'json' }
    get '/api/my/loan_history_summary' => 'loan_history#get_summary_feed', :defaults => { :format => 'json' }
    get '/api/my/new_admit_resources' =>'new_admit_resources#get_feed', :defaults => { :format => 'json' }
    get '/api/my/photo' => 'photo#my_photo', :as => :my_photo, :defaults => {:format => 'jpeg' }
    get '/api/my/profile' => 'my_profile#get_feed', :defaults => { :format => 'json' }
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
    post '/api/my/event' => 'my_events#create', defaults: { format: 'json' }
    post '/api/my/tasks' => 'my_tasks#update_task', :as => :update_task, :defaults => { :format => 'json' }
    post '/api/my/tasks/create' => 'my_tasks#insert_task', :as => :insert_task, :defaults => { :format => 'json' }
    post '/api/my/tasks/clear_completed' => 'my_tasks#clear_completed_tasks', :as => :clear_completed_tasks, :defaults => { :format => 'json' }
    post '/api/my/tasks/delete/:task_id' => 'my_tasks#delete_task', :as => :delete_task, :defaults => { :format => 'json' }

    # Advisor endpoints
    get '/api/advising/academics/:student_uid' => 'advising_student#academics', :defaults => { :format => 'json' }
    get '/api/advising/academic_status/:student_uid' => 'advising_student#academic_status', :defaults => { :format => 'json' }
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
    get '/api/search_users/id_or_name/:input' => 'search_users#by_id_or_name', :defaults => { :format => 'json' }
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
    get '/api/campus_solutions/aid_years' => 'campus_solutions/aid_years#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/billing' => 'campus_solutions/billing#get', :defaults => { :format => 'json' }
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
    get '/api/campus_solutions/financial_aid_funding_sources' => 'campus_solutions/financial_aid_funding_sources#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/financial_aid_funding_sources_term' => 'campus_solutions/financial_aid_funding_sources_term#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/financial_resources/emergency_loan' => 'campus_solutions/financial_resources#get_emergency_loan', :defaults => { :format => 'json' }
    get '/api/campus_solutions/financial_resources/summer_estimator' => 'campus_solutions/financial_resources#get_summer_estimator', :defaults => { :format => 'json' }
    get '/api/campus_solutions/fpp_enrollment' => 'campus_solutions/fpp_enrollment#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/higher_one_url' => 'campus_solutions/higher_one_url#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/holds' => 'campus_solutions/holds#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/language_code' => 'campus_solutions/language_code#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/link' => 'campus_solutions/link#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/name_type' => 'campus_solutions/name_type#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/slr_deeplink' => 'campus_solutions/slr_deeplink#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/state' => 'campus_solutions/state#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/student_resources' => 'campus_solutions/student_resources#get', :defaults => { :format => 'json' }
    get '/api/campus_solutions/translate' => 'campus_solutions/translate#get', :defaults => { :format => 'json' }
    post '/api/campus_solutions/emergency_contact' => 'campus_solutions/emergency_contact#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/emergency_phone' => 'campus_solutions/emergency_phone#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/ethnicity' => 'campus_solutions/ethnicity#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/language' => 'campus_solutions/language#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/person_name' => 'campus_solutions/person_name#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/sir_response' => 'campus_solutions/sir_response#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/terms_and_conditions' => 'campus_solutions/terms_and_conditions#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/title4' => 'campus_solutions/title4#post', :defaults => { :format => 'json' }
    post '/api/campus_solutions/work_experience' => 'campus_solutions/work_experience#post', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/emergency_contact/:contactName' => 'campus_solutions/emergency_contact#delete', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/emergency_phone/:contactName/:phoneType' => 'campus_solutions/emergency_phone#delete', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/ethnicity/:ethnicGroupCode/:regRegion' => 'campus_solutions/ethnicity#delete', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/language/:languageCode' => 'campus_solutions/language#delete', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/person_name/:type' => 'campus_solutions/person_name#delete', :defaults => { :format => 'json' }
    delete '/api/campus_solutions/work_experience/:sequenceNbr' => 'campus_solutions/work_experience#delete', :defaults => { :format => 'json' }

    # Redirect to College Scheduler
    get '/college_scheduler/student/:acad_career/:term_id' => 'campus_solutions/college_scheduler#get'
    get '/college_scheduler/advisor/:acad_career/:term_id/:student_user_id' => 'campus_solutions/college_scheduler#get_advisor'

    # Redirect to HigherOne
    get '/higher_one/higher_one_url' => 'campus_solutions/higher_one_url#redirect'

    # Redirect to National Student ClearingHouse
    get '/clearing_house/clearing_house_url' => 'my_clearing_house_url#redirect'

    # EDOs from integration hub
    get '/api/edos/academic_status' => 'hub_edo#academic_status', :defaults => { :format => 'json' }
    get '/api/edos/work_experience' => 'hub_edo#work_experience', :defaults => { :format => 'json' }
  end

  if ProvidedServices.bcourses?
    # Canvas embedded application support.
    post '/canvas/embedded/*url' => 'canvas_lti#embedded', :defaults => { :format => 'html' }
    get '/canvas/lti_roster_photos' => 'canvas_lti#lti_roster_photos', :defaults => { :format => 'xml' }
    get '/canvas/lti_site_creation' => 'canvas_lti#lti_site_creation', :defaults => { :format => 'xml' }
    get '/canvas/lti_site_mailing_list' => 'canvas_lti#lti_site_mailing_list', :defaults => { :format => 'xml' }
    get '/canvas/lti_site_mailing_lists' => 'canvas_lti#lti_site_mailing_lists', :defaults => { :format => 'xml' }
    get '/canvas/lti_user_provision' => 'canvas_lti#lti_user_provision', :defaults => { :format => 'xml' }
    get '/canvas/lti_course_add_user' => 'canvas_lti#lti_course_add_user', :defaults => { :format => 'xml' }
    get '/canvas/lti_course_mediacasts' => 'canvas_lti#lti_course_mediacasts', :defaults => { :format => 'xml' }
    get '/canvas/lti_course_grade_export' => 'canvas_lti#lti_course_grade_export', :defaults => { :format => 'xml' }
    get '/canvas/lti_course_manage_official_sections' => 'canvas_lti#lti_course_manage_official_sections', :defaults => { :format => 'xml' }
    # A Canvas course ID of "embedded" means to retrieve from session properties.
    get '/api/academics/canvas/course_user_roles/:canvas_course_id' => 'canvas_course_add_user#course_user_roles', :defaults => { :format => 'json' }
    get '/api/academics/canvas/external_tools' => 'canvas#external_tools', :defaults => { :format => 'json' }
    get '/api/academics/canvas/user_can_create_site' => 'canvas#user_can_create_site', :defaults => { :format => 'json' }
    get '/api/academics/canvas/egrade_export/download/:canvas_course_id' => 'canvas_course_grade_export#download_egrades_csv', :defaults => { :format => 'csv' }
    get '/api/academics/canvas/egrade_export/options/:canvas_course_id' => 'canvas_course_grade_export#export_options', :defaults => { :format => 'json' }
    get '/api/academics/canvas/egrade_export/is_official_course' => 'canvas_course_grade_export#is_official_course', :defaults => { :format => 'json' }
    get '/api/academics/canvas/egrade_export/status/:canvas_course_id' => 'canvas_course_grade_export#job_status', :defaults => { :format => 'json' }
    post '/api/academics/canvas/egrade_export/prepare/:canvas_course_id' => 'canvas_course_grade_export#prepare_grades_cache', :defaults => { :format => 'json' }
    post '/api/academics/canvas/egrade_export/resolve/:canvas_course_id' => 'canvas_course_grade_export#resolve_issues', :defaults => { :format => 'json' }
    get '/api/academics/rosters/canvas/:canvas_course_id' => 'canvas_rosters#get_feed', :as => :canvas_roster, :defaults => { :format => 'json' }
    get '/api/academics/rosters/canvas/csv/:canvas_course_id' => 'canvas_rosters#get_csv', :as => :canvas_roster_csv, :defaults => { :format => 'csv' }
    get '/canvas/:canvas_course_id/photo/:person_id' => 'canvas_rosters#photo', :defaults => { :format => 'jpeg' }, :action => 'show'
    get '/canvas/:canvas_course_id/profile/:person_id' => 'canvas_rosters#profile'
    get '/api/academics/canvas/course_provision' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision, :defaults => { :format => 'json' }
    get '/api/academics/canvas/course_provision_as/:admin_acting_as' => 'canvas_course_provision#get_feed', :as => :canvas_course_provision_as, :defaults => { :format => 'json' }
    post '/api/academics/canvas/course_provision/create' => 'canvas_course_provision#create_course_site', :as => :canvas_course_create, :defaults => { :format => 'json' }
    get '/api/academics/canvas/course_provision/sections_feed/:canvas_course_id' => 'canvas_course_provision#get_sections_feed', :as => :canvas_course_sections_feed, :defaults => { :format => 'json' }
    post '/api/academics/canvas/course_provision/edit_sections/:canvas_course_id' => 'canvas_course_provision#edit_sections', :as => :canvas_course_edit_sections, :defaults => { :format => 'json' }
    get '/api/academics/canvas/course_provision/status' => 'canvas_course_provision#job_status', :as => :canvas_course_job_status, :defaults => { :format => 'json' }
    post '/api/academics/canvas/project_provision/create' => 'canvas_project_provision#create_project_site', :as => :canvas_project_create, :defaults => { :format => 'json' }
    post '/api/academics/canvas/user_provision/user_import' => 'canvas_user_provision#user_import', :as => :canvas_user_provision_import, :defaults => { :format => 'json' }
    get '/api/academics/canvas/site_creation/authorizations' => 'canvas_site_creation#authorizations', :as => :canvas_site_creation_authorizations, :defaults => { :format => 'json' }
    get '/api/academics/canvas/course_add_user/:canvas_course_id/search_users' => 'canvas_course_add_user#search_users', :as => :canvas_course_add_user_search_users, :defaults => { :format => 'json' }
    get '/api/academics/canvas/course_add_user/:canvas_course_id/course_sections' => 'canvas_course_add_user#course_sections', :as => :canvas_course_add_user_course_sections, :defaults => { :format => 'json' }
    post '/api/academics/canvas/course_add_user/:canvas_course_id/add_user' => 'canvas_course_add_user#add_user', :as => :canvas_course_add_user_add_user, :defaults => { :format => 'json' }
    get '/api/canvas/media/:canvas_course_id' => 'canvas_webcast_recordings#get_media', :defaults => { :format => 'json' }
    # Administer Canvas mailing list for a single course site
    get '/api/academics/canvas/mailing_list/:canvas_course_id' => 'canvas_mailing_list#show', :defaults => { :format => 'json' }
    post '/api/academics/canvas/mailing_list/:canvas_course_id/create' => 'canvas_mailing_list#create', :defaults => { :format => 'json' }
    # Administer Canvas mailing lists for any course site
    get '/api/academics/canvas/mailing_lists/:canvas_course_id' => 'canvas_mailing_lists#show', :defaults => { :format => 'json' }
    post '/api/academics/canvas/mailing_lists/:canvas_course_id/create' => 'canvas_mailing_lists#create', :defaults => { :format => 'json' }
    post '/api/academics/canvas/mailing_lists/:canvas_course_id/populate' => 'canvas_mailing_lists#populate', :defaults => { :format => 'json' }
    post '/api/academics/canvas/mailing_lists/:canvas_course_id/delete' => 'canvas_mailing_lists#destroy', :defaults => { :format => 'json' }
    # Incoming email messages
    post '/api/mailing_lists/message' => 'mailing_lists_message#relay', :defaults => { :format => 'json' }
  end

  if ProvidedServices.oec?
    # OEC endpoints
    get '/api/oec/google/request_authorization'=> 'oec_google_auth#refresh_tokens', :defaults => { :format => 'json' }
    get '/api/oec/google/handle_callback' => 'oec_google_auth#handle_callback', :defaults => { :format => 'json' }
    get '/api/oec/google/current_scope' => 'oec_google_auth#current_scope', :defaults => { :format => 'json' }
    get '/api/oec/google/remove_authorization' => 'oec_google_auth#remove_authorization'
    get '/api/oec/tasks' => 'oec_tasks#index', :defaults => { :format => 'json' }
    post '/api/oec/tasks/:task_name' => 'oec_tasks#run', :defaults => { :format => 'json' }
    get '/api/oec/tasks/status/:task_id' => 'oec_tasks#task_status',  :defaults => { :format => 'json' }
  end

  # All the other paths should use the bootstrap page
  # We need this because we use html5mode=true
  #
  # This should ALWAYS be the last rule on the routes list!
  get '/*url' => 'bootstrap#index', :defaults => { :format => 'html' }
end
