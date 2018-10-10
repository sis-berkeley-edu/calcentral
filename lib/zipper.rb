require 'zip'

module Zipper
  extend self

  def zip_flattened(input_file_paths, output_zip_path)
    count = 0
    if File.file? output_zip_path
      Rails.logger.warn "Zipper output path #{output_zip_path} already exists and will be added to"
    end
    Zip::File.open(output_zip_path, Zip::File::CREATE) do |zipfile|
      input_file_paths.each do |file_path|
        if File.file? file_path
          basefile = File.basename file_path
          zipfile.add(basefile, file_path)
          count += 1
        else
          Rails.logger.warn "Zipper received bad input file path #{file_path}"
        end
      end
    end
    Rails.logger.info "Zipper added #{count} files to #{output_zip_path}"
    output_zip_path
  end

end
