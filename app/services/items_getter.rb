class ItemsGetter
  class << self
    def items
      JSON.load(File.read('app/models/items.json'))
    end
  end
end