module HubEdos
  module PersonApi
    module V1
      class Person
        def self.get(user)
          api_response = ::HubEdos::PersonApi::V1::SisPerson.new(user_id: user.uid).get
          if api_response[:statusCode] == 200
            return self.new(api_response[:feed])
          end
          nil
        end

        def initialize(data)
          @data = data
        end

        def identifiers
          ::HubEdos::PersonApi::V1::Identifiers.new(@data['identifiers'])
        end

        def names
          ::HubEdos::PersonApi::V1::Names.new(@data['names'])
        end

        def affiliations
          ::HubEdos::PersonApi::V1::Affiliations.new(@data['affiliations'])
        end

        def emails
          ::HubEdos::Common::Contact::Emails.new(@data['emails'])
        end
      end
    end
  end
end
