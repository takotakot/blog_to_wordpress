class Post < ApplicationRecord
  belongs_to :type
  has_many :post_tag
  has_many :tag, through: :post_tag
  has_many :post_medium
  has_many :medium, through: :post_medium
  # attr_accessor :page

  def scrape
    set_page

    self.status = get_page_status
    self.title = get_page_title
    self.date = get_page_date
    self.html = get_page_html

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

  def article
    set_doc

    @doc.xpath('id("article")')
  end
end
