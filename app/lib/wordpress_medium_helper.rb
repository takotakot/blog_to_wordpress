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
    upload
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
  def upload
    require 'mime/types'
    require 'net/http/post/multipart'

    return nil unless @wp_medium.parent_ready?
    return nil unless @wp_medium.wp_id.nil?

    file_path = mediumhelper.file_path(@wp_medium.medium)

    post_data = {
      title: @wp_medium.title,
      alt_text: @wp_medium.alt_text,
      date: @wp_medium.date.iso8601,
      post: @wp_medium.wp_post_id,
      file: UploadIO.new(file_path, MIME::Types.type_for(file_path)[0].to_s),
    }
    response_hash = WordpressApiHelper.post_media(@wp_medium, post_data)
    pp response_hash

    @wp_medium.wp_id = response_hash['id']
    @wp_medium.source_url = response_hash['source_url']
    @wp_medium.status = WordpressMedium.statuses[:uploaded]

    # For development
    @wp_medium.version = VERSION

    @wp_medium.save
  end

  # uploaded -> inserted
end
