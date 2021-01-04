module SecretLogicHelper
  HASH_DATA = [
    {id: 1, name: 'type 1', wp_categories: [1]},
  ]

  def self.type_id_to_wp_posttype(type_id)
    posttype = 'post'
    return posttype
  end

  def self.post_categories_from_type_id(type_id)
    HASH_DATA.each do |h|
      next unless h[:id] == type_id
      return h[:wp_categories]
    end
    return []
  end
end
