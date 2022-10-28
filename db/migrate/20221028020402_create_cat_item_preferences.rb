class CreateCatItemPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :cat_item_preferences do |t|
      t.references :cat, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.boolean :like

      t.timestamps
    end
  end
end
