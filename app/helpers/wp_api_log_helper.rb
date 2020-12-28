module WpApiLogHelper
  def self.wp_api_log(wp_id:, method:, query:, endpoint:, ret_json:)
    log_object = WpApiLog.new
    log_object.assign_attributes({
      wp_id: wp_id,
      method: method,
      query: query,
      endpoint: endpoint,
      ret_json: ret_json,
    })
    log_object.save
  end
end
