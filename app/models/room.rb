class Room < ApplicationRecord
  has_one :cat, dependent: :destroy
  has_many :items, dependent: :destroy

  after_create :create_cat

  private

  def create_cat
    Cat.generate(id)
  end
end
