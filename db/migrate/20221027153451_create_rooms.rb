class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :line_id, null: false
      t.integer :score, default: 0
      t.integer :money, default: 0

      t.timestamps
    end
  end
end
