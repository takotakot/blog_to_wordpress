class WordpressPost < ApplicationRecord
  belongs_to :post  #, optional: true

  enum status: {
    ignored: 0,
    before_processed: 1,
    prepared: 2,
    draft_created: 3,
    categories_set: 4,
    all_media_uploaded: 5,
    rewritten: 6,
    uploaded: 7,
    published: 8,
  }
end
