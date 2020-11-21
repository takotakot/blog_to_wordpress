class Type < ApplicationRecord
  has_many :posts

  HASH_DATA = [
    {id: 1, name: 'type 1'},
  ]
end
