class Cat < ApplicationRecord
  belongs_to :room
  has_many :cat_item_preferences

  def self.generate(room_id, name: '貓貓小惡魔', saturation: 50, trustiness: 10, healthiness: 100)
    cat = create(room_id: room_id, name: name, saturation: saturation, trustiness: trustiness, healthiness: healthiness)
    items = JSON.load(File.read('app/models/items.json'))
    items.each do |item|
      item_record = cat.room.items.create(name: item['name'], item_type: item['item_type'])
      like = item['like'].nil? ? random_preference : item['like']
      cat.cat_item_preferences.create(item: item_record, like: like)
    end
  end

  private

  def random_preference
    Random.rand(10) < 5 ? true : false
  end
end
