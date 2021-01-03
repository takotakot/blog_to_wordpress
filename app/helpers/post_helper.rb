module PostHelper
  def self.title(post)
    post.title
  end

  def self.content(post)
    post.article
  end

  def self.date(post)
    post.date
  end
end
