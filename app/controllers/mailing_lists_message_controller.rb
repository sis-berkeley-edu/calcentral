class MailingListsMessageController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_filter :verify_message

  # POST /api/mailing_lists/message
  # Handle a received message.

  def relay
    # See https://documentation.mailgun.com/api-sending.html#retrieving-stored-messages for Mailgun's message parameters.
    message_attrs = {
      # Capitalized params are unaltered headers from the original message.
      id: params['Message-Id'],
      from: params['From'],
      to: params['To'],
      # Lowercase params are set by Mailgun.
      subject: params['subject'],
      body: {
        html: params['body-html'],
        plain: params['body-plain']
      },
      sender: params['sender'],
      recipient: params['recipient'],
      attachments: extract_attachments
    }

    relayed = MailingLists::IncomingMessage.new(message_attrs).relay
    render json: {success: relayed}
  end

  private

  def extract_attachments
    attachments = {}
    if params['attachment-count']
      attachments[:count] = params['attachment-count'].to_i
      attachments[:data] = {}

      if params['content-id-map']
        attachments[:cid_map] = {}
        JSON.parse(params['content-id-map']).each do |cid, attachment_name|
          stripped_cid = cid.tr('<>', '')
          attachments[:cid_map][stripped_cid] = attachment_name
        end
      end

      params.each do |key, value|
        if key.match /\Aattachment-\d+\Z/
          attachments[:data][key] = value
        end
      end
    end
    attachments
  end

  def verify_message
    if verify_timestamp && verify_signature
      # Cache signatures to prevent replay attempts.
      signature_key = "#{self.class.name}/signature/#{params['signature']}"
      verified = !Rails.cache.fetch(signature_key) && Rails.cache.write(signature_key, true, expires_in: 1.hour)
    end
    render nothing: true, status: 401 unless verified
  end

  # Verify Mailgun signature per https://documentation.mailgun.com/user_manual.html#webhooks
  def verify_signature
    digest = OpenSSL::Digest::SHA256.new
    nonce = params.values_at('timestamp', 'token').join
    params['signature'] == OpenSSL::HMAC.hexdigest(digest, Settings.mailgun_proxy.api_key, nonce)
  end

  # Timestamp must be reasonably close to the current time.
  def verify_timestamp
    (Time.now.to_i - params['timestamp'].to_i).abs <= Settings.canvas_mailing_lists.timestamp_tolerance
  end
end
