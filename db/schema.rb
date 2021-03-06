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

ActiveRecord::Schema.define(version: 20140211221257) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "recipe_ingredients", force: true do |t|
    t.integer  "recipe_id",                 null: false
    t.string   "quantity",                  null: false
    t.string   "unit_of_measure"
    t.string   "alternate_quantity"
    t.string   "alternate_unit_of_measure"
    t.string   "ingredient",                null: false
    t.string   "additional_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", force: true do |t|
    t.string   "name",                                         limit: 40, null: false
    t.integer  "user_id",                                                 null: false
    t.string   "recipe_source",                                limit: 30
    t.string   "recipe_source_desc",                           limit: 90
    t.string   "original_attachment_file_name"
    t.string   "original_attachment_content_type"
    t.integer  "original_attachment_file_size"
    t.datetime "original_attachment_updated_at"
    t.string   "intermediate_process_attachment_file_name"
    t.string   "intermediate_process_attachment_content_type"
    t.integer  "intermediate_process_attachment_file_size"
    t.datetime "intermediate_process_attachment_updated_at"
    t.string   "post_process_attachment_file_name"
    t.string   "post_process_attachment_content_type"
    t.integer  "post_process_attachment_file_size"
    t.datetime "post_process_attachment_updated_at"
    t.text     "attachment_as_text"
    t.text     "attachment_processing_output"
    t.datetime "attachment_processing_starttime"
    t.datetime "attachment_processing_endtime"
    t.boolean  "attachment_processing_successful"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipes", ["user_id", "name"], name: "index_recipes_on_user_id_and_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username",        limit: 35, null: false
    t.string   "email",                      null: false
    t.string   "password_digest",            null: false
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
