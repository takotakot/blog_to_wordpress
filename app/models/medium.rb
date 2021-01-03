class Medium < ApplicationRecord
  has_many :post_medium
  has_many :post, through: :post_medium
end
