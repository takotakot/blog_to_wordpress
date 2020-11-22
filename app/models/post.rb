class Post < ApplicationRecord
  belongs_to :type
  has_many :post_tag
  has_many :tag, through: :post_tag
  has_many :post_medium
  has_many :medium, through: :post_medium

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
