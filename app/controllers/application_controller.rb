class ApplicationController < ActionController::Base
  INTERVAL = 0.5
  PARALLEL_TYPE = :process

  def self.add_media_by_hand
    MEDIA_RELATION.each do |record|
      post = Post.find(record[:post_id])
      media_uri = record[:media_uri]

      medium = Medium.find_or_initialize_by(uri: media_uri)
      if medium.new_record?
        medium.original_src = media_uri
        medium.is_internal = true
        medium.title = ''
        medium.alt = ''
        medium.oldest_date = post.date
        medium.server_path = media_uri
        medium.local_path = ''
        medium.date_loaded = post.date
      else
        medium.oldest_date = [medium.oldest_date, post.date].min
      end

      medium.save!
    end
  end

  def self.scrape_and_analyze_all_zero
    Post.where(status: 0).all.each do |post|
      post.scrape
      post.analyze
      sleep INTERVAL
    end
  end

  # for development
  def self.analyze_all_200
    posts = Post.where(status: 200).all
    posts.each do |post|
      post.analyze
    end
    posts.length
  end

  def self.all_html_tags_under_article
    tags = Set.new
    Post.where(status: 200).all.each do |post|
      # p tags
      tags.merge(post.all_html_tags_under_article)
    end
    tags
  end

  def self.find_html_tags_from_article(needle_tags)
    result = []

    Post.where(status: 200).all.each do |post|
      # p tags
      result.concat(post.find_html_tags_from_article(needle_tags))
    end
    result
  end

  def self.crawl_list_pages
    TO_CRAWL.each do |item|
      page = BlogPage::Base.new
      page.get(item[:uri]).crawl_list_page(item)
      sleep INTERVAL
    end
  end

  def self.download_media(status: 0, limit: -1)
    require 'parallel'
    skip = [
    ]

    locker = Mutex::new
    Medium.where(status: status).limit(limit).find_in_batches do |media|
      if PARALLEL_TYPE == :thread
        Parallel.each(media, in_threads: 3) do |medium|
        # Parallel.each(media, in_processes: 4) do |medium|
        # media.each do |medium|
          # @reconnected ||= Medium.connection.reconnect! || true
          ActiveRecord::Base.connection_pool.with_connection do
            if ! skip.include? medium.id
              medium.store_local
              locker.synchronize do
                medium.save!
              end
              # sleep INTERVAL
            end
          end
        end
      else
        Parallel.each(media, in_processes: 3) do |medium|
        # media.each do |medium|
          # @reconnected ||= Medium.connection.reconnect! || true
          # ActiveRecord::Base.connection_pool.with_connection do
            if ! skip.include? medium.id
              medium.store_local
              self.synchronize do
                medium.save!
              end
              # sleep INTERVAL
            end
          # end
        end
      end
    end
  end

  def self.synchronize(lock_file_path = 'lock.lck')
    File.open(lock_file_path, 'w') do |lock_file|
      begin
        lock_file.flock(File::LOCK_EX)
        yield
      ensure
        lock_file.flock(File::LOCK_UN)
      end
    end
  end

  def self.update_medium_data_image_610
    code = 610
    Medium.where('uri LIKE ?', 'data:image/%').all.update(status: code)
  end

  def self.medium_check_file
    ignore_status = [
      404,
      610,
    ]
    Medium.all.find_in_batches do |media|
      media.each do |medium|
        next if ignore_status.include?(medium.status)
        medium.check_file
      end
    end
  end
end
