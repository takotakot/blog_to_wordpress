module WordpressApiHelper
  def self.post_endpoint(wp_post)
    type_id = wp_post.post.type_id
    return Rails.application.credentials.wp_api_uri + self.type_id_to_wp_posttype(type_id)
  end

  def self.media_endpoint
    return Rails.application.credentials.wp_api_uri + 'media'
  end


  # Help determine endpoint
  def self.type_id_to_wp_posttype(type_id)
    SecretLogicHelper.type_id_to_wp_posttype(type_id)
  end

  def self.post_post(wp_post, post_data)
    require 'net/http'

    uri = self.post_endpoint(wp_post)

    unless wp_post.wp_id.nil?
      # update
      uri += '/' + wp_post.wp_id.to_s
      wp_id = wp_post.wp_id
    else
      # new
    end

    uri_obj= URI.parse(uri)
    http = Net::HTTP.new(uri_obj.host, uri_obj.port)

    req = Net::HTTP::Post.new(uri_obj.path)
    req.content_type = 'application/json'
    req.body = post_data
    req.basic_auth(Rails.application.credentials.wp_api_username, Rails.application.credentials.wp_api_password)

    response = http.request(req)
    response_body_hash = JSON.parse(response.body)
    wp_id ||= response_body_hash['id']

    p response_body_hash
    if response.code == '201'
      p 'Post success: ' + wp_id.to_s
      WpApiLogHelper.wp_api_log(wp_id: wp_id, method: 'POST', query: post_data, endpoint: uri, ret_json: response.body)
    else
      p ['---Failed to WP API Post---', response.code, response.message, response.body].join("\n")
      WpApiLogHelper.wp_api_log(wp_id: wp_id, method: 'POST', query: post_data, endpoint: uri, ret_json: response.body)
    end
    return response_body_hash
  end

  def self.post_media(wp_medium, post_data)
    require 'net/http'
    require 'net/http/post/multipart'

    uri = self.media_endpoint

    unless wp_medium.wp_id.nil?
      # update
      uri += '/' + wp_medium.wp_id.to_s
      wp_id = wp_medium.wp_id
    else
      # new
    end

    uri_obj= URI.parse(uri)
    http = Net::HTTP.new(uri_obj.host, uri_obj.port)
    # http.set_debug_output($stdout)

    req = Net::HTTP::Post::Multipart.new(uri_obj.path, post_data)
    req.basic_auth(Rails.application.credentials.wp_api_username, Rails.application.credentials.wp_api_password)
    pp req

    response = http.request(req)
    response_body_hash = JSON.parse(response.body)
    wp_id ||= response_body_hash['id']

    p response_body_hash
    if response.code == '201'
      p 'Post success: ' + wp_id.to_s
      WpApiLogHelper.wp_api_log(wp_id: wp_id, method: 'POST', query: post_data, endpoint: uri, ret_json: response.body)
    else
      p ['---Failed to WP API Post---', response.code, response.message, response.body].join("\n")
      WpApiLogHelper.wp_api_log(wp_id: wp_id, method: 'POST', query: post_data, endpoint: uri, ret_json: response.body)
    end
    return response_body_hash
  end

end
