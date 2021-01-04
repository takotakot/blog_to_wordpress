class BlogPage::Base
  # < ApplicationRecord
  include BlogPage
  attr_accessor :uri, :charset, :html, :doc, :status
  require 'open-uri'

  def get(uri)
    @uri = uri
    @charset = nil
    begin
      @html = URI.open(uri) do |f|
        @charset = f.charset
        @status = f.status[0]
        f.read
      end
    rescue OpenURI::HTTPError => e
      # TODO
      # raise e
      @status = e.io.status[0].to_i
    end

    @doc = Nokogiri::HTML.parse(@html, nil, @charset)
    self
  end

  def crawl_list_page(item)
    # item[:name], item[:uri]
    type = Type.find_by(name: item[:name])

    # add all list
    add_all_detail_uri(type: type)

    # next page
    next_uri = get_next_link
    return true if next_uri.nil?  # last
    next_page = BlogPage::Base.new
    next_page.get(next_uri).crawl_list_page(item)
  end

  def add_all_detail_uri(type:)
    detail_list = @doc.xpath('id("detail_uri")/a/@href')
    detail_list.each do |node|
      uri = URI.join(@uri, node.text).to_s
      post = Post.find_or_initialize_by(original_uri: uri, type: type)
      post.save
    end
  end

  def get_next_link
    next_page_node = @doc.xpath('id("next_link")/a')[0]

    # confirm
    return nil if next_page_node.nil?
    raise if next_page_node.text != NEXT_PAGE_MESSAGE
    return URI.join(@uri, next_page_node.xpath('@href').text).to_s
  end
end
