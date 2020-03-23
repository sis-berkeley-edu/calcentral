module ENF
  class Message
    include ActiveModel::Model

    attr_accessor :timestamp
    attr_accessor :text

    def student_uid
      @student_uid ||= User::Current.from_campus_solutions_id(student_campus_solutions_id).uid
    end

    def student_campus_solutions_id
      student['StudentId']
    rescue NoMethodError
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
  end
end
