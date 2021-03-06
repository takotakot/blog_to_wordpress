module WordpressPostHelper
  VERSION = 1

  def self.mirror_post(post)
    wp_post = self.find_or_create(post)
    self.prepare(PostHelper, wp_post)
    self.create_draft(PostHelper, wp_post)
    self.set_categories(PostHelper, wp_post)
    self.upload_all_media(PostHelper, wp_post, WordpressMediumHelper, MediumHelper)
    self.rewrite_media_tags(PostHelper, wp_post, WordpressMediumHelper, MediumHelper)
    self.upload(PostHelper, wp_post)
    self.publish(PostHelper, wp_post)
    wp_post
  end

  def self.find_or_create(post)
    wp_post = WordpressPost.find_by(post_id: post.id)
    return wp_post unless wp_post.nil?
    self.create(post)
  end

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
      date_gmt: wp_post.date.iso8601,
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
  def self.upload_all_media(posthelper, wp_post, wp_mediumhelper, mediumhelper)
    return false unless wp_post.categories_set?

    if wp_post.post.medium.length == 0
      # No media
    else
      # Upload all media
      wp_mediumhelper.upload_all_media_for_wp_post(wp_post, posthelper, self, mediumhelper)
    end

    wp_post.status = WordpressPost.statuses[:all_media_uploaded]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # all_media_uploaded -> rewritten
  def self.rewrite_media_tags(posthelper, wp_post, wp_mediumhelper, mediumhelper)
    return false unless wp_post.all_media_uploaded?

    if wp_post.post.medium.length == 0
      # No media
    else
      # Rewrite src
      wp_post.content = self.rewrite_media_tags_html(posthelper, wp_post, wp_mediumhelper, mediumhelper)
    end

    wp_post.status = WordpressPost.statuses[:rewritten]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # rewritten -> uploaded
  def self.upload(posthelper, wp_post)
    return false unless wp_post.rewritten?

    post_data = {
      content: wp_post.content,
    }
    response_hash = WordpressApiHelper.post_post(wp_post, post_data.to_json)
    pp response_hash

    wp_post.status = WordpressPost.statuses[:uploaded]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  # uploaded -> published
  def self.publish(posthelper, wp_post)
    return false unless wp_post.uploaded?

    post_data = {
      status: 'publish',
    }
    response_hash = WordpressApiHelper.post_post(wp_post, post_data.to_json)
    pp response_hash

    wp_post.status = WordpressPost.statuses[:published]

    # For development
    wp_post.version = VERSION

    wp_post.save
  end

  def self.post_categories(wp_post)
    SecretLogicHelper.post_categories(wp_post)
  end

  def self.rewrite_media_tags_html(posthelper, wp_post, wp_mediumhelper, mediumhelper)
    doc = Nokogiri::HTML::DocumentFragment.parse(wp_post.content)
    tag_attr_list = [
      'img/@src',
      'object/@src',
    ]
    tag_attr_list.each do |tag_attr|
      doc.xpath('.//' + tag_attr).each do |node_attr|
        self.rewrite_tag_attr_at_node(node_attr, posthelper, wp_post, wp_mediumhelper, mediumhelper)
      end
    end
    doc.to_html
  end

  def self.rewrite_tag_attr_at_node(node_attr, posthelper, wp_post, wp_mediumhelper, mediumhelper)
    # See Post.add_img_to_medium
    src = node_attr.value

    # Find medium
    src_uri = Addressable::URI.parse(wp_post.post.original_uri).join(src)
    medium = Medium.find_by(uri: src_uri.to_s)

    return nil if medium.nil?
    return nil unless mediumhelper.rewrite_needed?(medium)

    wp_medium = WordpressMedium.find_by(medium_id: medium.id)
    # TODO: better handling
    wp_mediumhelper.set_inserted(wp_medium)

    # No WordpressMedium record is found.
    raise if wp_medium.nil?

    # Rewrite
    node_attr.value = wp_medium.source_url
  end
end
