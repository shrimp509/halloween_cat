class Room < ApplicationRecord
  has_one :cat, dependent: :destroy
  has_many :items, dependent: :destroy

  after_create :create_cat

  def self.ranking(topn = 10)
    Room.includes(:cat).order(score: :desc).first(topn)
  end

  def existing_items
    items.select{|item| item.count > 0}
  end

  def room_name
    response = Api::V1::WebhookController.helpers.client.get_group_summary(line_id)
    body = JSON.load(response.body)
    name = body&.dig('groupName')
    if name.nil?
      response = Api::V1::WebhookController.helpers.client.get_profile(line_id)
      body = JSON.load(response.body)
      name = body&.dig('displayName')
    end

    name
  end

  private

  def create_cat
    Cat.generate(id)
  end
end
