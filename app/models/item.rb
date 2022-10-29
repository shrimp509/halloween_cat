class Item < ApplicationRecord
  belongs_to :room
  has_many :cat_item_preferences

  enum item_type: [:food, :toy]

  class << self
    def get_attr(name)
      all_items.select { |item| item['name'] == name }&.last
    end

    def all_items
      ItemsGetter.items
    end
  end

end
