module HubEdos
  module StudentApi
    module V2
      module StudentRecord
        # A Unit Total is a set of numbers summing various groups of units
        class UnitTotal
          def initialize(data={})
            @data = data
          end

          # a short descriptor representing the kind of units, such as letter graded, p/np, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # the minimum number of units that must be enrolled in for a term
          def units_min
            @data['unitsMin'].try(:to_f)
          end

          # the maximum number of units that may be enrolled in or amassed
          def units_max
            @data['unitsMax'].try(:to_f)
          end

          # the number of units currently enrolled in	decimal
          def units_enrolled
            @data['unitsEnrolled'].try(:to_f)
          end

          # the number of units currently waitlisted
          def units_waitlisted
            @data['unitsWaitlisted'].try(:to_f)
          end

          # the number of units attempted (not including current enrollments)
          def units_taken
            @data['unitsTaken'].try(:to_f)
          end

          # the number of units completed with a passing grade
          def units_passed
            @data['unitsPassed'].try(:to_f)
          end

          # the number of units not completed within the term taken, and allowed by the instructor to be completed by some later date
          def units_incomplete
            @data['unitsIncomplete'].try(:to_f)
          end

          # the number of units from other institutions presented for application
          def units_transfer_earned
            @data['unitsTransferEarned'].try(:to_f)
          end

          # the number of units from other institutions actually applied to the record
          def units_transfer_accepted
            @data['unitsTransferAccepted'].try(:to_f)
          end

          # the number of units applied to the record from tests
          def units_test
            @data['unitsTest'].try(:to_f)
          end

          # the number of units applied to the record that fall outside all of these subsets
          def units_other
            @data['unitsOther'].try(:to_f)
          end

          # the number of units applied to the record from all sources
          def units_cumulative
            @data['unitsCumulative'].try(:to_f)
          end

        end
      end
    end
  end
end
