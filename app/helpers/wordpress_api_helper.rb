module WordpressApiHelper
  def self.post_endpoint(wp_post)
    type_id = wp_post.post.type_id
    return Rails.application.credentials.wp_api_uri + self.type_id_to_wp_posttype(type_id)
  end

  # Help determine endpoint
  def self.type_id_to_wp_posttype(type_id)
    SecretLogicHelper.type_id_to_wp_posttype(type_id)
  end
end
