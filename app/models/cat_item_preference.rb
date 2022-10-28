class CatItemPreference < ApplicationRecord
  belongs_to :cat
  belongs_to :item
end
