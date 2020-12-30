module MediumHelper
  def self.title(medium)
    medium.title
  end

  def self.alt_text(medium)
    medium.alt
  end

  def self.date(medium)
    medium.oldest_date
  end

  def self.upload_needed?(medium)
    return false if medium.base_uri.nil?
    return false if medium.uri.start_with?('data:')
    return false unless medium.is_internal
    true
  end

  def self.file_path(medium)
    File.join(medium.media_dir_path, medium.local_path)
  end

  def self.file_name(medium)
    File.basename(medium.local_path)
  end
end
