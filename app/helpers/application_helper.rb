module ApplicationHelper
  def normalize_uri(uri)
    Addressable::URI.parse(uri).normalize.to_s
  end
end
