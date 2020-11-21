# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_21_074440) do

  create_table "media", force: :cascade do |t|
    t.boolean "is_internal", null: false
    t.string "original_src", null: false
    t.string "server_path", null: false
    t.string "name", null: false
    t.string "local_path", null: false
    t.date "date_loaded", null: false
    t.date "oldest_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "post_types", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "type_id", null: false
    t.index "\"post\", \"type\"", name: "index_post_types_on_post_and_type", unique: true
    t.index ["post_id"], name: "index_post_types_on_post_id"
    t.index ["type_id"], name: "index_post_types_on_type_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "original_uri", null: false
    t.string "title"
    t.datetime "date"
    t.integer "type_id", null: false
    t.string "html"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["type_id"], name: "index_posts_on_type_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "oldid", null: false
    t.string "memo", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "post_types", "posts"
  add_foreign_key "post_types", "types"
  add_foreign_key "posts", "types"
end
