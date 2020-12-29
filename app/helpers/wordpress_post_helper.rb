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
  # Post type is depend on post.type
  def self.create_draft(posthelper, wp_post)
    return false unless wp_post.prepared?

    post_data = {
      title: wp_post.title,
      content: wp_post.content,
      date: wp_post.date.iso8601,
      status: 'draft',
    }
    response_hash = WordpressApiHelper.post_post(wp_post, post_data.to_json)
    pp response_hash

    wp_post.wp_id = response_hash['id']
    wp_post.status = WordpressPost.statuses[:draft_created]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # draft_created -> categories_set
  def self.set_categories(posthelper, wp_post)
    return false unless wp_post.draft_created?

    post_data = self.post_categories(wp_post)
    response_hash = WordpressApiHelper.post_post(wp_post, post_data.to_json)
    pp response_hash

    wp_post.status = WordpressPost.statuses[:categories_set]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # categories_set -> all_media_uploaded
  # all_media_uploaded -> rewritten
  # rewritten -> uploaded
  # uploaded -> published

  def self.post_categories(wp_post)
    SecretLogicHelper.post_categories(wp_post)
  end
end
