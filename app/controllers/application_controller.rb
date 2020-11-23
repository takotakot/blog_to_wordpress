class ApplicationController < ActionController::Base
  INTERVAL = 0.5

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
end
