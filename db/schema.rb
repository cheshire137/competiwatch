# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180204203946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "maps", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "map_type", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_maps_on_name", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.integer "oauth_account_id", null: false
    t.integer "map_id", null: false
    t.integer "rank", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "season_id", null: false
    t.integer "prior_match_id"
    t.boolean "placement", default: false, null: false
    t.integer "result", null: false
    t.integer "time_of_day", null: false
    t.integer "day_of_week", null: false
    t.datetime "time", null: false
    t.index ["day_of_week"], name: "index_matches_on_day_of_week"
    t.index ["map_id"], name: "index_matches_on_map_id"
    t.index ["oauth_account_id", "time"], name: "index_matches_on_oauth_account_id_and_time"
    t.index ["placement"], name: "index_matches_on_placement"
    t.index ["result"], name: "index_matches_on_result"
    t.index ["season_id"], name: "index_matches_on_season_id"
    t.index ["time_of_day"], name: "index_matches_on_time_of_day"
  end

  create_table "oauth_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", limit: 30, null: false
    t.string "uid", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "battletag"
    t.index ["provider", "uid"], name: "index_oauth_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_oauth_accounts_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_seasons_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "battletag", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "UTC", null: false
    t.index ["battletag"], name: "index_users_on_battletag", unique: true
  end

end
