# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160316165250) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: :cascade do |t|
    t.integer  "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "boards", ["game_id"], name: "index_boards_on_game_id", using: :btree

  create_table "cells", force: :cascade do |t|
    t.string   "x_param"
    t.string   "y_param"
    t.integer  "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  add_index "cells", ["board_id"], name: "index_cells_on_board_id", using: :btree

  create_table "challenges", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "opponent_id"
    t.string   "color"
    t.boolean  "access",      default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "challenges", ["opponent_id"], name: "index_challenges_on_opponent_id", using: :btree
  add_index "challenges", ["user_id"], name: "index_challenges_on_user_id", using: :btree

  create_table "figures", force: :cascade do |t|
    t.string   "type"
    t.string   "color"
    t.integer  "cell_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "board_id"
    t.string   "image"
    t.string   "beaten_fields",    default: [],                 array: true
    t.string   "protected_fields", default: [],                 array: true
    t.boolean  "attack",           default: false
  end

  add_index "figures", ["board_id"], name: "index_figures_on_board_id", using: :btree
  add_index "figures", ["cell_id"], name: "index_figures_on_cell_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "opponent_id"
    t.boolean  "access",            default: true
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "white_turn",        default: true
    t.float    "game_result"
    t.string   "white_checkmat"
    t.string   "black_checkmat"
    t.string   "white_beats",       default: [],                array: true
    t.string   "black_beats",       default: [],                array: true
    t.string   "white_protectes",   default: [],                array: true
    t.string   "black_protectes",   default: [],                array: true
    t.string   "w_king_protectors", default: [],                array: true
    t.string   "b_king_protectors", default: [],                array: true
    t.string   "game_result_text"
    t.integer  "challenge_id"
    t.integer  "user_rating"
    t.integer  "opponent_rating"
    t.string   "guest"
  end

  add_index "games", ["challenge_id"], name: "index_games_on_challenge_id", using: :btree
  add_index "games", ["opponent_id"], name: "index_games_on_opponent_id", using: :btree
  add_index "games", ["user_id"], name: "index_games_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "turns", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "second_from"
    t.string   "second_to"
    t.string   "next_turn"
    t.string   "icon"
  end

  add_index "turns", ["game_id"], name: "index_turns_on_game_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "username",               default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "elo",                    default: 1000
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
