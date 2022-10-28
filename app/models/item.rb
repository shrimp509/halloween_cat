class Item < ApplicationRecord
  belongs_to :room
  has_many :cat_item_preferences

  enum item_type: [:food, :toy]
end
