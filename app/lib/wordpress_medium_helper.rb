class WordpressMediumHelper
  VERSION = 1
  attr_accessor :medium, :mediumhelper, :wp_post, :posthelper, :wp_posthelper, :wp_medium

  def initialize(medium:, mediumhelper:, wp_post:, posthelper:, wp_posthelper:)
    @medium = medium
    @mediumhelper = mediumhelper
    @wp_post = wp_post
    @posthelper = posthelper
    @wp_posthelper = wp_posthelper
    @wp_medium = WordpressMedium.find_by(medium_id: @medium.id)
  end

  def mirror
    find_or_create
    prepare
    set_parent
    raise
  end

  def self.upload_all_media_for_wp_post(wp_post, posthelper, wp_posthelper, mediumhelper)
    wp_post.post.medium.each do |medium|
      if mediumhelper.upload_needed?(medium)
        wp_medium_h = self.new(medium: medium, mediumhelper: mediumhelper, wp_post: wp_post, posthelper: posthelper, wp_posthelper: wp_posthelper)
        wp_medium_h.mirror
      end
    end
  end

  def find_or_create
    @wp_medium = WordpressMedium.find_by(medium_id: @medium.id)
    return unless @wp_medium.nil?
    create
  end

  # ignored -> considered
  def create
    @wp_medium = WordpressMedium.find_or_initialize_by(medium_id: @medium.id)
    return nil unless @wp_medium.new_record?

    # Update attributes
    # wp_medium.medium_id = medium.id
    @wp_medium.status = WordpressMedium.statuses[:considered]

    # For development
    @wp_medium.version = VERSION

    return nil unless @wp_medium.save
    self
  end

  # considered -> prepared
  def prepare
    return false unless @wp_medium.considered?

    # Update attributes
    @wp_medium.title = @mediumhelper.title(@wp_medium.medium)
    @wp_medium.alt_text = @mediumhelper.alt_text(@wp_medium.medium)
    @wp_medium.date = @mediumhelper.date(@wp_medium.medium)
    @wp_medium.status = WordpressMedium.statuses[:prepared]

    # For development
    @wp_medium.version = VERSION

    @wp_medium.save
  end

  # prepared -> parent_ready
  def set_parent
    return nil unless @wp_medium.prepared?
    return nil if @wp_post.wp_id.nil?

    # Set parent post
    @wp_medium.wp_post_id ||= @wp_post.wp_id
    @wp_medium.status = WordpressMedium.statuses[:parent_ready]

    # For development
    @wp_medium.version = VERSION

    @wp_medium.save
  end

  # parent_ready -> uploaded
  # uploaded -> inserted
end
