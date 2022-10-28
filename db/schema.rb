# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_10_28_020402) do
  create_table "cat_item_preferences", force: :cascade do |t|
    t.integer "cat_id", null: false
    t.integer "item_id", null: false
    t.boolean "like"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cat_id"], name: "index_cat_item_preferences_on_cat_id"
    t.index ["item_id"], name: "index_cat_item_preferences_on_item_id"
  end

  create_table "cats", force: :cascade do |t|
    t.string "name"
    t.integer "saturation", default: 50
    t.integer "trustiness", default: 10
    t.integer "healthiness", default: 100
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_cats_on_room_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "item_type", default: 0
    t.integer "count", default: 0
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_items_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "line_id", null: false
    t.integer "score", default: 0
    t.integer "money", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cat_item_preferences", "cats"
  add_foreign_key "cat_item_preferences", "items"
  add_foreign_key "cats", "rooms"
  add_foreign_key "items", "rooms"
end
