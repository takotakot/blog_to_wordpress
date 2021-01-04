module SecretLogicHelper
  HASH_DATA = [
    {id: 1, name: 'type 1', wp_categories: [1]},
  ]

  def self.type_id_to_wp_posttype(type_id)
    posttype = 'post'
    return posttype
  end

  def self.post_categories(wp_post)
    type_id = wp_post.post.type_id

    category_name_list = {
      'cat 1' => [1],
    }

    category_name = ''
    category_name_list.each do |k,v|
      if v.include?(type_id)
        category_name = k
        break
      end
    end
    return {} if category_name == ''

    return {
      category_name => self.post_categories_from_type_id(type_id),
    }
  end

  def self.post_categories_from_type_id(type_id)
    HASH_DATA.each do |h|
      next unless h[:id] == type_id
      return h[:wp_categories]
    end
    return []
  end

  def self.mirror_posts(status: 200, type_id: nil, limit: -1)
    Post.where(status: status, type_id: type_id).limit(limit).each do |post|
      WordpressPostHelper.mirror_post(post)
    end
  end

  def self.create_not_processed_wp_posts(status: 200, type_id: nil, limit: -1)
    Post.where(status: status, type_id: type_id).order(date: :asc).limit(limit) do |post|
      WordpressPostHelper.find_or_create(post)
    end
  end

  def self.proceed_wp_posts(limit: -1, status: 1)
    WordpressPost.joins(:post).where(status: status).merge(Post.order(date: :asc)).limit(limit).each do |wp_post|
      # p wp_post.post.date
      WordpressPostHelper.mirror_post(wp_post.post)
    end
  end
end
