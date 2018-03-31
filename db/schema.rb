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

ActiveRecord::Schema.define(version: 20180331222533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", limit: 30, null: false
    t.string "uid", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "battletag"
    t.string "platform", limit: 3, default: "pc", null: false
    t.string "region", limit: 6, default: "us", null: false
    t.boolean "admin", default: false, null: false
    t.text "avatar_url"
    t.integer "rank"
    t.integer "level"
    t.text "level_url"
    t.integer "parent_account_id"
    t.index ["battletag", "provider", "uid"], name: "index_accounts_on_battletag_and_provider_and_uid", unique: true
    t.index ["parent_account_id"], name: "index_accounts_on_parent_account_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "friends", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_friends_on_user_id_and_name", unique: true
  end

  create_table "heroes", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "role", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_heroes_on_name", unique: true
    t.index ["role"], name: "index_heroes_on_role"
  end

  create_table "maps", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "map_type", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "color", limit: 16, default: "#ffffff", null: false
    t.index ["name"], name: "index_maps_on_name", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "map_id"
    t.integer "rank"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prior_match_id"
    t.boolean "placement"
    t.integer "result"
    t.integer "time_of_day"
    t.integer "day_of_week"
    t.integer "season", null: false
    t.boolean "enemy_thrower"
    t.boolean "ally_thrower"
    t.boolean "enemy_leaver"
    t.boolean "ally_leaver"
    t.integer "group_member_ids", default: [], null: false, array: true
    t.integer "hero_ids", default: [], null: false, array: true
    t.index ["account_id"], name: "index_matches_on_account_id"
    t.index ["ally_leaver"], name: "index_matches_on_ally_leaver"
    t.index ["ally_thrower"], name: "index_matches_on_ally_thrower"
    t.index ["created_at"], name: "index_matches_on_created_at"
    t.index ["day_of_week"], name: "index_matches_on_day_of_week"
    t.index ["enemy_leaver"], name: "index_matches_on_enemy_leaver"
    t.index ["enemy_thrower"], name: "index_matches_on_enemy_thrower"
    t.index ["map_id"], name: "index_matches_on_map_id"
    t.index ["placement"], name: "index_matches_on_placement"
    t.index ["result"], name: "index_matches_on_result"
    t.index ["season"], name: "index_matches_on_season"
    t.index ["time_of_day"], name: "index_matches_on_time_of_day"
  end

  create_table "season_shares", force: :cascade do |t|
    t.integer "season", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.index ["account_id", "season"], name: "index_season_shares_on_account_id_and_season", unique: true
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "number", null: false
    t.integer "max_rank", default: 5000, null: false
    t.date "started_on"
    t.date "ended_on"
    t.index ["number"], name: "index_seasons_on_number", unique: true
    t.index ["started_on", "ended_on"], name: "index_seasons_on_started_on_and_ended_on"
  end

  create_table "users", force: :cascade do |t|
    t.string "battletag", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battletag"], name: "index_users_on_battletag", unique: true
  end

end
