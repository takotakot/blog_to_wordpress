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

ActiveRecord::Schema.define(version: 2020_12_30_104840) do

  create_table "media", force: :cascade do |t|
    t.boolean "is_internal", null: false
    t.string "original_src", null: false
    t.string "server_path", null: false
    t.string "title", null: false
    t.string "local_path", null: false
    t.date "date_loaded", null: false
    t.date "oldest_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "alt", null: false
    t.text "uri", null: false
    t.integer "status", default: 0, null: false
    t.text "base_uri"
    t.datetime "last_modified"
    t.text "meta"
  end

  create_table "post_media", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "medium_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["medium_id"], name: "index_post_media_on_medium_id"
    t.index ["post_id", "medium_id"], name: "index_post_media_on_post_id_and_medium_id", unique: true
    t.index ["post_id"], name: "index_post_media_on_post_id"
  end

  create_table "post_tags", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id", "tag_id"], name: "index_post_tags_on_post_id_and_tag_id", unique: true
    t.index ["post_id"], name: "index_post_tags_on_post_id"
    t.index ["tag_id"], name: "index_post_tags_on_tag_id"
  end

  create_table "post_types", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "type_id", null: false
    t.index ["post_id", "type_id"], name: "index_post_types_on_post_id_and_type_id", unique: true
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
    t.integer "status", default: 0, null: false
    t.integer "analyzed_version", default: 0, null: false
    t.index ["status"], name: "index_posts_on_status"
    t.index ["type_id"], name: "index_posts_on_type_id"
  end

  create_table "tag_uris", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.text "original_uri"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id", "original_uri"], name: "index_tag_uris_on_tag_id_and_original_uri", unique: true
    t.index ["tag_id"], name: "index_tag_uris_on_tag_id"
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

  create_table "wordpress_media", force: :cascade do |t|
    t.integer "medium_id", null: false
    t.bigint "wp_id"
    t.integer "status", default: 0, null: false
    t.datetime "date"
    t.bigint "wp_post_id"
    t.text "title"
    t.text "alt_text"
    t.integer "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "source_url"
    t.index ["medium_id"], name: "index_wordpress_media_on_medium_id"
    t.index ["status"], name: "index_wordpress_media_on_status"
    t.index ["wp_id"], name: "index_wordpress_media_on_wp_id", unique: true
    t.index ["wp_post_id"], name: "index_wordpress_media_on_wp_post_id"
  end

  create_table "wordpress_posts", force: :cascade do |t|
    t.integer "post_id"
    t.bigint "wp_id"
    t.integer "status", default: 0, null: false
    t.text "slug"
    t.text "title"
    t.text "content", limit: 4294967295
    t.datetime "date"
    t.integer "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_wordpress_posts_on_post_id"
    t.index ["status"], name: "index_wordpress_posts_on_status"
    t.index ["wp_id"], name: "index_wordpress_posts_on_wp_id", unique: true
  end

  create_table "wp_api_logs", force: :cascade do |t|
    t.bigint "wp_id"
    t.text "method"
    t.text "endpoint"
    t.text "query"
    t.text "ret_json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "post_media", "media"
  add_foreign_key "post_media", "posts"
  add_foreign_key "post_tags", "posts"
  add_foreign_key "post_tags", "tags"
  add_foreign_key "post_types", "posts"
  add_foreign_key "post_types", "types"
  add_foreign_key "posts", "types"
  add_foreign_key "tag_uris", "tags"
  add_foreign_key "wordpress_media", "media"
  add_foreign_key "wordpress_posts", "posts"
end
