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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_154214) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accommodation_locations", force: :cascade do |t|
    t.integer "capacity"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name"
    t.string "type"
    t.datetime "updated_at", null: false
  end

  create_table "accommodations", force: :cascade do |t|
    t.integer "bed_number"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "type"
    t.datetime "updated_at", null: false
  end

  create_table "activities", force: :cascade do |t|
    t.date "availability_end"
    t.date "avalability_start"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.datetime "processed_at"
    t.string "source"
    t.string "type"
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "nationality"
    t.string "password"
    t.string "password_digest"
    t.string "permission"
    t.string "phone_number"
    t.string "role"
    t.datetime "updated_at", null: false
  end
end
