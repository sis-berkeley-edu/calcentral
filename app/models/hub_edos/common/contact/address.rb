module HubEdos
  module Common
    module Contact
      # An Address describes information associated with a location
      class Address
        def initialize(data={})
          @data = data
        end

        # a short descriptor representing the kind address, such as home or mailing, etc.
        def type
          ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
        end

        # the first line of a street address, usually including a number and a street name
        def address_1
          @data['address1']
        end

        # the second line of a street address
        def address_2
          @data['address2']
        end

        # the third line of a street address
        def address_3
          @data['address3']
        end

        # the fourth line of a street address
        def address_4
          @data['address4']
        end

        # a general number associated with a non-USA location
        def num_1
          @data['num1']
        end

        # another general number associated with a non-USA location
        def num_2
          @data['num2']
        end

        # general use text associated with a non-USA location
        def addr_field_1
          @data['addrField1']
        end

        # second general use text associated with a non-USA location
        def addr_field_2
          @data['addrField2']
        end

        # third general use text associated with a non-USA location
        def addr_field_3
          @data['addrField3']
        end

        # an indicator or the kind of structure associated with a non-USA location
        def house_type
          @data['houseType']
        end

        # a specific, named, local area
        def city
          @data['city']
        end

        # a specific, named, wider area
        def county
          @data['county']
        end

        # a code representing the state, region, or province
        def state_code
          @data['stateCode']
        end

        # the full name of the state, region, or province
        def state_name
          @data['stateName']
        end

        # a code used by the country to designate a postal delivery zone
        def postal_code
          @data['postalCode']
        end

        # a code representing the country, defaults to "USA"
        def country_code
          @data['countryCode']
        end

        # the full name of the country
        def country_name
          @data['countryName']
        end

        # a combination of all address elements in the correct order with line breaks
        def formatted_address
          @data['formattedAddress']
        end

        # an indicator of whether this address should be the main one used
        def primary
          @data['primary']
        end

        # an indicator of whether this address should be disclosed to the public
        def disclose
          @data['disclose']
        end

        # a short descriptor indicating limits on displaying or editing this address
        def ui_control
          ::HubEdos::Common::Reference::Descriptor.new(@data['uiControl']) if @data['uiControl']
        end

        # the user who last changed the address
        def last_changed_by
          ::HubEdos::Common::Reference::Party.new(@data['lastChangedBy']) if @data['lastChangedBy']
        end

        # the date this address came into use
        def from_date
          @from_date ||= begin
            Date.parse(@data['fromDate']) if @data['fromDate']
          end
        end

        # the date this address stopped being used
        def to_date
          @to_date ||= begin
            Date.parse(@data['toDate']) if @data['toDate']
          end
        end

        def as_json(options={})
          {
            type: type,
            address1: address_1,
            address2: address_2,
            address3: address_3,
            address4: address_4,
            num1: num_1,
            num2: num_2,
            addrField1: addr_field_1,
            addrField2: addr_field_2,
            addrField3: addr_field_3,
            houseType: house_type,
            city: city,
            county: county,
            stateCode: state_code,
            stateName: state_name,
            postalCode: postal_code,
            countryCode: country_code,
            countryName: country_name,
            formattedAddress: formatted_address,
            primary: primary,
            disclose: disclose,
            uiControl: ui_control,
            lastChangedBy: last_changed_by,
            fromDate: from_date,
            toDate: to_date,
          }.compact
        end

      end
    end
  end
end
