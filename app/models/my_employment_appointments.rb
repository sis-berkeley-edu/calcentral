class MyEmploymentAppointments
  include Cache::CachedFeed
  include Cache::UserCacheExpiry

  attr_accessor :uid

  def initialize(uid)
    self.uid = uid
  end

  def get_feed_internal
    {
      termsTaught: terms_taught,
      appointments: appointments,
      link: reporting_center
    }
  end

  def instance_key
    uid
  end

  private

  def terms_taught
    EdoOracle::EmploymentAppointmentQueries.get_terms_taught(uid)
  end

  def appointments
    EdoOracle::EmploymentAppointmentQueries.get_appointments(uid)
  end

  def reporting_center
    LinkFetcher.fetch_link('UC_CX_REPORTING_CENTER')
  end
end
