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
end
