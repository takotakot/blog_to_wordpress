class Post < ApplicationRecord
  belongs_to :type
  has_many :post_tag
  has_many :tag, through: :post_tag
  has_many :post_medium
  has_many :medium, through: :post_medium
  # attr_accessor :page
  include BlogHelper

  ANALYZED_VERSION = 1

  def scrape
    set_page

    self.status = get_page_status
    self.title = get_page_title
    self.date = get_page_date
    self.html = get_page_html

    save!
  end

  def analyze
    # use self.html after downloading
    set_doc

    # update for tune
    self.title = get_page_title
    self.date = get_page_date

    add_all_blog_tags
    add_all_media

    self.analyzed_version = ANALYZED_VERSION

    save!
  end

  def set_page
    @page = BlogPage::Base.new
    @page.get(original_uri)
  end

  def get_page_status
    @page.status
  end

  def get_page_html
    @page.html
  end

  def get_page_title
    doc = @page&.doc || set_doc
    doc.xpath('id("page_title")')[0].text
  end

  def get_page_date
    doc = @page&.doc || set_doc
    doc.xpath('id("page_date")')[0].text
  end

  def set_doc
    @doc ||= Nokogiri::HTML.parse(html)
  end

  def all_html_tags_under_article
    tags = Set.new
    set_doc

    article.each do |div|
      div.traverse do |node|
        if node.text? then
        else
          tags.add(node.name)
        end
      end
    end
    tags
  end

  def add_all_blog_tags
    set_doc
    blog_tag_nodes = @doc.xpath('id("tag_position")/a')

    blog_tags = []
    blog_tag_nodes.each do |node|
      blog_tags << blog_tag_from_nokogiri_node(node)
    end

    # not merge
    self.tag = blog_tags

    save!
  end

  def blog_tag_from_nokogiri_node(node)
    set_doc

    tag_name = node.text
    node_uri = URI.join(original_uri, node.xpath('@href').text)
    query = node_uri.query
    # node_uri.fragment = node_uri.query = nil
    tag_uri = node_uri.to_s

    blog_tag = Tag.find_or_initialize_by(name: tag_name, oldid: query)
    blog_tag.tag_uri.find_or_initialize_by(original_uri: tag_uri)
    blog_tag.memo = '' if blog_tag.memo.nil?

    blog_tag.save!
    blog_tag
  end

  def add_all_media
    set_doc

    add_all_img_to_medium
  end

  def add_all_img_to_medium
    article.xpath('.//img').each do |img|
      add_img_to_medium(img)
    end
  end

  def add_img_to_medium(img)
    set_doc

    img_src = img.xpath('@src').text
    # img_uri = URI.join(original_uri, URI.escape(img_src))
    img_uri = Addressable::URI.parse(original_uri).join(img_src)

    medium = Medium.find_or_initialize_by(uri: img_uri.to_s)
    if medium.new_record?
      medium.original_src = img_src
      medium.is_internal = is_internal_uri(img_uri.to_s)
      medium.title = img.xpath('@title').text || ''
      medium.alt = img.xpath('@alt').text || ''
      medium.oldest_date = self.date
      medium.server_path = img_uri.path
      medium.local_path = img_uri.path
      medium.date_loaded = self.date
    else
      medium.oldest_date = [medium.oldest_date, self.date].min
    end

    medium.save!
  end

  def article
    set_doc

    @doc.xpath('id("article")')
  end
end
