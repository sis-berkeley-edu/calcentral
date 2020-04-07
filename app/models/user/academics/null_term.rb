module User
  module Academics
    # Used by User::Academics::Term, NullTerm is initialized with a term_id for
    # which we don't yet have data.
    #
    # It responds to #end just like the ::Berkeley::Term, but its date is always
    # in the past, so it is filtered out of the list of active terms.
    class NullTerm
      def initialize(term_id)
        @term_id = term_id
      end

      def end
        1.year.ago
      end
    end
  end
end
