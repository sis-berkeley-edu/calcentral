module DataLoch
  class S3
    include ClassLogger

    def initialize(target=nil)
      settings = Settings.data_loch
      if target
        s3_config = settings.targets.find {|c| c.name == target}
        raise ArgumentError, "Could not find data_loch target #{target}" unless s3_config
      else
        # TODO Remove support for old one-S3-target-only configurations in next release.
        s3_config = settings
      end
      @bucket = s3_config.bucket
      @prefix = s3_config.prefix
      @resource = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(s3_config.aws_key, s3_config.aws_secret),
        region: s3_config.aws_region
      )
    end

    def upload(subfolder, local_path, is_historical=false)
      if is_historical
        key = "#{@prefix}/historical/#{subfolder}/#{File.basename local_path}"
      else
        today = (Settings.terms.fake_now || DateTime.now).in_time_zone.strftime('%Y-%m-%d')
        digest = Digest::MD5.hexdigest today
        key = "#{@prefix}/daily/#{digest}-#{today}/#{subfolder}/#{File.basename local_path}"
      end
      begin
        @resource.bucket(@bucket).object(key).upload_file local_path, server_side_encryption: 'AES256'
        logger.info("S3 upload complete (bucket=#{@bucket}, key=#{key}")
        key
      rescue => e
        logger.error("Error on S3 upload (bucket=#{@bucket}, key=#{key}: #{e.message}")
        nil
      end
    end

  end
end
