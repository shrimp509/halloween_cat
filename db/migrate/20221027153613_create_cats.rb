class CreateCats < ActiveRecord::Migration[7.0]
  def change
    create_table :cats do |t|
      t.string :name
      t.integer :saturation, default: 50
      t.integer :trustiness, default: 10
      t.integer :healthiness, default: 100
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
