class ApplicationController < ActionController::Base
  INTERVAL = 0.5

  def self.scrape_all_zero
    Post.where(status: 0).all.each do |post|
      post.scrape
      sleep INTERVAL
    end
  end
end
