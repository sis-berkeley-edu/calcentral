module User
  module Academics
    class EnrollmentPeriod
      include BerkeleyTime

      attr_accessor :id
      attr_accessor :acadCareer
      attr_accessor :enddatetime
      attr_accessor :name
      attr_accessor :date

      alias :career :acadCareer

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def as_json(options={})
        {
          id: id,
          acadCareer: acadCareer,
          enddatetime: zoned(enddatetime),
          name: name,
          date: date
        }
      end
    end
  end
end
