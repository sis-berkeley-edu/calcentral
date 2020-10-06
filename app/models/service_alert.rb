class ServiceAlert < ActiveRecord::Base
  include OraclePrimaryHelper

  self.table_name = 'PS_UC_CLC_SRVALERT'
  self.primary_key = 'uc_clc_id'

  if self.primary_database_is_oracle?
    attribute :uc_alrt_display, :boolean
    attribute :uc_alrt_splash, :boolean
  end

  # Convert the API to something easily legible
  alias_attribute :title, :uc_alrt_title
  alias_attribute :display, :uc_alrt_display
  alias_attribute :body, :uc_alrt_body
  alias_attribute :publication_date, :uc_alrt_pubdt
  alias_attribute :snippet, :uc_alrt_snippt
  alias_attribute :splash_only, :uc_alrt_splash

  validates :title, presence: true
  validates :body, presence: true
  validates :publication_date, presence: true

  scope :displayed, -> { where(display: true) }

  before_create :set_id
  after_save :expire_feed

  def self.public_feed
    self.where(display: true).order(publication_date: :asc)
  end

  def as_json(options={})
    {
      id: id,
      title: title,
      body: body,
      snippet: snippet,
      publication_date: formatted_publication_date,
      display: display,
      splash_only: splash_only
    }
  end

  private

  def formatted_publication_date
    publication_date.to_date.iso8601
  end

  def expire_feed
    Api::ServiceAlerts.expire
  end
end
