class PostMedium < ApplicationRecord
  belongs_to :post
  belongs_to :medium
end
