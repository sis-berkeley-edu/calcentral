class OracleBase < ActiveRecord::Base
  def self.test_data?
    self.settings.adapter == "h2"
  end

  def self.fake?
    self.settings.fake
  end

  # Oracle and H2 have no timestamp formatting function in common.
  def self.timestamp_format(timestamp_column)
    return "formatdatetime(#{timestamp_column}, 'yyyy-MM-dd HH:mm:ss')" if test_data?
    "to_char(#{timestamp_column}, 'yyyy-mm-dd hh24:mi:ss')"
  end

  def self.timestamp_parse(datetime)
    return "parsedatetime('#{datetime.utc.to_s(:db)}', 'yyyy-MM-dd HH:mm:ss')" if test_data?
    "to_date('#{datetime.utc.to_s(:db)}', 'yyyy-mm-dd hh24:mi:ss')"
  end

  def self.stringify_ints!(results, additional_columns=[])
    columns = stringified_columns + additional_columns
    if results.respond_to?(:to_ary)
      results.to_ary.each { |row| stringify_row!(row, columns) }
    else
      stringify_row!(results, columns)
    end
  end

  def self.stringify_row!(row, columns)
    columns.each { |column| self.stringify_column!(row, column) }
    row
  end

  def self.stringify_column!(row, column, zero_padding = 0)
    if row && row[column]
      return if row[column].is_a?(String)
      row[column] = "%0#{zero_padding}d" % row[column].to_i
    end
  end

  def self.stringified_columns
    []
  end

  # Oracle has a limit of 1000 terms per expression, so whitelist predicates with more than 1000 entries must be
  # constructed in chunks joined with OR.
  def self.chunked_whitelist(column_name, terms=[])
    predicates = terms.each_slice(1000).map do |slice|
      "#{column_name} IN (#{slice.join ','})"
    end
    "(#{predicates.join ' OR '})"
  end
end
