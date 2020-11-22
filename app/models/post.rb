class Post < ApplicationRecord
  belongs_to :type
  has_many :post_tag
  has_many :tag, through: :post_tag
end
