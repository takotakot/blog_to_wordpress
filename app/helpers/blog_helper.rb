module BlogHelper
  def is_internal_uri(uri)
    uri.include?(Rails.application.credentials.blog_domain)
  end
end
