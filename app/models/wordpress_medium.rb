class WordpressMedium < ApplicationRecord
  belongs_to :medium  #, optional: true

  enum status: {
    ignored: 0,
    considered: 1,
    prepared: 2,
    parent_ready: 3,
    uploaded: 4,
    inserted: 5,
  }
end
