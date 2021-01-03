class Post < ApplicationRecord
  belongs_to :type
  has_many :post_tag
  has_many :tag, through: :post_tag
  has_many :post_medium
  has_many :medium, through: :post_medium
end
