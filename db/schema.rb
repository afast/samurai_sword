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

ActiveRecord::Schema.define(version: 2020_05_03_063049) do

  create_table "games", force: :cascade do |t|
    t.integer "num_players"
    t.boolean "waiting_room"
    t.boolean "started"
    t.boolean "ended"
    t.text "deck"
    t.text "discarded"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "amount_players"
    t.text "players"
    t.text "users"
    t.integer "hand"
    t.integer "turn"
    t.integer "phase"
    t.text "log"
    t.boolean "wait_for_answer"
    t.text "target"
    t.boolean "game_ended"
    t.integer "samurai_points"
    t.integer "ninja_points"
    t.integer "ronin_points"
    t.string "winning_team"
    t.string "status"
    t.text "pending_answer"
    t.string "last_action"
    t.text "last_error"
    t.text "defend_from"
    t.boolean "resolve_bushido"
    t.boolean "bushido_in_play"
  end

  create_table "games_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
