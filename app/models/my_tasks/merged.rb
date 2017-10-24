module MyTasks
  class Merged < UserSpecificModel
    include MyTasks::ParamValidator
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::FilterJsonOutput
    include MergedModel

    def initialize(uid, options={})
      super(uid, options)
      #To avoid issues with tz, use DateTime instead of Date (http://www.elabs.se/blog/36-working-with-time-zones-in-ruby-on-rails)
      @starting_date = Time.zone.today.in_time_zone.to_datetime
      @now_time = Time.zone.now
    end

    def providers
      @providers ||= candidate_providers.select { |k,v| v[:access_granted] == true }
    end

    def candidate_providers
      {
        Canvas::Proxy::APP_NAME => {access_granted: Canvas::Proxy.access_granted?(@uid),
                                source: MyTasks::CanvasTasks.new(@uid, @starting_date)},
        GoogleApps::Proxy::APP_ID => {access_granted: GoogleApps::Proxy.access_granted?(@uid),
                                source: MyTasks::GoogleTasks.new(@uid, @starting_date)},
        CampusSolutions::Proxy::APP_ID => {access_granted: true,
                                source: MyTasks::SisTasks.new(@uid, @starting_date)}
      }
    end

    def provider_class_name(provider)
      provider[1][:source].class.to_s
    end

    def get_feed_internal
      feed = {
        tasks: []
      }
      handling_provider_exceptions(feed, providers) do |provider_key, provider_value|
        feed[:tasks] += provider_value[:source].fetch_tasks
      end
      logger.debug "#{self.class.name} get_feed is #{feed[:tasks].inspect}"
      feed
    end

    def filter_for_view_as(feed)
      feed[:tasks].delete_if {|t| t[:emitter] == 'Google'}
      if authentication_state.authenticated_as_delegate?
        if authentication_state.delegated_privileges[:financial]
          feed[:tasks] = feed[:tasks].select {|t| (t[:emitter] == 'Campus Solutions') && t[:cs][:isFinaid]}
        else
          feed[:tasks] = []
        end
      elsif authentication_state.authenticated_as_advisor?
        feed[:tasks].delete_if {|t| t[:emitter] == 'bCourses'}
      end
      feed
    end

    def update_task(params, task_list_id='@default')
      return {} if providers[params['emitter']].blank?
      validate_update_params params
      source = providers[params['emitter']][:source]
      response = source.update_task(params, task_list_id)
      if response != {}
        expire_cache
      end
      response
    end

    def insert_task(params, task_list_id='@default')
      return {} if providers[params['emitter']].blank?
      source = providers[params['emitter']][:source]
      response = source.insert_task(params, task_list_id)
      if response != {}
        expire_cache
      end
      response
    end

    def clear_completed_tasks(params, task_list_id='@default')
      return {tasksCleared: false} if providers[params['emitter']].blank?
      source = providers[params['emitter']][:source]
      response = source.clear_completed_tasks(task_list_id)
      if response[:tasksCleared] != false
        expire_cache
      end
      response
    end

    def delete_task(params, task_list_id='@default')
      return {task_deleted: false} if providers[params['emitter']].blank?
      source = providers[params['emitter']][:source]
      response = source.delete_task(params, task_list_id)
      if response != {}
        expire_cache
      end
      response
    end

    private

    def includes_whitelist_values?(whitelist_array=[])
      Proc.new { |status_arg| !status_arg.blank? && whitelist_array.include?(status_arg) }
    end

    def validate_update_params(params)
      filters = {
          'type' => Proc.new { |arg| !arg.blank? && arg.is_a?(String) },
          'emitter' => includes_whitelist_values?(providers.keys),
          'status' => includes_whitelist_values?(%w(needsAction completed))
      }
      validate_params(params, filters)
    end

  end
end
