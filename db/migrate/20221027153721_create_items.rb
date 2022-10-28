class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :item_type, default: 0
      t.integer :count, default: 0
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
