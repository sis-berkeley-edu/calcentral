# Representation of an individual row within Oec::Worksheet. It exposes an interface broadly similar to Hash, but
# constrains keys to worksheet headers and stores values in an array for a smaller memory footprint. If a worksheet
# has defined transient headers, these values may be written and read in memory but will not be included in CSV export.

module Oec
  class WorksheetRow
    include Enumerable

    def initialize(hash, worksheet)
      @worksheet = worksheet
      @values = all_headers.map { |header| hash[header] }
    end

    def [](key)
      @values[get_index(key)]
    end

    def []=(key, value)
      @values[get_index(key)] = value
    end

    def all_headers
      @worksheet.headers + @worksheet.transient_headers
    end

    def each
      self.to_hash_transient.each { |k, v| yield k, v }
    end

    def empty?
      !@values.any?
    end

    def get_index(key)
      all_headers.index(key) || (raise ArgumentError, "Key '#{key}' not found in WorksheetRow")
    end

    def merge(other_row)
      self.to_hash.merge other_row.to_hash
    end

    def slice(*args)
      self.to_hash_transient.slice *args
    end

    # Do not include transient values.
    def to_hash
      Hash[@worksheet.headers.zip @values]
    end

    # Include transient values.
    def to_hash_transient
      Hash[all_headers.zip @values]
    end

    def update(other_row)
      other_row.each { |k, v| self[k] = v }
    end
  end
end
