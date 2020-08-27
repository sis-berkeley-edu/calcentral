module HubEdos
  module PersonApi
    module V1
      class Name
        def initialize(data)
          @data = data || {}
        end

        # a short descriptor representing the kind of name, such as official or preferred, etc.
        def type
          HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
        end

        # that part of the name passed down from parents (in Western contexts often called surname or last name)
        def family_name
          @data['familyName']
        end

        # that part of the name given specifically to the person (in Western contexts aka first name)
        def given_name
          @data['givenName']
        end

        # all of the name elements combined in the correct order, with proper capitalization and punctuation
        def formatted_name
          @data['formattedName']
        end

        # an indicator of whether this name should be the main one used
        def preferred
          @data['preferred']
        end

        # an indicator of whether this name should be disclosed to the public
        def disclose
          @data['disclose']
        end

        # the date this name became effective
        def from_date
          Date.parse(@data['fromDate']) if @data['fromDate']
        end

        # a short descriptor indicating limits on displaying or editing this name
        def ui_control
          HubEdos::Common::Reference::Descriptor.new(@data['uiControl']) if @data['uiControl']
        end

        def as_json(options={})
          {
            type: type,
            familyName: family_name,
            givenName: given_name,
            formattedName: formatted_name,
            preferred: preferred,
            disclose: disclose,
            uiControl: ui_control,
            fromDate: (from_date.present? ? from_date.to_s : nil),
          }.compact
        end
      end
    end
  end
end
