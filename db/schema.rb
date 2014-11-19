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

ActiveRecord::Schema.define(version: 20141106191531) do

  create_table "api_keys", force: true do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "last_access"
    t.boolean  "is_locked",    default: false
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", force: true do |t|
    t.integer  "user_id"
    t.date     "registration_date"
    t.string   "domain"
    t.date     "expiry_date"
    t.string   "status"
    t.string   "ns_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_accounts", force: true do |t|
    t.integer  "provider_id"
    t.string   "email"
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_to_emails", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "email_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "email"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", force: true do |t|
    t.string   "cellphone"
    t.integer  "inviter_id"
    t.integer  "domain_id"
    t.boolean  "accepted",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_to_company_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "cellphone"
    t.string   "password_digest"
    t.string   "name"
    t.string   "email"
    t.integer  "user_credential_id"
    t.boolean  "activated",          default: false
    t.boolean  "locked",             default: false
    t.string   "confirmation_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "device_token"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
