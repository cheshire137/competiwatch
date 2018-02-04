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

ActiveRecord::Schema.define(version: 20180204190815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "oauth_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", limit: 30, null: false
    t.string "uid", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_oauth_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_oauth_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "battletag", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battletag"], name: "index_users_on_battletag", unique: true
  end

end
