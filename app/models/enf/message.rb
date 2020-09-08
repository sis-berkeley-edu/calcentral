module ENF
  class Message
    include ActiveModel::Model

    attr_accessor :timestamp
    attr_accessor :text

    def student_uids
      student_ids.collect do |id|
        User::Current.from_campus_solutions_id(id).uid
      end
    end

    def topic
      event['topic']
    rescue NoMethodError
    end

    private

    def event
      parsed['eventNotification']['event']
    rescue NoMethodError
    end

    def parsed
      JSON.parse text
    end

    def payload
      event['payload']
    rescue NoMethodError
    end

    def student
      payload['student']
    rescue NoMethodError
    end

    def students
      payload['students']
    rescue NoMethodError
    end

    def student_ids
      if students
        Array(students['id'])
      elsif student
        Array(student['StudentId'])
      end
    end
  end
end
