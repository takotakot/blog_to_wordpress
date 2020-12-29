module WordpressPostHelper
  VERSION = 1

  def self.create(post)
    wp_post = WordpressPost.find_or_initialize_by(post_id: post.id)
    return nil unless wp_post.new_record?

    # Update attributes
    wp_post.post_id = post.id
    wp_post.status = WordpressPost.statuses[:before_processed]

    # For development
    wp_post.version = VERSION

    return nil unless wp_post.save
    wp_post
  end
end
