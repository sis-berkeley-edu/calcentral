module HubEdos
  module Common
    module Contact
      class Email
        def initialize(data={})
          @data = data
        end

        # a short descriptor representing the kind email, such as work or personal etc.
        def type
          ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
        end

        # the full email address, including account name, host name, and suffix	string
        def email_address
          @data['emailAddress']
        end

        # an indicator of whether this email address should be the main one used
        def primary
          @data['primary']
        end

        # an indicator of whether this email address should be disclosed to the public
        def disclose
          @data['disclose']
        end

        # a short descriptor indicating limits on displaying or editing this email
        def ui_control
          ::HubEdos::Common::Reference::Descriptor.new(@data['uiControl']) if @data['uiControl']
        end

        # the date this email address stopped being used
        def to_date
          @to_date ||= begin
            Date.parse(@data['toDate']) if @data['toDate']
          end
        end

        # the date this email address came into use
        def from_date
          @from_date ||= begin
            Date.parse(@data['fromDate']) if @data['fromDate']
          end
        end

        def as_json(options={})
          {
            type: type,
            emailAddress: email_address,
            primary: primary,
            disclose: disclose,
            uiControl: ui_control,
            fromDate: from_date,
            toDate: to_date,
          }.compact
        end
      end
    end
  end
end
