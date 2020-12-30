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
end
