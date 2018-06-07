module DataLoch
  class S3
    include ClassLogger

    def initialize
      @settings = Settings.data_loch
      @resource = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(@settings.aws_key, @settings.aws_secret),
        region: @settings.aws_region
      )
    end

    def upload(subfolder, local_path, is_historical=false)
      if is_historical
        key = "#{@settings.prefix}/historical/#{subfolder}/#{File.basename local_path}"
      else
        today = (Settings.terms.fake_now || DateTime.now).in_time_zone.strftime('%Y-%m-%d')
        digest = Digest::MD5.hexdigest today
        key = "#{@settings.prefix}/daily/#{digest}-#{today}/#{subfolder}/#{File.basename local_path}"
      end
      begin
        @resource.bucket(@settings.bucket).object(key).upload_file local_path, server_side_encryption: 'AES256'
        logger.info("S3 upload complete (bucket=#{@settings.bucket}, key=#{key}")
        key
      rescue => e
        logger.error("Error on S3 upload (bucket=#{@settings.bucket}, key=#{key}: #{e.message}")
        nil
      end
    end

  end
end
