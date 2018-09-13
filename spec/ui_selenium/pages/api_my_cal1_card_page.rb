class ApiMyCal1CardPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info 'Parsing JSON from /api/my/cal1card'
    navigate_to "#{WebDriverUtils.base_url}/api/my/cal1card"
    @parsed = JSON.parse driver.find_element(:xpath, '//pre').text
  end

  def has_data?
    true unless @parsed['cal1cardStatus'].nil?
  end

  def card_lost?
    true if @parsed['cal1cardLost'] == 'Lost'
  end

  def card_found?
    true if @parsed['cal1cardLost'] == 'Found'
  end

  def has_debit_account?
    true if @parsed['debitMessage'] == 'OK'
  end

  def debit_balance
    (sprintf '%.2f', @parsed['debit'].to_f).to_s
  end
end
