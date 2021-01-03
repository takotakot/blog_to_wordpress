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

  # before_processed -> prepared
  def self.prepare(posthelper, wp_post)
    return false unless wp_post.before_processed?

    # Update attributes
    wp_post.title = posthelper.title(wp_post.post)
    wp_post.content = posthelper.content(wp_post.post)
    wp_post.date = posthelper.date(wp_post.post)
    wp_post.status = WordpressPost.statuses[:prepared]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # prepared -> draft_created
  # draft_created -> categories_set
  # categories_set -> all_media_uploaded
  # all_media_uploaded -> rewritten
  # rewritten -> uploaded
  # uploaded -> published
end
