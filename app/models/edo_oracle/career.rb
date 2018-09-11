module EdoOracle
  class Career < BaseProxy
    include ClassLogger

    def initialize(options = {})
      super(Settings.edodb, options)
    end

    def fetch
      EdoOracle::Queries.get_careers(@uid)
    end

    def get_cumulative_units
      EdoOracle::Queries.get_cumulative_units(@uid)
    end
  end
end
