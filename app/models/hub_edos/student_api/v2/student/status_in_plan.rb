module HubEdos
  module StudentApi
    module V2
      module Student
        # A Status in Plan describes the student's current status within the academic plan and program
        class StatusInPlan
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the student's current status within the academic plan and program
          def status
            ::HubEdos::Common::Reference::Descriptor.new(@data['status']) if @data['status']
          end

          def status_code
            status.code
          end

          # a short descriptor representing how the student came to be in this status
          def action
            ::HubEdos::Common::Reference::Descriptor.new(@data['action']) if @data['action']
          end

          # a short descriptor representing why the student came to be in this status
          def reason
            ::HubEdos::Common::Reference::Descriptor.new(@data['reason']) if @data['reason']
          end

        end
      end
    end
  end
end
