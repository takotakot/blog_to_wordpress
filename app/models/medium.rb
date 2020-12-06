class Medium < ApplicationRecord
  has_many :post_medium
  has_many :post, through: :post_medium

  include ApplicationHelper

  MEDIA_DIR = 'media'

  def store_local
    return if self.uri.start_with?('data:')

    normalized_uri = normalize_uri(self.uri)
    content = get(normalized_uri)
    save_file(content)
  end

  def get(uri)
    require 'open-uri'
    begin
      dat = URI.open(uri) do |f|
        self.status = f.status[0]
        self.base_uri = f.base_uri
        self.last_modified = f.last_modified
        self.meta = f.meta.to_yaml
        f.read
      end
    rescue OpenURI::HTTPError => e
      # TODO
      # raise e
      self.status = e.io.status[0].to_i
      p 'Redirect 302', self.id, uri
      if self.status == 302
        dat = get(URI.join(uri, normalize_uri(e.io.meta['location'])))
      end
      self.status = 302 if self.status == 200
    rescue URI::InvalidURIError => e
      puts self.id
      self.status = 0
      raise
      return
    end

    dat
  end

  def media_dir_path
    Rails.root.join('media').to_s
  end

  def save_file(content)
    self.local_path = self.server_path if self.local_path == ''
    rel_path = self.local_path

    file_path = File.join(media_dir_path, rel_path)

    pathname_obj = Pathname.new(file_path)
    pathname_obj.dirname.mkpath

    # file = File.open(pathname_obj.to_s, 'w', 0666)
    # file.binwrite()
    begin
      File.binwrite(pathname_obj.to_s, content)
    rescue
      puts self.id
      raise
    end
    mtime = last_modified
    mtime ||= oldest_date
    FileUtils.touch pathname_obj.to_s, mtime: mtime.to_time
  end
end
