module MyTasks
  class SisTasks
    include MyTasks::TasksModule, ClassLogger, HtmlSanitizer, SafeJsonParser

    def initialize(uid, starting_date)
      @uid = uid
      @starting_date = starting_date
      @now_time = Time.zone.now
    end

    def fetch_tasks
      tasks = []
      checklist_feed = CampusSolutions::MyChecklist.new(@uid).get_feed
      checklist_results = collect_results(checklist_feed) { |result| format_checklist result }
      tasks.concat checklist_results.compact if checklist_results
      tasks
    end

    private

    def collect_results(response)
      collected_results = []
      if (response && response[:feed] && results = response[:feed][:checkListItems])
        logger.debug "Sorting SIS Checklist feed into buckets with starting_date #{@starting_date}; #{results}"
        results.each do |result|
          if (formatted_entry = yield result)
            logger.debug "Adding Checklist task with dueDate: #{formatted_entry[:dueDate]} in bucket '#{formatted_entry[:bucket]}': #{formatted_entry}"
            collected_results << formatted_entry
          end
        end
      end
      collected_results
    end

    def format_status_date(result)
      if result[:statusDt]
        status_date = strptime_in_time_zone(result[:statusDt], "%Y-%m-%d")
      else
        # Campus Solutions has a setting where they don't send over any date (due / status)
        # in that case, set it to today since the front-end needs it for sorting
        status_date = DateTime.now.midnight
      end
      status_date
    end

    def entry_from_result(result)
      status = 'inprogress'
      if %w(C P W X).include?(result[:itemStatusCode])
        status = 'completed'
      end
      formatted_entry = {
        emitter: CampusSolutions::Proxy::APP_NAME,
        linkDescription: result[:checkListDocMgmt][:linkUrlLbl],
        linkUrl: result[:checkListDocMgmt][:linkUrl],
        uploadUrl: result[:checkListDocMgmt][:docUploadLink],
        sourceUrl: 'http://sis-project.berkeley.edu',
        status: status,
        title: result[:checkListDescr],
        notes: result[:itemComment],
        type: 'task',
        subTitle: result[:responsibleCntctName],
        cs: {
          responsibleContactEmail: result[:responsibleCntctEmail],
          organization: result[:associationIdName],
          showStatus: result[:itemStatusCode] != 'C' ? result[:itemStatus] : '',
          itemStatusCode: result[:itemStatusCode],
          displayStatus: display_status(result[:itemStatusCode]),
          displayCategory: display_category(result[:adminFunc], result[:chklstItemCd])
        }
      }
      if result[:checkListMgmtFina] && (FinancialAid::Shared::ADMIN_FUNCTION.include? result[:adminFunc])
        formatted_entry[:cs].merge!({
          isFinaid: true,
          finaidYearId: result[:checkListMgmtFina][:aidYear]
        })
      end
      if status == 'completed'
        completedDate = format_date(format_status_date(result))
        formatted_entry[:completedDate] = completedDate
        formatted_entry[:completedDate][:hasTime] = false # CS dates never have times
      end
      formatted_entry
    end

    def format_date_and_bucket(formatted_entry, date)
      # Tasks are not overdue until the end of the day. Advance forward one day and back one second to cover
      # the possibility of daylight savings transitions.
      if date
        date = Time.at((date + 1).in_time_zone.to_datetime.to_i - 1).to_datetime
        format_date_into_entry!(date, formatted_entry, :dueDate, true)
      end
      formatted_entry[:bucket] = determine_bucket(date, formatted_entry, @now_time, @starting_date)
    end

    def format_checklist(result)
      unless result.is_a?(Hash) && result[:checkListDescr].present?
        return nil
      end
      if result[:checkListMgmtFina] && result[:checkListMgmtFina][:displayInCalcentral] == false
        return nil
      end
      formatted_entry = entry_from_result result
      due_date = convert_datetime_or_date result[:dueDt]
      format_date_and_bucket(formatted_entry, due_date)
      if due_date
        formatted_entry[:dueDate][:hasTime] = due_date.is_a?(DateTime)
      end
      if formatted_entry[:bucket] == 'Unscheduled'
        updated_date = format_status_date(result)
        format_date_into_entry!(updated_date, formatted_entry, :updatedDate)
      end
      formatted_entry
    end

    # Maps status code to display status for task
    def display_status(item_status_code)
      case item_status_code
        when 'I' # Initiated (Assigned)
          'incomplete'
        when 'A', 'R' # Active (Processing) / Received
          'beingProcessed'
        when 'C', 'W' # Completed / Waived
          'completed'
        when 'Z' # Incomplete
          'furtherActionNeeded'
        else
          'incomplete'
      end
    end

    # Maps admin function code and checklist item code to the category
    # in which the task should be displayed
    def display_category(admin_func_code, checklist_item_code)
      return 'residency' if checklist_item_code[0,2] == 'RR'
      case admin_func_code
        when 'ADMA' # Admissions Application
          'newStudent'
        when 'ADMP' # Admissions Program
          'admission'
        when 'FINA' # Financial Aid
          'finaid'
        else
          # General (GEN), Student Program (SPRG), Student Term (STRM), etc
          'student'
      end
    end
  end
end
